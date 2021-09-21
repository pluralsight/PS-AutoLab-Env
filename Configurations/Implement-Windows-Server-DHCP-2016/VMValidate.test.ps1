#requires -version 5.1

#test if VM setup is complete

#The password will be passed by the control script WaitforVM.ps1
#You can manually set it while developing this Pester test
$LabData = Import-PowerShellDataFile -Path $PSScriptRoot\VMConfigurationData.psd1
$Secure = ConvertTo-SecureString -String "$($labdata.allnodes.labpassword)" -AsPlainText -Force
$Domain = "company"
$cred = New-Object PSCredential "Company\Administrator", $Secure

#The prefix only changes the name of the VM not the guest computername
$prefix = $Labdata.NonNodeData.Lability.EnvironmentPrefix

$all = @()

Describe DC1 {

    $VMName = "$($prefix)DC1"
    Try {
        $dc = New-PSSession -VMName $VMName -Credential $cred -ErrorAction Stop
        $all += $dc

        #set error action preference to suppress all error messsages
        Invoke-Command { $errorActionPreference = 'silentlyContinue'} -session $dc

        It "[DC1] Should accept domain admin credential" {
            $dc.Count | Should Be 1
        }

        #test for features
        $feat = Invoke-Command { Get-WindowsFeature | Where-Object installed} -session $dc
        $needed = 'AD-Domain-Services', 'DNS', 'RSAT-AD-Tools',
        'RSAT-AD-PowerShell'
        foreach ($item in $needed) {
            It "[DC1] Should have feature $item installed" {
                $feat.Name -contains $item | Should Be "True"
            }
        }

        It "[DC1] Should have an IP address of 192.168.3.10" {
            $i = Invoke-Command -ScriptBlock { Get-NetIPAddress -interfacealias 'Ethernet' -AddressFamily IPv4} -Session $dc
            $i.ipv4Address | Should be '192.168.3.10'
        }

        It "[DC1] Should have a domain name of $domain" {
            $r = Invoke-Command {
                Try {
                    Get-ADDomain -ErrorAction Stop
                }
                Catch {
                    #ignore the error - Domain still spinning up
                }
            } -session $dc
            $r.name | Should Be $domain
        }

        $OUs = Invoke-Command {
            Try {
                Get-ADOrganizationalUnit -filter * -ErrorAction Stop
            }
            Catch {
                #ignore the error - Domain still spinning up
            }
        } -session $dc

        $needed = 'IT', 'Dev', 'Marketing', 'Sales', 'Accounting', 'JEA_Operators'
        foreach ($item in $needed) {
            It "[DC1] Should have organizational unit $item" {
                $OUs.name -contains $item | Should Be "True"
            }
        }

        $groups = Invoke-Command {
            Try {
                Get-ADGroup -filter * -ErrorAction Stop
            }
            Catch {
                #ignore the error - Domain still spinning up
            }
        } -session $DC

        $target = "IT", "Sales", "Marketing", "Accounting", "JEA Operators"
        foreach ($item in $target) {

            It "[DC1] Should have a group called $item" {
                $groups.Name -contains $item | Should Be "True"
            }
        }

        $users = Invoke-Command {
            Try {
                Get-ADUser -filter * -ErrorAction Stop
            }
            Catch {
                #ignore the error - Domain still spinning up
            }
        } -session $dc

        It "[DC1] Should have at least 15 user accounts" {
            $users.count | Should BeGreaterThan 15
        }

        $computer = Invoke-Command {
            Try {
                Get-ADComputer -filter * -ErrorAction SilentlyContinue
            }
            Catch {
                #ignore the error - Domain still spinning up
            }
        } -session $dc

        It "[DC1] Should have a computer account for Cli1" {
            $computer.name -contains "cli1" | Should Be "True"
        }

        It "[DC1] Should have a computer account for Cli2" {
            $computer.name -contains "cli2" | Should Be "True"
        }
        It "[DC1] Should have a computer account for S1" {
            $computer.name -contains "S1" | Should Be "True"
        }
    }
    Catch {
        It "[DC1] Should allow a PSSession but got error: $($_.exception.message)" {
            $false | Should Be $True
        }
    }
} #DC

