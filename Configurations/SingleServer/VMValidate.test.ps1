#requires -version 5.1

#test if VM setup is complete

$LabData = Import-PowerShellDataFile -Path $PSScriptRoot\*.psd1
$Secure = ConvertTo-SecureString -String "$($labdata.allnodes.labpassword)" -AsPlainText -Force
$wgcred = New-Object PSCredential  "administrator", $secure

#set error action preference to suppress all error messsages which would be normal while configurations are converging
#turn off progress bars
$prep = {
    $ProgressPreference = "SilentlyContinue"
    $errorActionPreference = 'silentlyContinue'
}

Describe S1 {

    Try {
        $S1 = New-PSSession -VMName S1 -Credential $wgCred -ErrorAction Stop
        Invoke-Command $prep -session $s1

        It "[S1] Should respond to WSMan requests" {
            $S1.Computername | Should Be 'S1'
        }

        $test = Invoke-Command { Get-CimInstance -ClassName win32_operatingsystem -property caption, csname } -session $s1
        It "[S1] Should be running Windows Server 2019" {
            $test.caption | Should BeLike '*2019*'
        }
        It "[S1] Should have a computername S1" {
            $test.CSName | Should Be "S1"
        }
        It "[S1] Should be running Server Core" {
            Invoke-Command {Get-ItemPropertyValue -path 'HKLM:\SOFTWARE\Microsoft\windows nt\currentversion' -name installationtype} -session $s1 | Should Be "Server Core"
        }
        It "[S1] Should have an IP address of 192.168.3.19" {
            $r = Invoke-Command { Get-NetIPAddress -InterfaceAlias Ethernet -AddressFamily IPv4} -session $S1
            $r.IPv4Address | Should Be '192.168.3.19'
        }
        It "[S1] Should belong to a Workgroup" {
            $sys = Invoke-Command { Get-CimInstance Win32_computersystem} -session $S1
            $sys.Domain | Should Be "Workgroup"
        }
        It "[S1] Should be able to resolve an Internet address" {
            $r = Invoke-Command { Resolve-DnsName www.pluralsight.com -type A | Select-Object -first 1} -session $S1
            $r.name | Should Be "www.pluralsight.com"
        }
        It "[S1] Should not have PowerShell 2 installed" {
            Invoke-Command { (Get-WindowsFeature -name 'PowerShell-V2').Installed} -session $s1 | Should be $False
        }
        It "[S1] Should pass Test-DSCConfiguration" {
            Invoke-Command { Test-DscConfiguration  -WarningAction SilentlyContinue} -session $S1 | Should be $True
        }
    }
    catch {
        It "[S1] Should allow a PSSession" {
            $false | Should Be $True
        }
    }
}

if ($s1) {
    $s1 | Remove-PSSession
}
