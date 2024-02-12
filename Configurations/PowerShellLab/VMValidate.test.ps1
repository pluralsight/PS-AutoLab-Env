#requires -version 5.1

#test if VM setup is complete

#set error action preference to suppress all error messages which would be normal while configurations are converging

BeforeDiscovery {
    #Write-Host "Pester Test development v2.0.0" -ForegroundColor Yellow
    $LabData = Import-PowerShellDataFile -Path $PSScriptRoot\VMConfigurationData.psd1
    $Domain = $LabData.AllNodes.DomainName
    $Secure = ConvertTo-SecureString -String "$($LabData.AllNodes.LabPassword)" -AsPlainText -Force
    $cred = New-Object PSCredential "$Domain\Administrator", $Secure
    $cl = New-PSSession -VMName WIN10 -Credential $Cred -ErrorAction Stop
    $FireWallRules = $LabData.AllNodes.FirewallRuleNames
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

    if ($cl) {
        $cl | Remove-PSSession
    }
}

Describe DOM1 {
    BeforeAll {
        $LabData = Import-PowerShellDataFile -Path $PSScriptRoot\*.psd1
        $Secure = ConvertTo-SecureString -String "$($LabData.AllNodes.LabPassword)" -AsPlainText -Force
        $Computername = $LabData.AllNodes[1].NodeName
        $Domain = $LabData.AllNodes.DomainName
        $cred = New-Object PSCredential "$Domain\Administrator", $Secure

        #The prefix only changes the name of the VM not the guest computername
        $prefix = $LabData.NonNodeData.Lability.EnvironmentPrefix
        $VMName = "$($prefix)$Computername"

        #set error action preference to suppress all error messages which would be normal while configurations are converging
        #turn off progress bars
        $prep = {
            $ProgressPreference = 'SilentlyContinue'
            $errorActionPreference = 'SilentlyContinue'
        }

        $VMSess = New-PSSession -VMName $VMName -Credential $Cred -ErrorAction Stop
        Invoke-Command $prep -Session $VMSess

        $OS = Invoke-Command { Get-CimInstance -ClassName win32_OperatingSystem -Property caption, csname } -Session $VMSess
        $dns = Invoke-Command { Get-DnsClientServerAddress -InterfaceAlias ethernet -AddressFamily IPv4 } -Session $VMSess
        $sys = Invoke-Command { Get-CimInstance Win32_ComputerSystem } -Session $VMSess
        $if = Invoke-Command -Scriptblock { Get-NetIPAddress -InterfaceAlias 'Ethernet' -AddressFamily IPv4 } -Session $VMSess
        $resolve = Invoke-Command { Resolve-DnsName www.pluralsight.com -Type A | Select-Object -First 1 } -Session $VMSess
        $PS2Test = Invoke-Command { (Get-WindowsFeature -Name 'PowerShell-V2').Installed } -Session $VMSess
        $rec = Invoke-Command { Resolve-DnsName Srv3.company.pri } -Session $VMSess
        $computer = Invoke-Command {
            Try {
                Get-ADComputer -Filter * -ErrorAction SilentlyContinue
            }
            Catch {
                #ignore the error - Domain still spinning up
            }
        } -Session $VMSess
        $users = Invoke-Command {
            Try {
                Get-ADUser -Filter * -ErrorAction Stop
            }
            Catch {
                #ignore the error - Domain still spinning up
            }
        } -Session $VMSess
        $groups = Invoke-Command {
            Try {
                Get-ADGroup -Filter * -ErrorAction Stop
            }
            Catch {
                #ignore the error - Domain still spinning up
            }
        } -Session $VMSess
        $ADDomain = Invoke-Command {
            Try {
                Get-ADDomain -ErrorAction Stop
            }
            Catch {
                #ignore the error - Domain still spinning up
            }
        } -Session $VMSess
        $OUs = Invoke-Command {
            Try {
                Get-ADOrganizationalUnit -Filter * -ErrorAction Stop
            }
            Catch {
                #ignore the error - Domain still spinning up
            }
        } -Session $VMSess
        $admins = Invoke-Command { Get-ADGroupMember 'Domain Admins'-ErrorAction SilentlyContinue } -Session $VMSess
        $feat = Invoke-Command { Get-WindowsFeature | Where-Object installed } -Session $VMSess
        $rdpTest = Invoke-Command { Get-ItemPropertyValue -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\' -Name fDenyTSConnections } -Session $VMSess
        $FireWallRules = $LabData.AllNodes.FirewallRuleNames
        $fw = Invoke-Command { Get-NetFirewallRule -Name $using:FireWallRules } -Session $VMSess |
        ForEach-Object -Begin { $tmp = @{} } -Process { $tmp.Add($_.Name, $_.Enabled) } -End { $tmp }
    }
    AfterAll {
        if ($VMSess) {
            $VMSess | Remove-PSSession
        }
    }

    It '[DOM1] Should Be running Windows Server 2019' {
        $OS.caption | Should -BeLike '*2019*'
    }
    It '[DOM1] Should have feature <_> installed' -ForEach @('AD-Domain-Services', 'DNS', 'RSAT-AD-Tools',
        'RSAT-AD-PowerShell') {
        $feat.Name -contains $_ | Should -Be $True
    }
    It '[DOM1] Should have an IP address of 192.168.3.10' {
        $if.ipv4Address | Should -Be '192.168.3.10'
    }
    It "[DOM1] Should Belong to the $domain domain" {
        $sys.domain | Should -Be $domain
    }
    It '[DOM1] Should have RDP for admin access enabled' {
        $rdpTest | Should -Be 0
    }
    It '[DOM1] Should have firewall rule <_> enabled' -ForEach $FireWallRules {
        $fw[$_] | Should -Be $True
    }

    Context ActiveDirectory {

        It "[DOM1] Should have a domain name of $domain" {
            $ADDomain.DNSRoot | Should -Be $domain
        }
        It '[DOM1] Should have organizational unit <_>' -ForEach @('IT', 'Dev', 'Marketing', 'Sales', 'Accounting', 'JEA_Operators', 'Servers') {
            $OUs.name -contains $_ | Should -Be $True
        }
        It '[DOM1] Should have a group called <_>' -ForEach @('IT', 'Sales', 'Marketing', 'Accounting', 'JEA Operators') {
            $groups.Name -contains $_ | Should -Be $True
        }
        It '[DOM1] Should have at least 15 user accounts' {
            $users.count | Should -BeGreaterThan 15
        }
        It '[DOM1] ArtD is a member of Domain Admins' {
            $admins.name -contains 'artd' | Should -Be $True
        }
        It '[DOM1] AprilS is a member of Domain Admins' {
            $admins.name -contains 'aprils' | Should -Be $True
        }
        It '[DOM1] Should have a computer account for WIN10' {
            $computer.name -contains 'Win10' | Should -Be $True
        }
        It '[DOM1] Should have a computer account for SRV1' {
            $computer.name -contains 'SRV1' | Should -Be $True
        }
        It '[DOM1] Should have a computer account for SRV2' {
            $computer.name -contains 'SRV2' | Should -Be $True
        }
    }

    Context DNS {
        It '[DOM1] Should have a DNS record for SRV3.COMPANY.PRI' {
            $rec.Name | Should -Be 'srv3.company.pri'
            $rec.IPAddress | Should -Be '192.168.3.60'
        }
        It '[DOM1] Should Be able to resolve an internet address' {
            $resolve.name | Should -Be 'www.pluralsight.com'
        }
        It '[DOM1] Should have a DNS server configuration of 192.168.3.10' {
            $dns.ServerAddresses -contains '192.168.3.10' | Should -Be $True
        }
    }

} #DOM1

Describe SRV1 {
    BeforeAll {
        $LabData = Import-PowerShellDataFile -Path $PSScriptRoot\*.psd1
        $Secure = ConvertTo-SecureString -String "$($LabData.AllNodes.LabPassword)" -AsPlainText -Force
        $Computername = $LabData.AllNodes[2].NodeName
        $Domain = $LabData.AllNodes.DomainName
        $cred = New-Object PSCredential "$Domain\Administrator", $Secure

        #The prefix only changes the name of the VM not the guest computername
        $prefix = $LabData.NonNodeData.Lability.EnvironmentPrefix
        $VMName = "$($prefix)$Computername"

        #set error action preference to suppress all error messages which would be normal while configurations are converging
        #turn off progress bars
        $prep = {
            $ProgressPreference = 'SilentlyContinue'
            $errorActionPreference = 'SilentlyContinue'
        }

        $VMSess = New-PSSession -VMName $VMName -Credential $Cred -ErrorAction Stop
        Invoke-Command $prep -Session $VMSess

        $OS = Invoke-Command { Get-CimInstance -ClassName win32_OperatingSystem -Property caption, csname } -Session $VMSess
        $dns = Invoke-Command { Get-DnsClientServerAddress -InterfaceAlias ethernet -AddressFamily IPv4 } -Session $VMSess
        $sys = Invoke-Command { Get-CimInstance Win32_ComputerSystem } -Session $VMSess
        $if = Invoke-Command -Scriptblock { Get-NetIPAddress -InterfaceAlias 'Ethernet' -AddressFamily IPv4 } -Session $VMSess
        $resolve = Invoke-Command { Resolve-DnsName www.pluralsight.com -Type A | Select-Object -First 1 } -Session $VMSess
        #$feat = Invoke-Command { Get-WindowsFeature | Where-Object installed } -Session $VMSess
        $rdpTest = Invoke-Command { Get-ItemPropertyValue -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\' -Name fDenyTSConnections } -Session $VMSess
        $FireWallRules = $LabData.AllNodes.FirewallRuleNames
        $fw = Invoke-Command { Get-NetFirewallRule -Name $using:FireWallRules } -Session $VMSess |
        ForEach-Object -Begin { $tmp = @{} } -Process { $tmp.Add($_.Name, $_.Enabled) } -End { $tmp }

    }
    AfterAll {
        if ($VMSess) {
            $VMSess | Remove-PSSession
        }
    }

    It "[SRV1] Should Belong to the $domain domain" {
        $sys.domain | Should -Be $domain
    }
    It '[SRV1] Should have an IP address of 192.168.3.50' {
        $if.ipv4Address | Should -Be '192.168.3.50'
    }
    It '[SRV1] Should have a DNS server configuration of 192.168.3.10' {
        $dns.ServerAddresses -contains '192.168.3.10' | Should -Be 'True'
    }
    It '[SRV1] Should have firewall rule <_> enabled' -ForEach $FireWallRules {
        $fw[$_] | Should -Be $True
    }
    It '[SRV1] Should Be running Windows Server 2019' {
        $OS.caption | Should -BeLike '*2019*'
    }
    It '[SRV1] Should have RDP for admin access enabled' {
        $rdpTest | Should -Be 0
    }
    It '[SRV1] Should Be able to resolve an internet address' {
        $resolve.name | Should -Be 'www.pluralsight.com'
    }
}

Describe SRV2 {
    BeforeAll {
        $LabData = Import-PowerShellDataFile -Path $PSScriptRoot\*.psd1
        $Secure = ConvertTo-SecureString -String "$($LabData.AllNodes.LabPassword)" -AsPlainText -Force
        $Computername = $LabData.AllNodes[3].NodeName
        $Domain = $LabData.AllNodes.DomainName
        $cred = New-Object PSCredential "$Domain\Administrator", $Secure

        #The prefix only changes the name of the VM not the guest computername
        $prefix = $LabData.NonNodeData.Lability.EnvironmentPrefix
        $VMName = "$($prefix)$Computername"

        #set error action preference to suppress all error messages which would be normal while configurations are converging
        #turn off progress bars
        $prep = {
            $ProgressPreference = 'SilentlyContinue'
            $errorActionPreference = 'SilentlyContinue'
        }

        $VMSess = New-PSSession -VMName $VMName -Credential $Cred -ErrorAction Stop
        Invoke-Command $prep -Session $VMSess

        $OS = Invoke-Command { Get-CimInstance -ClassName win32_OperatingSystem -Property caption, csname } -Session $VMSess
        $dns = Invoke-Command { Get-DnsClientServerAddress -InterfaceAlias ethernet -AddressFamily IPv4 } -Session $VMSess
        $sys = Invoke-Command { Get-CimInstance Win32_ComputerSystem } -Session $VMSess
        $if = Invoke-Command -Scriptblock { Get-NetIPAddress -InterfaceAlias 'Ethernet' -AddressFamily IPv4 } -Session $VMSess
        $resolve = Invoke-Command { Resolve-DnsName www.pluralsight.com -Type A | Select-Object -First 1 } -Session $VMSess
        $feature = Invoke-Command { Get-WindowsFeature -Name web-server } -Session $VMSess
        $file = Invoke-Command { Get-Item C:\MyWebServices\firstservice.asmx } -Session $VMSess
        $app = Invoke-Command { Try { Get-WebApplication -Name MyWebServices -ErrorAction stop } Catch {} } -Session $VMSess
        $rdpTest = Invoke-Command { Get-ItemPropertyValue -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\' -Name fDenyTSConnections } -Session $VMSess
        $FireWallRules = $LabData.AllNodes.FirewallRuleNames
        $fw = Invoke-Command { Get-NetFirewallRule -Name $using:FireWallRules } -Session $VMSess |
        ForEach-Object -Begin { $tmp = @{} } -Process { $tmp.Add($_.Name, $_.Enabled) } -End { $tmp }

    }
    AfterAll {
        if ($VMSess) {
            $VMSess | Remove-PSSession
        }
    }

    It "[SRV2] Should Belong to the $domain domain" {
        $sys.domain | Should -Be $domain
    }
    It '[SRV2] Should have an IP address of 192.168.3.51' {
        $if.ipv4Address | Should -Be '192.168.3.51'
    }
    It '[SRV2] Should have a DNS server configuration of 192.168.3.10' {
        $dns.ServerAddresses -contains '192.168.3.10' | Should -Be $True
    }
    It '[SRV2] Should have firewall rule <_> enabled' -ForEach $FireWallRules {
        $fw[$_] | Should -Be $True
    }
    It '[SRV2] Should Be running Windows Server 2019' {
        $OS.caption | Should -BeLike '*2019*'
    }
    It '[SRV2] Should have RDP for admin access enabled' {
        $rdpTest | Should -Be 0
    }
    It '[SRV2] Should Be able to resolve an internet address' {
        $resolve.name | Should -Be 'www.pluralsight.com'
    }

    Context Web {
        It '[SRV2] Should have the Web-Server feature installed' {
            $feature.Installed | Should -Be $True
        }
        It '[SRV2] Should have a sample web service file' {
            $file.name | Should -Be 'firstservice.asmx'
        }
        It '[SRV2] Should have a WebApplication called MyWebServices' {
            $app.path | Should -Be '/MyWebServices'
            $app.PhysicalPath | Should -Be 'c:\MyWebServices'
        }
    }
}

Describe SRV3 {
    #this is a workgroup server
    BeforeAll {
        $LabData = Import-PowerShellDataFile -Path $PSScriptRoot\*.psd1
        $Secure = ConvertTo-SecureString -String "$($LabData.AllNodes.LabPassword)" -AsPlainText -Force
        $Computername = $LabData.AllNodes[4].NodeName
        $Domain = $Computername
        $cred = New-Object PSCredential "$Domain\Administrator", $Secure

        #The prefix only changes the name of the VM not the guest computername
        $prefix = $LabData.NonNodeData.Lability.EnvironmentPrefix
        $VMName = "$($prefix)$Computername"

        #set error action preference to suppress all error messages which would be normal while configurations are converging
        #turn off progress bars
        $prep = {
            $ProgressPreference = 'SilentlyContinue'
            $errorActionPreference = 'SilentlyContinue'
        }

        $VMSess = New-PSSession -VMName $VMName -Credential $Cred -ErrorAction Stop
        Invoke-Command $prep -Session $VMSess

        $OS = Invoke-Command { Get-CimInstance -ClassName win32_OperatingSystem -Property caption, csname } -Session $VMSess
        $dns = Invoke-Command { Get-DnsClientServerAddress -InterfaceAlias ethernet -AddressFamily IPv4 } -Session $VMSess
        $sys = Invoke-Command { Get-CimInstance Win32_ComputerSystem } -Session $VMSess
        $if = Invoke-Command -Scriptblock { Get-NetIPAddress -InterfaceAlias 'Ethernet' -AddressFamily IPv4 } -Session $VMSess
        $resolve = Invoke-Command { Resolve-DnsName www.pluralsight.com -Type A | Select-Object -First 1 } -Session $VMSess
        $rdpTest = Invoke-Command { Get-ItemPropertyValue -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\' -Name fDenyTSConnections } -Session $VMSess
        $FireWallRules = $LabData.AllNodes.FirewallRuleNames
        $fw = Invoke-Command { Get-NetFirewallRule -Name $using:FireWallRules } -Session $VMSess |
        ForEach-Object -Begin { $tmp = @{} } -Process { $tmp.Add($_.Name, $_.Enabled) } -End { $tmp }
    }
    AfterAll {
        if ($VMSess) {
            $VMSess | Remove-PSSession
        }
    }

    It '[SRV3] Should have an IP address of 192.168.3.60' {
        $if.IPv4Address | Should -Be '192.168.3.60'
    }
    It '[SRV3] Should Belong to a Workgroup' {
        $sys.Domain | Should -Be 'Workgroup'
    }
    It '[SRV3] Should Be running Windows Server 2022' {
        $os.caption | Should -BeLike '*2022*'
    }
    It '[SRV3] Should have RDP for admin access enabled' {
        $rdpTest | Should -Be 0
    }
    It '[SRV3] Should have firewall rule <_> enabled' -ForEach $FireWallRules {
        $fw[$_] | Should -Be $True
    }
    It '[SRV3] Should have a DNS server configuration of 192.168.3.10' {
        $dns.ServerAddresses -contains '192.168.3.10' | Should -Be $True
    }
    It '[SRV3] Should Be able to resolve an internet address' {
        $resolve.name | Should -Be 'www.pluralsight.com'
    }
}

Describe Win10 {
    BeforeAll {
        $LabData = Import-PowerShellDataFile -Path $PSScriptRoot\*.psd1
        $Secure = ConvertTo-SecureString -String "$($LabData.AllNodes.LabPassword)" -AsPlainText -Force
        $Computername = $LabData.AllNodes[5].NodeName
        $Domain = $LabData.AllNodes.DomainName
        $cred = New-Object PSCredential "$Domain\Administrator", $Secure

        #The prefix only changes the name of the VM not the guest computername
        $prefix = $LabData.NonNodeData.Lability.EnvironmentPrefix
        $VMName = "$($prefix)$Computername"

        #set error action preference to suppress all error messages which would be normal while configurations are converging
        #turn off progress bars
        $prep = {
            $ProgressPreference = 'SilentlyContinue'
            $errorActionPreference = 'SilentlyContinue'
        }

        $VMSess = New-PSSession -VMName $VMName -Credential $Cred -ErrorAction Stop
        Invoke-Command $prep -Session $VMSess

        $OS = Invoke-Command { Get-CimInstance -ClassName win32_OperatingSystem -Property caption, csname } -Session $VMSess
        $dns = Invoke-Command { Get-DnsClientServerAddress -InterfaceAlias ethernet -AddressFamily IPv4 } -Session $VMSess
        $sys = Invoke-Command { Get-CimInstance Win32_ComputerSystem } -Session $VMSess
        $if = Invoke-Command -Scriptblock { Get-NetIPAddress -InterfaceAlias 'Ethernet' -AddressFamily IPv4 } -Session $VMSess
        $resolve = Invoke-Command { Resolve-DnsName www.pluralsight.com -Type A | Select-Object -First 1 } -Session $VMSess
        #$feat = Invoke-Command { Get-WindowsFeature | Where-Object installed } -Session $VMSess
        $rdpTest = Invoke-Command { Get-ItemPropertyValue -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\' -Name fDenyTSConnections } -Session $VMSess
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
        $pkg2 = Invoke-Command { $using:rsat | ForEach-Object { Get-WindowsCapability -Online -Name $_ } } -Session $cl
        $FireWallRules = $LabData.AllNodes.FirewallRuleNames
        $fw = Invoke-Command { Get-NetFirewallRule -Name $using:FireWallRules } -Session $VMSess |
        ForEach-Object -Begin { $tmp = @{} } -Process { $tmp.Add($_.Name, $_.Enabled) } -End { $tmp }
    }
    AfterAll {
        if ($VMSess) {
            $VMSess | Remove-PSSession
        }
    }

    It "[WIN10] Should Belong to the $Domain domain" {
        $sys.domain | Should -Be $Domain
    }
    It '[WIN10] Should Be running Windows 10 Enterprise' {
        $OS.caption | Should -BeLike '*Enterprise*'
    }
    It '[WIN10] Should have an IP address of 192.168.3.100' {
        $if.ipv4Address | Should -Be '192.168.3.100'
    }
    It '[WIN10] Should have firewall rule <_> enabled' -ForEach $FireWallRules {
        $fw[$_] | Should -Be $True
    }
    It '[WIN10] Should have a DNS server configuration of 192.168.3.10' {
        $dns.ServerAddresses -contains '192.168.3.10' | Should -Be $True
    }
    It '[WIN10] Should have RDP for admin access enabled' {
        $rdpTest | Should -Be 0
    }
    It '[WIN10] Should Be able to resolve an internet address' {
        $resolve.name | Should -Be 'www.pluralsight.com'
    }
    It "[WIN10] Should have RSAT installed [$rsatStatus]" {
        $pkg2 | Where-Object { $_.state -ne 'installed' } | Should -Be $Null
    }
}