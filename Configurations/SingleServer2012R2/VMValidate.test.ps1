#requires -version 5.1

#test if VM setup is complete

$LabData = Import-PowerShellDataFile -Path $PSScriptRoot\*.psd1
$Secure = ConvertTo-SecureString -String "$($labdata.allnodes.labpassword)" -AsPlainText -Force
$computername = "S12R2"
$wgcred = New-Object PSCredential  "$computername\administrator", $secure

#set error action preference to suppress all error messsages which would be normal while configurations are converging
#turn off progress bars
$prep = {
    $ProgressPreference = "SilentlyContinue"
    $errorActionPreference = 'SilentlyContinue'
}

Describe $Computername {

    Try {
        #Windows Server 2012 R2 cannot use PowerShell Direct
        $S1 = New-PSSession -ComputerName $Computername -Credential $wgCred -ErrorAction Stop

        Invoke-Command $prep -session $s1

        It "[$Computername] Should respond to WSMan requests" {
            $S1.Computername | Should Be $Computername
        }

        $test = Invoke-Command { Get-CimInstance -ClassName win32_operatingsystem -property caption, csname } -session $s1
        It "[$Computername] Should be running Windows Server 2012 R2" {
            $test.caption | Should BeLike '*2012 R2*'
        }
        It "[$Computername] Should have a computername $computername" {
            $test.CSName | Should Be $computername
        }
        It "[$Computername] Should be running Server Core" {
            Invoke-Command {Get-ItemPropertyValue -path 'HKLM:\SOFTWARE\Microsoft\windows nt\currentversion' -name installationtype} -session $s1 | Should Be "Server Core"
        }
        It "[$Computername] Should have an IP address of 192.168.3.12" {
            $r = Invoke-Command { Get-NetIPAddress -InterfaceAlias Ethernet -AddressFamily IPv4} -session $S1
            $r.IPv4Address | Should Be '192.168.3.12'
        }
        It "[$Computername] Should belong to a Workgroup" {
            $sys = Invoke-Command { Get-CimInstance Win32_computersystem} -session $S1
            $sys.Domain | Should Be "Workgroup"
        }
        It "[$Computername] Should be able to resolve an Internet address" {
            $r = Invoke-Command { Resolve-DnsName www.pluralsight.com -type A | Select-Object -first 1} -session $S1
            $r.name | Should Be "www.pluralsight.com"
        }
        It "[$Computername] Should not have PowerShell 2 installed" {
            Invoke-Command { (Get-WindowsFeature -name 'PowerShell-V2').Installed} -session $s1 | Should be $False
        }
        It "[$Computername] Should pass Test-DSCConfiguration" {
            Invoke-Command { Test-DscConfiguration  -WarningAction SilentlyContinue} -session $S1 | Should be $True
        }
    }
    catch {
        It "[$Computername] Should allow a PSSession but got error: $($_.exception.message)" {
            $false | Should Be $True
        }
    }
}

if ($s1) {
    $s1 | Remove-PSSession
}
