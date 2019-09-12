#requires -version 5.1

#test if VM setup is complete


#The password will be passed by the control script WaitforVM.ps1
#You can manually set it while developing this Pester test
$LabData = Import-PowerShellDataFile -Path $PSScriptRoot\VMConfigurationData.psd1
$Secure = ConvertTo-SecureString -String "$($labdata.allnodes.labpassword)" -AsPlainText -Force
$Domain = "company"
$cred = New-Object PSCredential "Company\Administrator", $Secure

$all = @()
Describe DC1 {

    $dc = New-PSSession -VMName DC1 -Credential $cred -ErrorAction SilentlyContinue
    $all += $dc
    #set error action preference to suppress all error messsages
    Invoke-Command { $errorActionPreference = 'silentlyContinue'} -session $dc

    It "[DC1] Should accept domain admin credential" {
        $dc.Count | Should Be 1
    }

    #test for features
    $feat = Invoke-Command { Get-WindowsFeature | Where-object installed} -session $dc
    $needed = 'AD-Domain-Services', 'DNS', 'RSAT-AD-Tools',
    'RSAT-AD-PowerShell'
    foreach ($item in $needed) {
        It "[DC1] Should have feature $item installed" {
            $feat.Name -contains $item | Should Be "True"
        }
    }

    It "[DC1] Should have an IP address of 192.168.3.10" {
        $i = Invoke-command -ScriptBlock { Get-NetIPAddress -interfacealias 'Ethernet' -AddressFamily IPv4} -Session $dc
        $i.ipv4Address | should be '192.168.3.10'
    }

    It "[DC1] Should have a domain name of $domain" {
        $r = Invoke-command { Get-ADDomain -ErrorAction SilentlyContinue } -session $dc
        $r.name | should Be $domain
    }

    $OUs = Invoke-command { Get-ADorganizationalUnit -filter * -ErrorAction SilentlyContinue} -session $dc
    $needed = 'IT', 'Dev', 'Marketing', 'Sales', 'Accounting', 'JEA_Operators'
    foreach ($item in $needed) {
        It "[DC1] Should have organizational unit $item" {
            $OUs.name -contains $item | Should Be "True"
        }
    }
    $groups = Invoke-Command { Get-ADGroup -filter * -ErrorAction SilentlyContinue} -session $DC
    $target = "IT", "Sales", "Marketing", "Accounting", "JEA Operators"
    foreach ($item in $target) {

        It "[DC1] Should have a group called $item" {
            $groups.Name -contains $item | Should Be "True"
        }

    }

    $users = Invoke-Command { Get-AdUser -filter * -ErrorAction SilentlyContinue} -session $dc
    It "[DC1] Should have at least 15 user accounts" {
        $users.count | should BeGreaterThan 15
    }

    $computer = Invoke-Command { Get-ADComputer -filter * -ErrorAction SilentlyContinue} -session $dc
    It "[DC1] Should have a computer account for Client" {
        $computer.name -contains "cli1" | Should Be "True"
    }

    It "[DC1] Should have a computer account for S1" {
        $computer.name -contains "S1" | Should Be "True"
    }

    It "[DC1] Should have a computer account for S2" {
        $computer.name -contains "S2" | Should Be "True"
    }

    It "[DC1] Should have a computer account for PullServer" {
        $computer.name -contains "PullServer" | Should Be "True"
    }

} #DC

Describe S1 {
    $s1 = New-PSSession -VMName S1 -Credential $cred -ErrorAction SilentlyContinue
    $all += $s1
    It "[S1] Should accept domain admin credential" {
        $s1.Count | Should Be 1
    }

    It "[S1] Should have an IP address of 192.168.3.50" {
        $i = Invoke-command -ScriptBlock { Get-NetIPAddress -interfacealias 'Ethernet' -AddressFamily IPv4} -Session $S1
        $i.ipv4Address | should be '192.168.3.50'
    }
    $dns = Invoke-Command {Get-DnsClientServerAddress -InterfaceAlias ethernet -AddressFamily IPv4} -session $s1
    It "[S1] Should have a DNS server configuration of 192.168.3.10" {
        $dns.ServerAddresses -contains '192.168.3.10' | Should Be "True"
    }
} #S1

Describe S2 {
    $s2 = New-PSSession -VMName S2 -Credential $cred -ErrorAction SilentlyContinue
    $all += $s2
    It "[S2] Should accept domain admin credential" {
        $s2.Count | Should Be 1
    }

    It "[S2] Should have an IP address of 192.168.3.51" {
        $i = Invoke-command -ScriptBlock { Get-NetIPAddress -interfacealias 'Ethernet' -AddressFamily IPv4} -Session $S2
        $i.ipv4Address | should be '192.168.3.51'
    }
    $dns = Invoke-Command {Get-DnsClientServerAddress -InterfaceAlias ethernet -AddressFamily IPv4} -session $s2
    It "[S2] Should have a DNS server configuration of 192.168.3.10" {
        $dns.ServerAddresses -contains '192.168.3.10' | Should Be "True"
    }
} #S2

Describe PullServer {
    $PullServer = New-PSSession -VMName PullServer -Credential $cred -ErrorAction SilentlyContinue
    $all += $PullServer
    It "[PullServer] Should accept domain admin credential" {
        $PullServer.Count | Should Be 1
    }

    It "[PullServer] Should have an IP address of 192.168.3.70" {
        $i = Invoke-command -ScriptBlock { Get-NetIPAddress -interfacealias 'Ethernet' -AddressFamily IPv4} -Session $PullServer
        $i.ipv4Address | should be '192.168.3.70'
    }
    $dns = Invoke-Command {Get-DnsClientServerAddress -InterfaceAlias ethernet -AddressFamily IPv4} -session $PullServer
    It "[PullServer] Should have a DNS server configuration of 192.168.3.10" {
        $dns.ServerAddresses -contains '192.168.3.10' | Should Be "True"
    }
}

Describe Cli1 {

    $cl = New-PSSession -VMName cli1 -Credential $cred -ErrorAction SilentlyContinue
    $all += $cl
    It "[CLI] Should accept domain admin credential" {
        $cl = New-PSSession -VMName cli1 -Credential $cred -ErrorAction SilentlyContinue
        $cl.Count | Should Be 1
    }

    It "[CLI] Should have an IP address of 192.168.3.100" {
        $i = Invoke-command -ScriptBlock { Get-NetIPAddress -interfacealias 'Ethernet' -AddressFamily IPv4} -session $cl
        $i.ipv4Address | should be '192.168.3.100'
    }

    $dns = Invoke-Command {Get-DnsClientServerAddress -InterfaceAlias ethernet -AddressFamily IPv4} -session $cl
    It "[CLI] Should have a DNS server configuration of 192.168.3.10" {
        $dns.ServerAddresses -contains '192.168.3.10' | Should Be "True"
    }

} #client

$all | Remove-PSSession
