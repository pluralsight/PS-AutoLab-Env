#region Param

param
(
    [String]$DomainName,

    [String]$DomainNetbiosName,

    [PSCredential]$Credential,
    
    [PSCredential]$DomainCredential,
    
    [PSCredential]$SafeModeAdministratorPassword,

    [String]$EncryptionCertificateThumbprint
)

#endregion

#region Decrypt

function Decrypt
{
    param
    (
        [Parameter(Mandatory)]
        [String]$Thumbprint,

        [Parameter(Mandatory)]
        [String]$Base64EncryptedValue
    )

    # Decode Base64 string
    $encryptedBytes = [System.Convert]::FromBase64String($Base64EncryptedValue)

    # Get certificate from store
    $store = new-object System.Security.Cryptography.X509Certificates.X509Store([System.Security.Cryptography.X509Certificates.StoreLocation]::LocalMachine)
    $store.open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadOnly)
    $certificate = $store.Certificates | %{if($_.thumbprint -eq $Thumbprint){$_}}
   
    # Decrypt
    $decryptedBytes = $certificate.PrivateKey.Decrypt($encryptedBytes, $false)
    $decryptedValue = [System.Text.Encoding]::UTF8.GetString($decryptedBytes)
    
    return $decryptedValue
}

if ($EncryptionCertificateThumbprint)
{
    Write-Verbose -Message "Decrypting parameters with certificate $EncryptionCertificateThumbprint..."

    $Password = Decrypt -Thumbprint $EncryptionCertificateThumbprint -Base64EncryptedValue $Password
    $SafeModeAdministratorPassword = Decrypt -Thumbprint $EncryptionCertificateThumbprint -Base64EncryptedValue $SafeModeAdministratorPassword

    Write-Verbose -Message "Successfully decrypted parameters."
}
else
{
    Write-Verbose -Message "No encryption certificate specified. Assuming cleartext parameters."
}

#endregion

#region Config Data

if ($env:COMPUTERNAME -match 'DC-Server\d\d') {
    $ConfigData = @{
        AllNodes = @(
             @{
                Nodename = $env:COMPUTERNAME
                ServerRole = 'Active Directory Domain Controller'
                DomainName = $DomainName
                DomainNetbiosName = $DomainNetbiosName
                Disk = 1
                Drive = 'F'
                PSDscAllowPlainTextPassword = $true
                Credential = $Credential
                DomainCredential = $DomainCredential
                SMCredential = $SafeModeAdministratorPassword
            }
        )
    }
}

if ($EncryptionCertificateThumbprint)
{
    $certificate = dir Cert:\LocalMachine\My\$EncryptionCertificateThumbprint
    $certificatePath = Join-Path -path $PSScriptRoot -childPath "EncryptionCertificate.cer"
    Export-Certificate -Cert $certificate -FilePath $certificatePath | Out-Null
    $configData = @{
        AllNodes = @(
            @{
                Nodename = "*"
                CertificateFile = $certificatePath
                Thumbprint = $EncryptionCertificateThumbprint
                PSDscAllowPlainTextPassword = $false
            }
        )
    }
}

#endregion

#region First DC Configuration Script

