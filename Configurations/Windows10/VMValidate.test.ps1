#requires -version 5.1

#test if VM setup is complete

# Uncomment the Write-Host lines for development and troubleshooting

$LabData = Import-PowerShellDataFile -Path $PSScriptRoot\VMConfigurationData.psd1
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

    try {
        $cl = New-PSSession -VMName $Computername -Credential $cred -ErrorAction Stop
    }
    Catch {
        Write-Warning "Failed to create PSSession to $Computername using credential for $($cred.UserName). $($_.exception.message)"
        #bail out
        Return
    }

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

    It "[$Computername] Should have a local admin account for $env:username" {
        $local = Invoke-Command {get-ciminstance -ClassName win32_useraccount -filter "Name='$using:env:username'"} -session $cl
        $local.Accounttype | Should be 512
        $local.Name | Should Be $env:username
        # Write-Host ($local | Out-string) -ForegroundColor cyan
    }

    It "[$Computername] Should have 2 members in Administrators" {
        $admins = Invoke-Command {
            get-ciminstance -ClassName win32_group -filter "name='Administrators'" | Get-CimAssociatedInstance -ResultClassName win32_useraccount
        } -session $cl
        $Admins.Count | Should be 2
        # Write-Host ($admins | Out-string) -ForegroundColor cyan
    }
    It "[$Computername] Should have RSAT installed" {
        $pkg = Invoke-Command { Get-WindowsPackage -PackageName *RemoteServerAdministrationTools* -online} -session $cl

        # write-host ($pkg | out-string) -ForegroundColor cyan
        $pkg.PackageState| should match "Install"

    }

} #client

if ($cl) {
  $cl | Remove-PSSession
}
