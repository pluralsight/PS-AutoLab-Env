#requires -version 5.0

#test if VM setup is complete


#The password will be passed by the control script WaitforVM.ps1
#You can manually set it while developing this Pester test
$LabData = Import-PowerShellDataFile -Path .\*.psd1
$Secure = ConvertTo-SecureString -String "$($labdata.allnodes.labpassword)" -AsPlainText -Force
$Domain = "company"
$cred = New-Object PSCredential "Company\Administrator", $Secure

$all = @()
Describe DC1 {

    $dc = New-PSSession -VMName DC1 -Credential $cred -ErrorAction SilentlyContinue
    $all+=$dc

    #set error action preference to suppress all error messsage
    if ($dc) {
        Invoke-Command { $errorActionPreference = 'silentlyContinue'} -session $dc
    }


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


} #DC

Describe S1 {
    $s1 = New-PSSession -VMName S1 -Credential $cred -ErrorAction SilentlyContinue
    $all+=$s1
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


Describe N1 {

    $N1 = New-PSSession -VMName N1 -Credential $Cred -ErrorAction Stop
   $all+=$n1
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

    $pkg = Invoke-Command {(get-WindowsPackage -online -PackageName *Nanoserver* | Where-object packageState -eq 'installed').packagename} -session $N1

    It "[N1] Should have DSC Nano packages installed" {
        ($pkg -match "NanoServer-DSC").Count | Should Be 2
    }
    It "[N1] Should have Guest Nano packages installed" {
        ($pkg -match "NanoServer-Guest").Count | Should Be 2
    }
}

Describe Cli1 {

    $cl = New-PSSession -VMName cli1 -Credential $cred -ErrorAction SilentlyContinue
    $all+=$cl
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

    It "[CLI] Should have RSAT installed" {
        $pkg = Invoke-Command {Get-WindowsCapability -online -name *rsat*} -session $cl

        # write-host ($pkg | Select-object Name,Displayname,State | format-list | Out-String) -ForegroundColor cyan
        $pkg.State| should match "Installed"

    }

} #client

$all | Remove-PSSession
