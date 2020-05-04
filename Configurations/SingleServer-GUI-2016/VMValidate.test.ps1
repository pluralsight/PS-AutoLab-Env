#requires -version 5.1

#test if VM setup is complete

$LabData = Import-PowerShellDataFile -Path $PSScriptRoot\*.psd1
$Secure = ConvertTo-SecureString -String "$($labdata.allnodes.labpassword)" -AsPlainText -Force
$Domain = "S1"
$cred = New-Object PSCredential "$Domain\Administrator", $Secure

#The prefix only changes the name of the VM not the guest computername
$prefix = $Labdata.NonNodeData.Lability.EnvironmentPrefix
$VMName = "$($prefix)S1"

#set error action preference to suppress all error messsages which would be normal while configurations are converging
#turn off progress bars
$prep = {
    $ProgressPreference = "SilentlyContinue"
    $errorActionPreference = 'silentlyContinue'
}

Describe S1 {

    Try {
        $S1 = New-PSSession -VMName $VMName -Credential $cred -ErrorAction Stop
        Invoke-Command $prep -session $s1

        It "[S1] Should accept admin credential" {
            $s1.Count | Should Be 1
        }

        It "[S1] Should belong to a Workgroup" {
            $sys = Invoke-Command { Get-CimInstance Win32_computersystem} -session $S1
            $sys.Domain | Should Be "Workgroup"
        }

        It "[S1] Should be running Windows Server 2016" {
            $test = Invoke-Command {Get-CimInstance -ClassName win32_operatingsystem -property caption} -session $S1
            $test.caption | Should BeLike '*2016*'
        }

        It "[S1] Should be running Server (desktop experience)" {
            Invoke-Command {Get-ItemPropertyValue -path 'HKLM:\SOFTWARE\Microsoft\windows nt\currentversion' -name installationtype} -session $s1 | Should Be "Server"
        }

        It "[S1] Should have an IP address of 192.168.3.75" {
            $i = Invoke-Command -ScriptBlock { Get-NetIPAddress -interfacealias 'Ethernet' -AddressFamily IPv4} -Session $S1
            $i.ipv4Address | Should be '192.168.3.75'
        }

        $dns = Invoke-Command {Get-DnsClientServerAddress -InterfaceAlias ethernet -AddressFamily IPv4} -session $s1
        It "[S1] Should have a DNS server configuration of 4.2.2.2" {
            $dns.ServerAddresses -contains '4.2.2.2' | Should Be "True"
        }

        It "[S1] Should have RDP enabled" {
            Invoke-Command {Test-NetConnection $env:computername -CommonTCPPort RDP -InformationLevel Quiet -WarningAction silentlycontinue
            } -session $s1 | Should Be "True"
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
        It "[S1] Will fail with error: $($_.exception.message)" {
            $true | Should be $True
        }
    }
} #S1

if ($s1) {
    $s1 | Remove-PSSession
}

