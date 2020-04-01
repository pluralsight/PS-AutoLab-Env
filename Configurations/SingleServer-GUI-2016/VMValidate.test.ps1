#requires -version 5.1

#test if VM setup is complete

#The password will be passed by the control script WaitforVM.ps1
#You can manually set it while developing this Pester test
$LabData = Import-PowerShellDataFile -Path $PSScriptRoot\*.psd1
$Secure = ConvertTo-SecureString -String "$($labdata.allnodes.labpassword)" -AsPlainText -Force
$Domain = "S1"
$cred = New-Object PSCredential "$Domain\Administrator", $Secure

Describe S1 {
    $s1 = New-PSSession -VMName S1 -Credential $cred -ErrorAction SilentlyContinue
    It "[S1] Should accept admin credential" {
        $s1.Count | Should Be 1
    }

    It "[S1] Should have an IP address of 192.168.3.75" {
        $i = Invoke-Command -ScriptBlock { Get-NetIPAddress -interfacealias 'Ethernet' -AddressFamily IPv4} -Session $S1
        $i.ipv4Address | Should be '192.168.3.75'
    }
    $dns = Invoke-Command {Get-DnsClientServerAddress -InterfaceAlias ethernet -AddressFamily IPv4} -session $s1
    It "[S1] Should have a DNS server configuration of 4.2.2.2" {
        $dns.ServerAddresses -contains '4.2.2.2' | Should Be "True"
    }

} #S1


Get-PSSession | Remove-PSSession