if ((test-path C:\Windows\temp\FirstDC.txt) -eq $True)
{
    configuration FirstDomainController
    {
        Import-DscResource -ModuleName xComputerManagement, xActiveDirectory, xStorage, xAdcsDeployment

        node $AllNodes.Where{$_.ServerRole -eq 'Active Directory Domain Controller'}.Nodename
        {    
            xWaitforDisk SMA
            {
                DiskNumber = $Node.Disk
                RetryCount = 720
            }

            xDisk DataDisk
            {
                DiskNumber = $Node.Disk
                DriveLetter = $Node.Drive
                DependsOn = '[xWaitforDisk]SMA'
            }
        
            WindowsFeature AD-Domain-Services
            {
                   Ensure = 'Present'
                   Name = 'AD-Domain-Services'
            }
            
            WindowsFeature ADCS-Cert-Authority
            {
                   Ensure = 'Present'
                   Name = 'ADCS-Cert-Authority'
            }

            WindowsFeature ADCS-Web-Enrollment
            {
                Ensure = 'Present'
                Name = 'ADCS-Web-Enrollment'
            }

            xADDomain PrimaryDC
            {
                DomainAdministratorCredential = $Node.Credential
                DomainName = $Node.DomainName
                SafemodeAdministratorPassword = $Node.SMCredential
                DatabasePath = $Node.Drive + ":\NTDS"
                LogPath = $Node.Drive + ":\NTDS"
                SysvolPath = $Node.Drive + ":\SYSVOL"
                DependsOn = "[xDisk]DataDisk", "[WindowsFeature]AD-Domain-Services"
            }

            xADCSCertificationAuthority ADCS
            {
                Ensure = 'Present'
                Credential = $Node.Credential
                CAType = 'EnterpriseRootCA'
                DependsOn = '[WindowsFeature]ADCS-Cert-Authority'              
            }

            xADCSWebEnrollment CertSrv
            {
                IsSingleInstance = 'Yes'
                Ensure = 'Absent'
                Credential = $Node.Credential
                DependsOn = '[xADCSCertificationAuthority]ADCS'
            }
            
            LocalConfigurationManager
            {
                CertificateId = $node.Thumbprint
                ConfigurationMode = 'ApplyandAutoCorrect'
                RebootNodeIfNeeded = 'True'
            }
        }
    }

FirstDomainController -ConfigurationData $configData -OutputPath $PSScriptRoot

}

#endregion

#region DC Configuration Script

if ((test-path C:\Windows\temp\FirstDC.txt) -eq $False)
{
    configuration DomainController
    {
        Import-DscResource -ModuleName xComputerManagement, xActiveDirectory, xStorage

        node $AllNodes.Where{$_.ServerRole -eq 'Active Directory Domain Controller'}.Nodename
        {    
             xWaitforDisk DataDisk
            {
                DiskNumber = $Node.Disk
                RetryCount = 720
            }

            xDisk DataDisk
            {
                DiskNumber = $Node.Disk
                DriveLetter = $Node.Drive
                DependsOn = '[xWaitforDisk]DataDisk'
            }
        
            WindowsFeature AD-Domain-Services
            {
                   Ensure = 'Present'
                   Name = 'AD-Domain-Services'
            }

            xWaitForADDomain WaitforDomain
            {
                DomainName = $Node.DomainName
                DomainUserCredential = $Node.DomainCredential
                RetryCount = 720
                RetryIntervalSec = 10
                DependsOn = "[WindowsFeature]AD-Domain-Services"
            }
        
            xADDomainController BackupDC
            {
                DomainAdministratorCredential = $Node.DomainCredential
                DomainName = $Node.DomainName
                SafemodeAdministratorPassword = $Node.SMCredential
                DatabasePath = $Node.Drive + ":\NTDS"
                LogPath = $Node.Drive + ":\NTDS"
                SysvolPath = $Node.Drive + ":\SYSVOL"
                DependsOn = '[xDisk]DataDisk', '[WindowsFeature]AD-Domain-Services', '[xWaitforADDomain]WaitforDomain'
            }

            LocalConfigurationManager
            {
                CertificateId = $node.Thumbprint
                ConfigurationMode = 'ApplyandAutoCorrect'
                RebootNodeIfNeeded = 'True'
            }
        }
    }

DomainController -ConfigurationData $configData -OutputPath $PSScriptRoot

}

#endregion

#region Apply MOF

Set-WSManQuickConfig -Force > $null

Set-DscLocalConfigurationManager -ComputerName $env:COMPUTERNAME -Path $PSScriptRoot -Verbose
Start-DscConfiguration -ComputerName $env:COMPUTERNAME -Path $PSScriptRoot -Force -Verbose -Wait

#endregion
