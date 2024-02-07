#requires -version 5.1

#test if VM setup is complete

BeforeDiscovery {
    #Write-Host "Pester Test development v2.0.0" -ForegroundColor Yellow
    $LabData = Import-PowerShellDataFile -Path $PSScriptRoot\VMConfigurationData.psd1
    $Domain = $LabData.AllNodes.DomainName
    $Secure = ConvertTo-SecureString -String "$($LabData.AllNodes.LabPassword)" -AsPlainText -Force
    $cred = New-Object PSCredential "$Domain\Administrator", $Secure
    $cl = New-PSSession -VMName Cli1 -Credential $Cred -ErrorAction Stop
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

Describe DC1 {
    BeforeAll {
        Try {
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
            $installType = Invoke-Command { Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\windows nt\currentversion' -Name InstallationType } -Session $VMSess
            $if = Invoke-Command -Scriptblock { Get-NetIPAddress -InterfaceAlias 'Ethernet' -AddressFamily IPv4 } -Session $VMSess
            $resolve = Invoke-Command { Resolve-DnsName www.pluralsight.com -Type A | Select-Object -First 1 } -Session $VMSess
            $rdpTest = Invoke-Command { Get-ItemPropertyValue -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\' -Name fDenyTSConnections } -Session $VMSess
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
        }
        catch {
            <#     It "[$Node] Should allow a PSSession but got error: $($_.exception.message)" {
                $false | Should -Be $True
            } #>
        }
    }
    AfterAll {
        if ($VMSess) {
            $VMSess | Remove-PSSession
        }
    }

    It '[DC1] Should be running Windows Server 2019' {
        $os.caption | Should -BeLike '*2019*'
    }
    It '[DC1] Should be running Server (with desktop)' {
        $installType | Should -Be 'Server'
    }
    It '[DC1] Should have feature <_> installed' -ForEach @('AD-Domain-Services', 'DNS', 'RSAT-AD-Tools',
        'RSAT-AD-PowerShell') {
        $feat.Name -contains $_ | Should -Be $True
    }
    It '[DC1] Should have an IP address of 192.168.3.10' {
        $if.ipv4Address | Should -Be '192.168.3.10'
    }
    It '[DC1] Should have RDP for admin access enabled' {
        $rdpTest | Should -Be 0
    }
    Context ActiveDirectory {

        It "[DC1] Should have a domain name of $domain" {
            $ADDomain.DNSRoot | Should -Be $domain
        }
        It '[DC1] Should have organizational unit <_>' -ForEach @('IT', 'Dev', 'Marketing', 'Sales', 'Accounting', 'JEA_Operators', 'Servers') {
            $OUs.name -contains $_ | Should -Be $True
        }
        It '[DC1] Should have a group called <_>' -ForEach @('IT', 'Sales', 'Marketing', 'Accounting', 'JEA Operators') {
            $groups.Name -contains $_ | Should -Be $True
        }
        It '[DC1] Should have at least 15 user accounts' {
            $users.count | Should -BeGreaterThan 15
        }
        It '[DC1] Should have a computer account for Cli1' {
            $computer.name -contains 'Cli1' | Should -Be $True
        }
        It '[DC1] Should have a computer account for S1' {
            $computer.name -contains 'S1' | Should -Be $True
        }
    }

    Context DNS {
        It '[DC1] Should Be able to resolve an internet address' {
            $resolve.name | Should -Be 'www.pluralsight.com'
        }
        It '[DC1] Should have a DNS server configuration of 192.168.3.10' {
            $dns.ServerAddresses -contains '192.168.3.10' | Should -Be $True
        }
    }

} #DC

Describe S1 {

    BeforeAll {
        Try {
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
            $installType = Invoke-Command { Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\windows nt\currentversion' -Name InstallationType } -Session $VMSess
            $rdpTest = Invoke-Command { Get-ItemPropertyValue -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\' -Name fDenyTSConnections } -Session $VMSess
        }
        catch {
            <#     It "[$Node] Should allow a PSSession but got error: $($_.exception.message)" {
                $false | Should -Be $True
            } #>
        }
    }
    AfterAll {
        if ($VMSess) {
            $VMSess | Remove-PSSession
        }
    }

    It '[S1] Should be running Windows Server 2019' {
        $os.caption | Should -BeLike '*2019*'
    }
    It '[S1] Should be running Server (with desktop)' {
        $installType | Should -Be 'Server'
    }
    It "[S1] Should Belong to the $domain domain" {
        $sys.domain | Should -Be $domain
    }

    It '[S1] Should have an IP address of 192.168.3.50' {
        $if.ipv4Address | Should -Be '192.168.3.50'
    }
    It '[S1] Should have a DNS server configuration of 192.168.3.10' {
        $dns.ServerAddresses -contains '192.168.3.10' | Should -Be $True
    }
    It '[S1] Should Be able to resolve an internet address' {
        $resolve.name | Should -Be 'www.pluralsight.com'
    }
    It '[S1] Should have RDP for admin access enabled' {
        $rdpTest | Should -Be 0
    }

} #S1


Describe Cli1  {

    BeforeAll {
        Try {
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
            $if = Invoke-Command -ScriptBlock { Get-NetIPAddress -InterfaceAlias 'Ethernet' -AddressFamily IPv4 } -Session $VMSess
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

        }
        catch {
            <#     It "[$Node] Should allow a PSSession but got error: $($_.exception.message)" {
                $false | Should -Be $True
            } #>
        }
    }
    AfterAll {
        if ($VMSess) {
            $VMSess | Remove-PSSession
        }
    }

    It "[Cli1] Should Belong to the $Domain domain" {
        $sys.domain | Should -Be $Domain
    }
    It '[Cli1] Should Be running Windows 10 Enterprise' {
        $OS.caption | Should -BeLike '*Enterprise*'
    }
    It '[CLI1] Should have an IP address of 192.168.3.100' {
        $if.ipv4Address | Should -Be '192.168.3.100'
    }

    It '[CLI1] Should have a DNS server configuration of 192.168.3.10' {
        $dns.ServerAddresses -contains '192.168.3.10' | Should -Be $True
    }

    It '[Cli1] Should have RDP for admin access enabled' {
        $rdpTest | Should -Be 0
    }
    It '[Cli1] Should Be able to resolve an internet address' {
        $resolve.name | Should -Be 'www.pluralsight.com'
    }
    It "[Cli1] Should have RSAT installed [$rsatStatus]" {
        $pkg2 | Where-Object { $_.state -ne 'installed' } | Should -Be $Null
    }


} #client


