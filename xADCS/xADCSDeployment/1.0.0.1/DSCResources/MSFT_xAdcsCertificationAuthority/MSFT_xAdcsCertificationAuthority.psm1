#region Get Resource
Function Get-TargetResource
{
    [OutputType([System.Collections.Hashtable])]
    [CmdletBinding()]
    param(
    [ValidateSet('Present','Absent')]
    [string]$Ensure = 'Present',
    [string]$CACommonName,
    [string]$CADistinguishedNameSuffix,
    [Parameter(Mandatory)]
    [ValidateSet('EnterpriseRootCA','EnterpriseSubordinateCA','StandaloneRootCA','StandaloneSubordinateCA')]
    [string]$CAType,
    [string]$CertFile,
    [pscredential]$CertFilePassword,
    [string]$CertificateID,
    [Parameter(Mandatory)]
    [pscredential]$Credential,
    [string]$CryptoProviderName,
    [string]$DatabaseDirectory,
    [string]$HashAlgorithmName,
    [boolean]$IgnoreUnicode,
    [string]$KeyContainerName,
    [uint32]$KeyLength,
    [string]$LogDirectory,
    [string]$OutputCertRequestFile,
    [boolean]$OverwriteExistingCAinDS,
    [boolean]$OverwriteExistingDatabase,
    [boolean]$OverwriteExistingKey,
    [string]$ParentCA,
    [ValidateSet('Hours','Days','Months','Years')]
    [string]$ValidityPeriod,
    [uint32]$ValidityPeriodUnits
    )

    $ADCSParams = @{} + $PSBoundParameters
    $ADCSParams.Remove('Ensure') | out-null
    $ADCSParams.Remove('Debug') | out-null
    $ADCSParams.Remove('ErrorAction') | out-null

    return @{Ensure = $Ensure
        Credential = $Credential
        IsCA = Test-TargetResource @ADCSParams
    }
}
# Get-TargetResource -CAType EnterpriseRootCA -Credential (get-credential)
# Expected Outcome: Returns a hashtable with appropriate values
#endregion

#region Set Resource
Function Set-TargetResource
{
    [CmdletBinding()]
    param(
    [ValidateSet('Present','Absent')]
    [string]$Ensure = 'Present',
    [string]$CACommonName,
    [string]$CADistinguishedNameSuffix,
    [Parameter(Mandatory)]
    [ValidateSet('EnterpriseRootCA','EnterpriseSubordinateCA','StandaloneRootCA','StandaloneSubordinateCA')]
    [string]$CAType,
    [string]$CertFile,
    [pscredential]$CertFilePassword,
    [string]$CertificateID,
    [Parameter(Mandatory)]
    [pscredential]$Credential,
    [string]$CryptoProviderName,
    [string]$DatabaseDirectory,
    [string]$HashAlgorithmName,
    [boolean]$IgnoreUnicode,
    [string]$KeyContainerName,
    [uint32]$KeyLength,
    [string]$LogDirectory,
    [string]$OutputCertRequestFile,
    [boolean]$OverwriteExistingCAinDS,
    [boolean]$OverwriteExistingDatabase,
    [boolean]$OverwriteExistingKey,
    [string]$ParentCA,
    [ValidateSet('Hours','Days','Months','Years')]
    [string]$ValidityPeriod,
    [uint32]$ValidityPeriodUnits
    )

    $ADCSParams = @{} + $PSBoundParameters
    $ADCSParams.Remove('Ensure') | out-null
    $ADCSParams.Remove('Debug') | out-null
    $ADCSParams.Remove('ErrorAction') | out-null

    switch ($Ensure) {
        'Present' {
                (Install-AdcsCertificationAuthority @ADCSParams -Force).ErrorString
        }
        'Absent' {
                (Uninstall-AdcsCertificationAuthority -Force).ErrorString
        }
    }
}
# Set-TargetResource -CAType EnterpriseRootCA -Credential (Get-Credential)
# Expected Outcome: Setup Certificate Authority on this node
#endregion

#region Test Resource
Function Test-TargetResource
{
    [OutputType([System.Boolean])]
    [CmdletBinding()]
    param(
    [ValidateSet('Present','Absent')]
    [string]$Ensure = 'Present',
    [string]$CACommonName,
    [string]$CADistinguishedNameSuffix,
    [Parameter(Mandatory)]
    [ValidateSet('EnterpriseRootCA','EnterpriseSubordinateCA','StandaloneRootCA','StandaloneSubordinateCA')]
    [string]$CAType,
    [string]$CertFile,
    [pscredential]$CertFilePassword,
    [string]$CertificateID,
    [Parameter(Mandatory)]
    [pscredential]$Credential,
    [string]$CryptoProviderName,
    [string]$DatabaseDirectory,
    [string]$HashAlgorithmName,
    [boolean]$IgnoreUnicode,
    [string]$KeyContainerName,
    [uint32]$KeyLength,
    [string]$LogDirectory,
    [string]$OutputCertRequestFile,
    [boolean]$OverwriteExistingCAinDS,
    [boolean]$OverwriteExistingDatabase,
    [boolean]$OverwriteExistingKey,
    [string]$ParentCA,
    [ValidateSet('Hours','Days','Months','Years')]
    [string]$ValidityPeriod,
    [uint32]$ValidityPeriodUnits
    )

    $ADCSParams = @{} + $PSBoundParameters
    $ADCSParams.Remove('Ensure') | out-null
    $ADCSParams.Remove('Debug') | out-null
    $ADCSParams.Remove('ErrorAction') | out-null
    
    try{
        $test = Install-AdcsCertificationAuthority @ADCSParams -WhatIf
        Switch ($Ensure) {
            'Present' {return $false}
            'Absent' {return $true}
            }
    }
    catch{
        Write-verbose $_
        Switch ($Ensure) {
            'Present' {return $true}
            'Absent' {return $false}
            }
    }
}

# Test-TargetResource -CAType EnterpriseRootCA -Credential (get-credential)
# Expected Outcome: Returns boolean indicating whether this machine is a Certificate Authority.
#endregion

Export-ModuleMember -Function *-TargetResource
