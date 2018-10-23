#requires -version 5.0

#test if VM setup is complete

#The password will be passed by the control script WaitforVM.ps1
#You can manually set it while developing this Pester test
$LabData = Import-PowerShellDataFile -Path .\VMConfigurationData.psd1
if (-Not $LabData) {
  Write-Warning "Failed to get lab data."
  #bail out
  Return
}
$Secure = ConvertTo-SecureString -String $labdata.allnodes.labpassword -AsPlainText -Force 
$cred = New-Object -typename Pscredential -ArgumentList Administrator, $secure 
$Computername = $labdata.allnodes[1].nodename
$IP = $labdata.allnodes[1].IPAddress
$DNSAddress = $LabData.allnodes[0].DnsServerAddress

Describe $Computername {

$cl = New-PSSession -VMName $Computername -Credential $cred -ErrorAction SilentlyContinue

It "[$Computername] Should have an IP address of $IP" {
    $i = Invoke-command -ScriptBlock { Get-NetIPAddress -interfacealias 'Ethernet' -AddressFamily IPv4} -session $cl
    $i.ipv4Address | should be $IP
}

$dns = Invoke-Command {Get-DnsClientServerAddress -InterfaceAlias ethernet -AddressFamily IPv4} -session $cl
It "[$Computername] Should have a DNS server configuration of $DNSAddress" {                        
  $dns.ServerAddresses -contains $DNSAddress | Should Be "True"           
}

It "[$Computername] Should belong to the LAB Workgroup" {
   $wg = Invoke-Command {(Get-CimInstance -ClassName win32_computersystem)} -session $cl
   $wg.Workgroup | Should Be "Lab"
}


It "[$Computername] Should have 4 local user accounts" {
  $local = Invoke-Command {get-ciminstance -ClassName win32_useraccount} -session $cl
  $local.Count | Should be 4
  Write-Host ($local | Out-string) -ForegroundColor cyan
}

It "[$Computername] Should have 2 members in Administrators" {
  $admins = Invoke-Command {
    get-ciminstance -ClassName win32_group -filter "name='Administrators'" | Get-CimAssociatedInstance -ResultClassName win32_useraccount
} -session $cl
  $Admins.Count | Should be 2
  Write-Host ($admins | Out-string) -ForegroundColor cyan
}
It "[$Computername] Should have RSAT installed" {
   $pkg = Invoke-Command { Get-WindowsPackage -PackageName *RemoteServerAdministrationTools* -online} -session $cl
   
  write-host ($pkg | out-string) -ForegroundColor cyan
  $pkg.PackageState| should match "Install"
  
}

} #client

Get-PSSession | Remove-PSSession
