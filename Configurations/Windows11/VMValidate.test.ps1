#requires -version 5.1

#test if VM setup is complete

# Uncomment the Write-Host lines for development and troubleshooting

BeforeDiscovery {
    #Write-Host 'v2.12.1' -ForegroundColor yellow
    #Define variables that will be used in the assertion script blocks
    $Node = 'Win10Ent'
    $LabData = Import-PowerShellDataFile -Path $PSScriptRoot\VMConfigurationData.psd1
    $Computername = $LabData.AllNodes[1].NodeName
    $prefix = $LabData.NonNodeData.Lability.EnvironmentPrefix
    $VMName = "$($prefix)$Computername"
    $Secure = ConvertTo-SecureString -String $LabData.AllNodes.LabPassword -AsPlainText -Force
    $cred = New-Object -TypeName PSCredential -ArgumentList Administrator, $secure
    $FireWallRules = $LabData.AllNodes.FirewallRuleNames
    $cl = New-PSSession -VMName $VMName -Credential $Cred -ErrorAction Stop
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
    $pkg = Invoke-Command { $using:rsat | ForEach-Object { Get-WindowsCapability -Online -Name $_ } } -Session $cl

    $rsatStatus = '{0}/{1}' -f ($pkg.where({ $_.state -eq 'installed' }).Name).count, $rsat.count
    $NodeIP = $LabData.AllNodes[1].IPAddress
    $DNSAddress = $LabData.AllNodes[0].DnsServerAddress

    $CNTest = @{ CN = $Computername }
    $IPTest = @{ IP = $NodeIP }
    $DNSTest = @{Address = $DNSAddress }

    if ($cl) {
        $cl | Remove-PSSession
    }
}

Describe $Node {

    BeforeAll {
        $LabData = Import-PowerShellDataFile -Path $PSScriptRoot\VMConfigurationData.psd1
        $Computername = $LabData.AllNodes[1].NodeName

        #The prefix only changes the name of the VM not the guest computername
        $prefix = $LabData.NonNodeData.Lability.EnvironmentPrefix
        $VMName = "$($prefix)$Computername"
        $Secure = ConvertTo-SecureString -String $LabData.AllNodes.LabPassword -AsPlainText -Force
        $cred = New-Object -TypeName PSCredential -ArgumentList Administrator, $secure

        # Write-Host "Connecting to $VMName" -fore yellow
        #set error action preference to suppress all error messages which would be normal while configurations are converging
        #turn off progress bars
        $prep = {
            $ProgressPreference = 'SilentlyContinue'
            $errorActionPreference = 'SilentlyContinue'
        }
        $cl = New-PSSession -VMName $VMName -Credential $Cred -ErrorAction Stop
        Invoke-Command -Scriptblock $prep -Session $cl
        #run commands that will be used in the assertions
        $test = Invoke-Command { Get-CimInstance -ClassName win32_OperatingSystem -Property version, caption } -Session $cl
        $if = Invoke-Command -ScriptBlock { Get-NetIPAddress -InterfaceAlias 'Ethernet' -AddressFamily IPv4 } -Session $cl
        $dns = Invoke-Command { Get-DnsClientServerAddress -InterfaceAlias ethernet -AddressFamily IPv4 } -Session $cl
        $wg = Invoke-Command { (Get-CimInstance -ClassName win32_computersystem) } -Session $cl
        $local = Invoke-Command { Get-CimInstance -ClassName win32_UserAccount -Filter "Name='$using:env:username'" } -Session $cl
        $admins = Invoke-Command {
            Get-CimInstance -ClassName win32_group -Filter "name='Administrators'" | Get-CimAssociatedInstance -ResultClassName win32_UserAccount
        } -Session $cl
        $rdpTest = Invoke-Command { Get-ItemPropertyValue -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\' -Name fDenyTSConnections } -Session $cl
        $FireWallRules = $LabData.AllNodes.FirewallRuleNames
        $fw = Invoke-Command { Get-NetFirewallRule -Name $using:FireWallRules } -Session $cl |
        ForEach-Object -Begin { $tmp = @{} } -Process { $tmp.Add($_.Name, $_.Enabled) } -End { $tmp }

    }
    AfterAll {
        if ($cl) {
            $cl | Remove-PSSession
        }
    }
    It "[$Node] Should be running Windows 11" {
        $test.caption | Should -BeLike '*Windows 11*'
    }
    It "[$Node] Should have a computername of <CN>" -ForEach $CNTest {
        #Write-Host "testing for $Computername" -fore yellow
        Invoke-Command { $Env:Computername } -Session $cl | Should -Be $CN
    }
    It "[$Node] Should have an IP address of <IP>" -ForEach $IPTest {
        $if.ipv4Address | Should -Be $IP
    }
    It "[$Node] Should have firewall rule <_> enabled" -ForEach $FireWallRules {
        $fw[$_] | Should -Be $True
    }
    It "[$Node] Should have a DNS server configuration of <Address>" -ForEach $DNSTest {
        #$dns.ServerAddresses | Out-String | Write-Host -ForegroundColor yellow
        $dns.ServerAddresses -contains $Address | Should -Be 'True'
    }
    It "[$Node] Should belong to the LAB Workgroup" {
        $wg.Workgroup | Should -Be 'Lab'
    }
    It "[$Node] Should have a local admin account for $env:username" {
        $local.AccountType | Should -Be 512
        $local.Name | Should -Be $env:username
        # Write-Host ($local | Out-string) -ForegroundColor cyan
    }
    It "[$Node] Should have 2 members in Administrators" {
        # Write-Host ($admins | Out-string) -ForegroundColor cyan
        $Admins.Count | Should -Be 2
    }
    It "[$Node] Should have RDP for admin access enabled" {
        $rdpTest | Should -Be 0
    }

}

