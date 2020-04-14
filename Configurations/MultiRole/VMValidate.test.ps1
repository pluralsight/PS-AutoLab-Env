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

    Try {
        $dc = New-PSSession -VMName DC1 -Credential $cred -ErrorAction Stop
        $all += $dc

        #set error action preference to suppress all error messsage
        if ($dc) {
            Invoke-Command { $errorActionPreference = 'silentlyContinue'} -session $dc
        }

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
            $r = Invoke-Command { Try {Get-ADDomain -ErrorAction stop} catch {} } -session $dc
            $r.name | Should Be $domain
        }

        $OUs = Invoke-Command { Try {Get-ADOrganizationalUnit -filter * -ErrorAction stop} Catch {}} -session $dc
        $needed = 'IT', 'Dev', 'Marketing', 'Sales', 'Accounting', 'JEA_Operators'
        foreach ($item in $needed) {
            It "[DC1] Should have organizational unit $item" {
                $OUs.name -contains $item | Should Be "True"
            }
        }
        $groups = Invoke-Command { Try {Get-ADGroup -filter * -ErrorAction Stop} Catch {}} -session $DC
        $target = "IT", "Sales", "Marketing", "Accounting", "JEA Operators"
        foreach ($item in $target) {

            It "[DC1] Should have a group called $item" {
                $groups.Name -contains $item | Should Be "True"
            }
        }

        $users = Invoke-Command { Try {Get-ADUser -filter * -ErrorAction stop} Catch {}} -session $dc
        It "[DC1] Should have at least 15 user accounts" {
            $users.count | Should BeGreaterThan 15
        }

        $computer = Invoke-Command { Try {Get-ADComputer -filter * -ErrorAction Stop} Catch {}} -session $dc
        It "[DC1] Should have a computer account for Client" {
            $computer.name -contains "cli1" | Should Be "True"
        }

        It "[DC1] Should have a computer account for S1" {
            $computer.name -contains "S1" | Should Be "True"
        }
    }
    Catch {
        It "[DC1] Should allow a PSSession" {
            $false | Should Be $True
        }
    }

} #DC

Describe S1 {
    Try {
        $s1 = New-PSSession -VMName S1 -Credential $cred -ErrorAction Stop
        $all += $s1
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
        It "[S1] Should allow a PSSession" {
            $false | Should Be $True
        }
    }

} #S1


Describe N1 {

    Try {
        $N1 = New-PSSession -VMName N1 -Credential $Cred -ErrorAction Stop
        $all += $n1

        It "[N1] Should respond to WSMan requests" {
            $N1.Computername | Should Be 'N1'
        }

        It "[N1] Should have an IP address of 192.168.3.60" {
            $r = Invoke-Command { Get-NetIPAddress -InterfaceAlias Ethernet -AddressFamily IPv4} -session $N1
            $r.IPv4Address | Should Be '192.168.3.60'
        }

        It "[N1] Should belong to the Workgroup domain" {
            $sys = Invoke-Command { Get-CimInstance Win32_computersystem} -session $N1
            $sys.Domain | Should Be "Workgroup"
        }

        Context "DSC" {
            $pkg = Invoke-Command {(Get-WindowsPackage -online -PackageName *Nanoserver* | Where-Object packageState -eq 'installed').packagename} -session $N1

            It "[N1] Should have DSC Nano packages installed" {

                ($pkg -match "NanoServer-DSC").Count | Should Be 2
            }
            It "[N1] Should have Guest Nano packages installed" {
                ($pkg -match "NanoServer-Guest").Count | Should Be 2
            }
        } #context
    }
    Catch {
        It "[N1] Should allow a PSSession" {
            $false | Should Be $True
        }
        It "[N1] Will fail with error: $($_.exception.message)" {
            $true | should be $True
        }
    }
}

Describe Cli1 {

    Try {
        $cl = New-PSSession -VMName cli1 -Credential $cred -ErrorAction stop
        $all += $cl
        It "[CLI1] Should accept domain admin credential" {
            $cl.Count | Should Be 1
        }

        It "[CLI1] Should have an IP address of 192.168.3.100" {
            $i = Invoke-Command -ScriptBlock { Get-NetIPAddress -interfacealias 'Ethernet' -AddressFamily IPv4} -session $cl
            $i.ipv4Address | Should be '192.168.3.100'
        }

        $dns = Invoke-Command {Get-DnsClientServerAddress -InterfaceAlias ethernet -AddressFamily IPv4} -session $cl
        It "[CLI1] Should have a DNS server configuration of 192.168.3.10" {
            $dns.ServerAddresses -contains '192.168.3.10' | Should Be "True"
        }

        It "[CLI1] Should have RSAT installed" {
            $pkg = Invoke-Command {Get-WindowsCapability -online -name *rsat*} -session $cl

            # write-host ($pkg | Select-object Name,Displayname,State | format-list | Out-String) -ForegroundColor cyan
            $pkg | Where-Object { $_.state -ne "installed"} | Should be $Null

        }
    }
    Catch {
        It "[CLI1] Should allow a PSSession" {
            $false | Should Be $True
        }
    }

} #client

$all | Remove-PSSession
