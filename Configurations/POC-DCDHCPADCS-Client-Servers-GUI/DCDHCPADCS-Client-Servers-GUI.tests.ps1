$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

$Server = "DC"

Describe "Test DC server for installation completeness" {
    Context "Windows Features for ADDS Installed" {
        
        It "Should have DNS installed" {
            $Result = (get-windowsFeature -name DNS -ComputerName $server).InstallState 
            $Result | should be 'Installed'
            }

        It "Should have DNS management tools installed" {
            $Result = (get-windowsFeature -name RSAT-DNS-Server -ComputerName $server).InstallState
            $Result | should be 'Installed'
            }

        It "Should have ADDS installed" {
            $Result = (get-windowsFeature -name AD-Domain-Services -ComputerName $server).InstallState
            $Result | should be 'Installed'
            }

        It "Should have GPMC installed" {
            $Result = (get-windowsFeature -name GPMC -ComputerName $server).InstallState
            $Result | should be 'Installed'
            }

        It "Should have RSAT AD Tools installed" {
            $Result = (get-windowsFeature -name RSAT-AD-Tools -ComputerName $server).InstallState
            $Result | should be 'Installed'
            }

        It "Should have RSAT AD Powershell installed" {
            $Result = (get-windowsFeature -name RSAT-AD-Powershell -ComputerName $server).InstallState
            $Result | should be 'Installed'
            }
    
        It "Should have RSAT AD AdminCenter installed" {
            $Result = (get-windowsFeature -name RSAT-AD-AdminCenter -ComputerName $server).InstallState
            $Result | should be 'Installed'
            }
        
        It "Should have RSAT ADDS Tools installed" {
            $Result = (get-windowsFeature -name RSAT-ADDS-Tools -ComputerName $server).InstallState
            $Result | should be 'Installed'
            }

        } # Context WindowsFeatures
    
    Context "Active Directory object existence" {

        It "Created AD OU named IT" {
            {Get-ADOrganizationalUnit -Identity "OU=IT,DC=Company,DC=pri"} | should not Throw
            }

        It "Created AD OU named Dev" {
            {Get-ADOrganizationalUnit -Identity "OU=Dev,DC=Company,DC=pri"} | should not Throw
            }
    
        It "Created AD OU named Marketing" {
            {Get-ADOrganizationalUnit -Identity "OU=Marketing,DC=Company,DC=pri"} | should not Throw
            }

        It "Created AD OU named Sales" {
            {Get-ADOrganizationalUnit -Identity "OU=Sales,DC=Company,DC=pri"} | should not Throw
            }
    
        It "Created AD OU named Accounting" {
            {Get-ADOrganizationalUnit -Identity "OU=Accounting,DC=Company,DC=pri"} | should not Throw
            }

        It "Created AD OU named JEA_Operators" {
            {Get-ADOrganizationalUnit -Identity "OU=JEA_Operators,DC=Company,DC=pri"} | should not Throw
            }

        It "Created AD User MaryL" {
            {Get-ADUser -Identity MaryL} | should not Throw
            }

        It "Created AD User MikeS" {
            {Get-ADUser -Identity MikeS} | should not Throw
            }

        It "Created AD User SimonS" {
            {Get-ADUser -Identity SimonS} | should not Throw
            }

        It "Created AD User AaronS" {
            {Get-ADUser -Identity AaronS} | should not Throw
            }

        It "Created AD User AndreaS" {
            {Get-ADUser -Identity AndreaS} | should not Throw
            }

        It "Created AD User AndyS" {
            {Get-ADUser -Identity AndyS} | should not Throw
            }

        It "Created AD User SamS" {
            {Get-ADUser -Identity SamS} | should not Throw
            }

        It "Created AD User SonyaS" {
            {Get-ADUser -Identity SonyaS} | should not Throw
            }
        
        It "Created AD User SamanthaS" {
            {Get-ADUser -Identity SamanthaS} | should not Throw
            }

        It "Created AD User MarkS" {
            {Get-ADUser -Identity MarkS} | should not Throw
            }

        It "Created AD User MonicaS" {
            {Get-ADUser -Identity MonicaS} | should not Throw
            }

        It "Created AD User MattS" {
            {Get-ADUser -Identity MattS} | should not Throw
            }

        It "Created AD User JimJ" {
            {Get-ADUser -Identity JimJ} | should not Throw
            }
    
        It "Created AD User JillJ" {
            {Get-ADUser -Identity JillJ} | should not Throw
            }
    
        It "Created AD Group IT" {
            {Get-ADGroup -Identity IT} | should not Throw
            }

        It "Created AD Group Sales" {
            {Get-ADGroup -Identity Sales} | should not Throw
            }

         It "Created AD Group Marketing" {
            {Get-ADGroup -Identity Marketing} | should not Throw
            }

        It "Created AD Group Accounting" {
            {Get-ADGroup -Identity Accounting} | should not Throw
            }

        It "Created AD Group JEA Operators" {
            {Get-ADGroup -Identity "JEA Operators"} | should not Throw
            }
    }

    Context "Windows Features for DHCP Installed" {

        It "Should have DHCP installed" {
            $Result = (get-windowsFeature -name DHCP -computerName $Server).InstallState
            $Result | should be 'Installed'
            }

        It "Should have DHCP Management Tools Installed" {
            $Result = (get-windowsFeature -name RSAT-DHCP -computerName $Server).InstallState 
            $Result | should be 'Installed'
            }
    }

    Context "DHCP Settings" {
    
    It "Should have DHCP authorized in AD" {
        {get-DHCPServerInDC} | should not Throw
        {get-DHCPServerInDC} | should not be NullOrEmpty
        }
       
    It "Should have a DHCP Scope" {
        {get-DHCPServerv4Scope -ComputerName $Server} | should not Throw 
        }

    It "Should have a Router Value" {
        {Get-DhcpServerv4OptionValue -ScopeId 192.168.2.0 -ComputerName $server | Where-Object {$_.Name -eq "Router"}} | should not Throw
        }

    It "Should have a DNS Server value" {
        {Get-DhcpServerv4OptionValue -ScopeId 192.168.2.0 -ComputerName $server | Where-Object {$_.Name -eq "DNS Servers"}} | should not Throw
        }

    }

    Context "Windows Features for ADCS Installed" {
        
        It "Should have ADCS Installed" {
            $Result = (get-WindowsFeature -Name ADCS-Cert-Authority -ComputerName $server).InstallState
            $Result | should be 'Installed'
            }

        It "Should have Certificate Enrollment Policy Web Service binaries installed" {
            $Result= (get-WindowsFeature -Name ADCS-Enroll-Web-Pol -ComputerName $server).InstallState
            $Result | should be "Installed"
            }

        It "Should have Certificate Enrollment Web Service binaries installed" {
            $Result = (get-WindowsFeature -Name ADCS-Enroll-Web-Svc -ComputerName $server).InstallState 
            $Result | should be "Installed"
            }

        It "Should have Certification Authority Web Enrollment role service binaries installed" {
            $Result = (get-WindowsFeature -Name ADCS-Web-Enrollment -ComputerName $server).InstallState
            $Result | should be "Installed"
            }

        It "Should have the RSAT for ADCS installed" {
            $Result = (get-WindowsFeature -Name RSAT-ADCS -ComputerName $server).InstallState
            $Result | should be "Installed"
            }

        It "Should have the RSAT-ADCS-Mgmt Installed" {
            $Result = (get-WindowsFeature -Name RSAT-ADCS-Mgmt -ComputerName $server).InstallState
            $Result | should be "Installed"
            }   

        }  
        
    Context "ADCS Configuration" {
        
        It "Should have one Certification Authority in Active Directory" {
            $Result = get-adobject -filter * -SearchBase "CN=Certification Authorities,CN=Public Key Services,CN=Services,CN=Configuration,DC=Company,DC=Pri" -SearchScope OneLevel
            ($Result.DistinguishedName).count | should BeExactly 1
            }
    }        
    
    Context "GPO for Autoenrollment" {
        
        It "Should have a GPO named PKI AutoEnroll" {
            {get-GPO -name "PKI AutoEnroll"} | should not Throw
            } 
    
    }      
        
}
