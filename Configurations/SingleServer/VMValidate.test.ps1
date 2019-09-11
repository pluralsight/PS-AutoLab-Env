#requires -version 5.1

#test if VM setup is complete

$LabData = Import-PowerShellDataFile -Path .\*.psd1
$Secure = ConvertTo-SecureString -String "$($labdata.allnodes.labpassword)" -AsPlainText -Force
$wgcred = New-Object PSCredential  "administrator", $secure

#define an array to hold all of the PSSessions

Describe S1 {

    $S1 = New-PSSession -VMName S1 -Credential $wgCred -ErrorAction Stop


    It "[S1] Should respond to WSMan requests" {
        $S1.Computername | Should Be 'S1'
    }

    It "[S1] Should have an IP address of 192.168.3.19" {
        $r = Invoke-Command { Get-NetIPAddress -InterfaceAlias Ethernet -AddressFamily IPv4} -session $S1
        $r.IPv4Address | Should Be '192.168.3.19'
    }

    It "[S1] Should belong to the Workgroup domain" {
        $sys = Invoke-Command { Get-CimInstance Win32_computersystem} -session $S1
        $sys.Domain | Should Be "Workgroup"
    }

    It "[S1] Should be running Windows Server 2019" {
        $test = Invoke-Command {Get-Ciminstance -ClassName win32_operatingsystem -property caption} -session $S1
        $test.caption | Should BeLike '*2019*'
    }

    It "[S1] Should be able to resolve an Internet address" {
        $r = Invoke-Command { Resolve-DNSName www.pluralsight.com -type A | Select-object -first 1} -session $S1
        $r.name | Should Be "www.pluralsight.com"
    }

    It "[S1] Should pass Test-DSCConfiguration" {
        $t = Invoke-Command { Test-DscConfiguration } -session $S1
        $t | Should Be $True
    }
}

if ($s1) {
   $s1 | Remove-PSSession
}
