#requires -version 5.1

#test if VM setup is complete

# Uncomment the Write-Host lines for development and troubleshooting

$LabData = Import-PowerShellDataFile -Path $PSScriptRoot\VMConfigurationData.psd1
if (-Not $LabData) {
    Write-Warning 'Failed to get lab data.'
    #bail out
    Return
}

$Secure = ConvertTo-SecureString -String $LabData.AllNodes.LabPassword -AsPlainText -Force
$cred = New-Object -TypeName PSCredential -ArgumentList Administrator, $secure
$Computername = $LabData.AllNodes[1].NodeName
$IP = $LabData.AllNodes[1].IPAddress
$DNSAddress = $LabData.AllNodes[0].DnsServerAddress

#The prefix only changes the name of the VM not the guest computername
$prefix = $LabData.NonNodeData.Lability.EnvironmentPrefix
$VMName = "$($prefix)$Computername"

#set error action preference to suppress all error messages which would be normal while configurations are converging
#turn off progress bars
$prep = {
    $ProgressPreference = 'SilentlyContinue'
    $errorActionPreference = 'silentlyContinue'
}

Describe $Computername {

    $rsat = @(
        'Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0',
        'Rsat.BitLocker.Recovery.Tools~~~~0.0.1.0',
        'Rsat.CertificateServices.Tools~~~~0.0.1.0',
        'Rsat.DHCP.Tools~~~~0.0.1.0',
        'Rsat.Dns.Tools~~~~0.0.1.0',
        'Rsat.FailoverCluster.Management.Tools~~~~0.0.1.0',
        'Rsat.FileServices.Tools~~~~0.0.1.0',
        'Rsat.GroupPolicy.Management.Tools~~~~0.0.1.0',
        'Rsat.IPAM.Client.Tools~~~~0.0.1.0',
        'Rsat.ServerManager.Tools~~~~0.0.1.0'
    )

    Try {
        $cl = New-PSSession -VMName $VMName -Credential $cred -ErrorAction Stop
        Invoke-Command $prep -Session $cl

        It "[$Computername] Should be running Windows 10" {
            $test = Invoke-Command { Get-CimInstance -ClassName win32_operatingsystem -Property version, caption } -Session $cl
            $test.caption | Should BeLike '*Windows 10*'
        }
        It "[$Computername] Should have an IP address of $IP" {
            $i = Invoke-Command -ScriptBlock { Get-NetIPAddress -InterfaceAlias 'Ethernet' -AddressFamily IPv4 } -Session $cl
            $i.ipv4Address | Should be $IP
        }

        $dns = Invoke-Command { Get-DnsClientServerAddress -InterfaceAlias ethernet -AddressFamily IPv4 } -Session $cl
        It "[$Computername] Should have a DNS server configuration of $DNSAddress" {
            $dns.ServerAddresses -contains $DNSAddress | Should Be 'True'
        }

        It "[$Computername] Should belong to the LAB Workgroup" {
            $wg = Invoke-Command { (Get-CimInstance -ClassName win32_computersystem) } -Session $cl
            $wg.Workgroup | Should Be 'Lab'
        }

        It "[$Computername] Should have a local admin account for $env:username" {
            $local = Invoke-Command { Get-CimInstance -ClassName win32_useraccount -Filter "Name='$using:env:username'" } -Session $cl
            $local.AccountType | Should be 512
            $local.Name | Should Be $env:username
            # Write-Host ($local | Out-string) -ForegroundColor cyan
        }

        It "[$Computername] Should have 2 members in Administrators" {
            $admins = Invoke-Command {
                Get-CimInstance -ClassName win32_group -Filter "name='Administrators'" | Get-CimAssociatedInstance -ResultClassName win32_useraccount
            } -Session $cl
            $Admins.Count | Should be 2
            # Write-Host ($admins | Out-string) -ForegroundColor cyan
        }

        $pkg = Invoke-Command { $using:rsat | ForEach-Object { Get-WindowsCapability -Online -Name $_ } } -Session $cl
        $RSATStatus = '{0}/{1}' -f ($pkg.where({ $_.state -eq 'installed' }).Name).count, $rsat.count
        It "[Win10] Should have RSAT installed [$RSATStatus]" {
            # write-host ($pkg | Select-object Name,DisplayName,State | format-list | Out-String) -ForegroundColor cyan
            $pkg | Where-Object { $_.state -ne 'installed' } | Should be $Null
        }
    }
    Catch {
        It "[$Computername] Should allow a PSSession but got error: $($_.exception.message)" {
            $false | Should Be $True
        }
    }
} #client

if ($cl) {
    $cl | Remove-PSSession
}
