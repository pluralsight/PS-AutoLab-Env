#requires -version 5.1

#test if VM setup is complete


#The password will be passed by the control script WaitforVM.ps1
#You can manually set it while developing this Pester test
$LabData = Import-PowerShellDataFile -Path .\*.psd1
$Secure = ConvertTo-SecureString -String "$($labdata.allnodes.labpassword)" -AsPlainText -Force 
$Domain = "company"
$cred = New-Object PSCredential "Company\Administrator",$Secure

Describe DC1 {

$dc = New-PSSession -VMName DC1 -Credential $cred -ErrorAction SilentlyContinue
#set error action preference to suppress all error messsages
    Invoke-Command { $errorActionPreference = 'silentlyContinue'} -session $dc

It "[DC1] Should accept domain admin credential" {
    $dc.Count | Should Be 1
}

#test for features
$feat = Invoke-Command { Get-WindowsFeature | Where installed} -session $dc
$needed = 'AD-Domain-Services','DNS','RSAT-AD-Tools',
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
$needed = 'IT','Dev','Marketing','Sales','Accounting','JEA_Operators'
foreach ($item in $needed) {
    It "[DC1] Should have organizational unit $item" {
    $OUs.name -contains $item | Should Be "True"
    }
}
$groups = Invoke-Command { Get-ADGroup -filter * -ErrorAction SilentlyContinue} -session $DC
$target = "IT","Sales","Marketing","Accounting","JEA Operators"
foreach ($item in $target) {

 It "[DC1] Should have a group called $item" {
    $groups.Name -contains $item | Should Be "True"
 }

}

$users= Invoke-Command { Get-AdUser -filter * -ErrorAction SilentlyContinue} -session $dc
It "[DC1] Should have at least 15 user accounts" {
    $users.count | should BeGreaterThan 15
}

} #DC


Get-PSSession | Remove-PSSession
