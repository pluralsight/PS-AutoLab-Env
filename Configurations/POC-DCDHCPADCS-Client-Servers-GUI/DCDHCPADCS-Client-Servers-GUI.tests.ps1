$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

$Server = "DC"

Describe "Test DC server for installation completeness" {
    Context "Windows Features for ADDS Installed" {
        
        It "Should have DNS installed" {
            {get-windowsFeature -name DNS -ComputerName $server} | should not be NullOrEmpty
            }

         It "Should have DNS management tools installed" {
            {get-windowsFeature -name RSAT-DNS-Server -ComputerName $server} | should not be NullOrEmpty
            }

        It "Should have ADDS installed" {
            {get-windowsFeature -name AD-Domain-Services -ComputerName $server} | should not be NullOrEmpty
            }

        It "Should have GPMC installed" {
            {get-windowsFeature -name GPMC -ComputerName $server} | should not be NullOrEmpty
            }

        It "Should have RSAT AD Tools installed" {
            {get-windowsFeature -name RSAT-AD-Tools -ComputerName $server} | should not be NullOrEmpty
            }

        It "Should have RSAT AD Powershell installed" {
            {get-windowsFeature -name RSAT-AD-Powershell -ComputerName $server} | should not be NullOrEmpty
            }
    
        It "Should have RSAT AD AdminCenter installed" {
            {get-windowsFeature -name RSAT-AD-AdminCenter -ComputerName $server} | should not be NullOrEmpty
            }
        
        It "Should have RSAT ADDS Tools installed" {
            {get-windowsFeature -name RSAT-ADDS-Tools -ComputerName $server} | should not be NullOrEmpty
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

    It "Created AD User DonJ" {
        {Get-ADUser -Identity DonJ} | should not Throw
        }

    It "Created AD User JasonH" {
        {Get-ADUser -Identity JasonH} | should not Throw
        }

    It "Created AD User GregS" {
        {Get-ADUser -Identity GregS} | should not Throw
        }

    It "Created AD User SimonA" {
        {Get-ADUser -Identity SimonA} | should not Throw
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
        {get-windowsFeaure -name DHCP -computerName $Server} | should not be NullorEmpty
        }

    It "Should have DHCP Management Tools Installed" {
        {get-windowsFeaure -name RSAT-DHCP -computerName $Server} | should not be NullorEmpty
        }

    Context "DHCP Settings"
    It "Should have DHCP authorized in AD" {
        {get-DHCPServerInDC} | should not Throw
        {get-DHCPServerInDC} | should not be NullOrEmpty
        }
        
    }
}
