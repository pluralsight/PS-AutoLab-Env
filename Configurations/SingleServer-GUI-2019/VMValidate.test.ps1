#requires -version 5.1

#test if VM setup is complete

#The password will be passed by the control script WaitforVM.ps1
#You can manually set it while developing this Pester test
$LabData = Import-PowerShellDataFile -Path $PSScriptRoot\*.psd1
$Secure = ConvertTo-SecureString -String "$($LabData.AllNodes.LabPassword)" -AsPlainText -Force
$Domain = "S1"
$cred = New-Object PSCredential "$Domain\Administrator", $Secure

#The prefix only changes the name of the VM not the guest computername
$prefix = $LabData.NonNodeData.Lability.EnvironmentPrefix
$VMName = "$($prefix)S1"

#set error action preference to suppress all error messages which would be normal while configurations are converging
#turn off progress bars
$prep = {
    $ProgressPreference = "SilentlyContinue"
    $errorActionPreference = 'silentlyContinue'
}

Describe S1 {

    Try {
        $S1 = New-PSSession -VMName $VMName -Credential $Cred -ErrorAction Stop
        Invoke-Command $prep -session $s1

        It "[S1] Should accept administrator credential" {
            $s1.Count | Should Be 1
        }

        It "[S1] Should respond to WSMan requests" {
            $S1.Computername | Should Be $VMName
        }

        It "[S1] Should belong to a Workgroup" {
            $sys = Invoke-Command { Get-CimInstance Win32_computersystem} -session $S1
            $sys.Domain | Should Be "Workgroup"
        }

        $test = Invoke-Command { Get-CimInstance -ClassName win32_operatingsystem -property caption, csname } -session $s1
        It "[S1] Should be running Windows Server 2019" {
            $test.caption | Should BeLike '*2019*'
        }
        It "[S1] Should have a computername of $Domain" {
            $test.CSName | Should Be $Domain
        }
        It "[S1] Should be running Server (with desktop)" {
            Invoke-Command {Get-ItemPropertyValue -path 'HKLM:\SOFTWARE\Microsoft\windows nt\currentversion' -name installationtype} -session $s1 | Should Be "Server"
        }
        It "[S1] Should have an IP address of 192.168.3.19" {
            $i = Invoke-Command -ScriptBlock { Get-NetIPAddress -InterfaceAlias 'Ethernet' -AddressFamily IPv4} -Session $S1
            $i.ipv4Address | Should be '192.168.3.19'
        }

        $dns = Invoke-Command {Get-DnsClientServerAddress -InterfaceAlias ethernet -AddressFamily IPv4} -session $s1
        It "[S1] Should have a DNS server configuration of 1.1.1.1" {
            $dns.ServerAddresses -contains '1.1.1.1' | Should Be "True"
        }

        It "[S1] Should be able to resolve an Internet address" {
            $r = Invoke-Command { Resolve-DnsName www.pluralsight.com -type A | Select-Object -first 1} -session $S1
            $r.name | Should Be "www.pluralsight.com"
        }

        It "[S1] Should not have PowerShell 2 installed" {
            Invoke-Command { (Get-WindowsFeature -name 'PowerShell-V2').Installed} -session $s1 | Should be $False
        }
    }
    catch {
        It "[S1] Should allow a PSSession but got error: $($_.exception.message)" {
            $false | Should Be $True
        }
    }
} #S1


if ($s1) {
    $s1 | Remove-PSSession
}
