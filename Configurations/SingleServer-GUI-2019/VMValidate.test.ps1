#requires -version 5.1

#revised for Pester 5.x

#test if VM setup is complete
BeforeDiscovery {
    #Write-Host "Pester Test development v2.0.0" -ForegroundColor Yellow
    $Node = "S1"
    $LabData = Import-PowerShellDataFile -Path $PSScriptRoot\*.psd1
    $Computername = $LabData.AllNodes[1].NodeName
    $Domain = $Computername
    $prefix = $LabData.NonNodeData.Lability.EnvironmentPrefix
    $VMName = "$($prefix)$Computername"
    $NodeIP = $LabData.AllNodes[1].IPAddress
    $DNSAddress = $LabData.AllNodes[0].DnsServerAddress
    $CNTest = @{ CN = $Computername }
    $IPTest = @{ IP = $NodeIP }
    $DNSTest = @{Address = $DNSAddress }
}

Describe $Node {
    BeforeAll {
        Try {
            $LabData = Import-PowerShellDataFile -Path $PSScriptRoot\*.psd1
            $Secure = ConvertTo-SecureString -String "$($LabData.AllNodes.LabPassword)" -AsPlainText -Force
            $Computername = $LabData.AllNodes[1].NodeName
            $cred = New-Object PSCredential "$Domain\Administrator", $Secure

            #The prefix only changes the name of the VM not the guest computername
            $prefix = $LabData.NonNodeData.Lability.EnvironmentPrefix
            $VMName = "$($prefix)$Computername"

            #set error action preference to suppress all error messages which would be normal while configurations are converging
            #turn off progress bars
            $prep = {
                $ProgressPreference = 'SilentlyContinue'
                $errorActionPreference = 'SilentlyContinue'
            }

            $VMSess = New-PSSession -VMName $VMName -Credential $Cred -ErrorAction Stop
            Invoke-Command $prep -Session $VMSess

            $test = Invoke-Command { Get-CimInstance -ClassName win32_OperatingSystem -Property caption, csname } -Session $VMSess
            $dns = Invoke-Command { Get-DnsClientServerAddress -InterfaceAlias ethernet -AddressFamily IPv4 } -Session $VMSess
            $sys = Invoke-Command { Get-CimInstance Win32_ComputerSystem } -Session $VMSess
            $if = Invoke-Command -ScriptBlock { Get-NetIPAddress -InterfaceAlias 'Ethernet' -AddressFamily IPv4 } -Session $VMSess
            $installType = Invoke-Command { Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\windows nt\currentversion' -Name InstallationType } -Session $VMSess
            $resolve = Invoke-Command { Resolve-DnsName www.pluralsight.com -Type A | Select-Object -First 1 } -Session $VMSess
            $PS2Test = Invoke-Command { (Get-WindowsFeature -Name 'PowerShell-V2').Installed } -Session $VMSess
            $rdpTest= Invoke-Command { Get-ItemPropertyValue -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\' -Name fDenyTSConnections} -Session $VMSess
        }
        catch {
        <#     It "[$Node] Should allow a PSSession but got error: $($_.exception.message)" {
                $false | Should -Be $True
            } #>
        }
    }
    AfterAll {
        if ($VMSess) {
            $VMSess | Remove-PSSession
        }
    }
    It "[$Node] Should accept administrator credential"{
        $VMSess.State | Should -Be 'Opened'
    }

    It "[$Node] Should respond to WSMan requests" {
        $VMSess.Computername | Should -Be $VMName
    }

    It "[$Node] Should Belong to a Workgroup" {
        $sys.Domain | Should -Be 'Workgroup'
    }

    It "[$Node] Should Be running Windows Server 2019" {
        $test.caption | Should -BeLike '*2019*'
    }
    It "[$Node] Should have a computername of <CN>" -ForEach $CNTest {
        $test.CSName | Should -Be $CN
    }
    It "[$Node] Should -Be running Server (with desktop)" {
        $installType | Should -Be 'Server'
    }
    It "[$Node] Should have an IP address of <IP>" -ForEach $IPTest {
        $if.ipv4Address | Should -Be $IP
    }

    It "[$Node] Should have a DNS server configuration of <Address>" -ForEach $DNSTest {
        $dns.ServerAddresses -contains $Address | Should -Be 'True'
    }

    It "[$Node] Should Be able to resolve an Internet address" {
        $resolve.name | Should -Be 'www.pluralsight.com'
    }
    It "[$Node] Should have RDP for admin access enabled" {
        $rdpTest | Should -Be 0
    }
    It "[$Node] Should not have PowerShell 2 installed" {
        $PS2Test | Should -Be $False
    }

} #S1