Describe S1 {

    $VMName = "$($prefix)S1"
    Try {

        $s1 = New-PSSession -VMName $VMName -Credential $cred -ErrorAction Stop
        $all += $s1

        #set error action preference to suppress all error messsages
        Invoke-Command { $errorActionPreference = 'silentlyContinue'} -session $s1

        It "[S1] Should accept domain admin credential" {
            $s1.Count | Should Be 1
        }

        It "[S1] Should have an IP address of 192.168.3.50" {
            $i = Invoke-Command -ScriptBlock { Get-NetIPAddress -interfacealias 'Ethernet' -AddressFamily IPv4} -Session $S1
            $i.ipv4Address | Should be '192.168.3.50'
        }
        $dns = Invoke-Command {Get-DnsClientServerAddress -InterfaceAlias ethernet -AddressFamily IPv4} -session $s1
        It "[S1] Should have a DNS server configuration of 192.168.3.10" {
            $dns.ServerAddresses -contains '192.168.3.10' | Should Be "True"
        }
    }
    Catch {
        It "[S1] Should allow a PSSession but got error: $($_.exception.message)" {
            $false | Should Be $True
        }
    }
} #S1

Describe Cli1 {

    $VMName = "$($prefix)Cli1"
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
        $all += $cl

        #set error action preference to suppress all error messsages
        Invoke-Command { $errorActionPreference = 'silentlyContinue'} -session $cl

        It "[CLI1]] Should accept domain admin credential" {
            $cl.Count | Should Be 1
        }

        It "[CLI1]] Should have an IP address of 192.168.3.100" {
            $i = Invoke-Command -ScriptBlock { Get-NetIPAddress -interfacealias 'Ethernet' -AddressFamily IPv4} -session $cl
            $i.ipv4Address | Should be '192.168.3.100'
        }

        $pkg = Invoke-Command { $using:rsat | foreach-object {Get-WindowsCapability -Online -Name $_}} -Session $cl
        $rsatstatus = "{0}/{1}" -f ($pkg.where({$_.state -eq "installed"}).Name).count,$rsat.count
        It "[Cli1] Should have RSAT installed [$rsatStatus]" {
            # write-host ($pkg | Select-object Name,Displayname,State | format-list | Out-String) -ForegroundColor cyan
            $pkg | Where-Object { $_.state -ne "installed" } | Should be $Null
        }

        $dns = Invoke-Command {Get-DnsClientServerAddress -InterfaceAlias ethernet -AddressFamily IPv4} -session $cl
        It "[CLI1]] Should have a DNS server configuration of 192.168.3.10" {
            $dns.ServerAddresses -contains '192.168.3.10' | Should Be "True"
        }
    }
    Catch {
        It "[CLI1] Should allow a PSSession but got error: $($_.exception.message)" {
            $false | Should Be $True
        }
    }
} #cli1

Describe Cli2 {

    $VMName = "$($prefix)Cli2"

    Try {

        $cl2 = New-PSSession -VMName $VMName -Credential $cred -ErrorAction Stop
        $all += $cl2

        #set error action preference to suppress all error messsages
        Invoke-Command { $errorActionPreference = 'silentlyContinue'} -session $cl2
        It "[CLI2] Should accept domain admin credential" {
            $cl2.Count | Should Be 1
        }

        It "[CLI2] Should have an IP address of 192.168.3.101" {
            $i = Invoke-Command -ScriptBlock { Get-NetIPAddress -interfacealias 'Ethernet' -AddressFamily IPv4} -session $cl2
            $i.ipv4Address | Should be '192.168.3.101'
        }

        $dns = Invoke-Command {Get-DnsClientServerAddress -InterfaceAlias ethernet -AddressFamily IPv4} -session $cl2
        It "[CLI2] Should have a DNS server configuration of 192.168.3.101" {
            $dns.ServerAddresses -contains '192.168.3.10' | Should Be "True"
        }
    }
    Catch {
        It "[CLI2] Should allow a PSSession but got error: $($_.exception.message)" {
            $false | Should Be $True
        }
    }
} #cli2

$all | Remove-PSSession
