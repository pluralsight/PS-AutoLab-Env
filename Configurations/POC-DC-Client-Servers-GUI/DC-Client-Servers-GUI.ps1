<# Notes:

Authors: Jason Helmick and Melissa (Missy) Janusko

The bulk of this DC, DHCP, ADCS config is authored by Melissa (Missy) Januszko.
Currently on her public DSC hub located here:
https://github.com/majst32/DSC_public.git

Goal - Create a Domain Controller, Populute with OU's Groups and Users.
       One Server joined to the new domain
       One Windows 10 CLient joined to the new domain

       

Disclaimer

This example code is provided without copyright and AS IS.  It is free for you to use and modify.
Note: These demos should not be run as a script. These are the commands that I use in the 
demonstrations and would need to be modified for your environment.

#> 

Configuration AutoLab {

    param (
        [Parameter()] 
        [ValidateNotNull()] 
        [PSCredential] $Credential = (Get-Credential -Credential Administrator)
    )

#region DSC Resources
    Import-DSCresource -ModuleName PSDesiredStateConfiguration,
        @{ModuleName="xActiveDirectory";ModuleVersion="2.13.0.0"},
        @{ModuleName="xComputerManagement";ModuleVersion="1.8.0.0"},
        @{ModuleName="xNetworking";ModuleVersion="2.12.0.0"}

#endregion

    node $AllNodes.Where({$true}).NodeName {
#region LCM configuration
       
        LocalConfigurationManager {
            RebootNodeIfNeeded   = $true
            AllowModuleOverwrite = $true
            ConfigurationMode = 'ApplyOnly'
        }

#endregion
  
#region IPaddress settings 

 
    If (-not [System.String]::IsNullOrEmpty($node.IPAddress)) {
        xIPAddress 'PrimaryIPAddress' {
            IPAddress      = $node.IPAddress
            InterfaceAlias = $node.InterfaceAlias
            SubnetMask     = $node.SubnetMask
            AddressFamily  = $node.AddressFamily
        }

        If (-not [System.String]::IsNullOrEmpty($node.DefaultGateway)) {     
            xDefaultGatewayAddress 'PrimaryDefaultGateway' {
                InterfaceAlias = $node.InterfaceAlias
                Address = $node.DefaultGateway
                AddressFamily = $node.AddressFamily
            }
        }

        If (-not [System.String]::IsNullOrEmpty($node.DnsServerAddress)) {                    
            xDnsServerAddress 'PrimaryDNSClient' {
                Address        = $node.DnsServerAddress
                InterfaceAlias = $node.InterfaceAlias
                AddressFamily  = $node.AddressFamily
            }
        }

        If (-not [System.String]::IsNullOrEmpty($node.DnsConnectionSuffix)) {
            xDnsConnectionSuffix 'PrimaryConnectionSuffix' {
                InterfaceAlias = $node.InterfaceAlias
                ConnectionSpecificSuffix = $node.DnsConnectionSuffix
            }
        }
    } #End IF
            
#endregion

#region Firewall Rules
        
        xFirewall 'FPS-ICMP4-ERQ-In' {
            Name = 'FPS-ICMP4-ERQ-In'
            DisplayName = 'File and Printer Sharing (Echo Request - ICMPv4-In)'
            Description = 'Echo request messages are sent as ping requests to other nodes.'
            Direction = 'Inbound'
            Action = 'Allow'
            Enabled = 'True'
            Profile = 'Any'
        }

        xFirewall 'FPS-ICMP6-ERQ-In' {
            Name = 'FPS-ICMP6-ERQ-In';
            DisplayName = 'File and Printer Sharing (Echo Request - ICMPv6-In)'
            Description = 'Echo request messages are sent as ping requests to other nodes.'
            Direction = 'Inbound'
            Action = 'Allow'
            Enabled = 'True'
            Profile = 'Any'
        }

        xFirewall 'FPS-SMB-In-TCP' {
            Name = 'FPS-SMB-In-TCP'
            DisplayName = 'File and Printer Sharing (SMB-In)'
            Description = 'Inbound rule for File and Printer Sharing to allow Server Message Block transmission and reception via Named Pipes. [TCP 445]'
            Direction = 'Inbound'
            Action = 'Allow'
            Enabled = 'True'
            Profile = 'Any'
        }
#endregion

    } #end nodes ALL

#region Domain Controller config

    node $AllNodes.Where({$_.Role -eq 'DC'}).NodeName {
         
        xComputer ComputerName { 
            Name = $Node.NodeName 
        }            

        ## Hack to fix DependsOn with hypens "bug" :(
        foreach ($feature in @(
                'DNS',
                'RSAT-DNS-Server'                           
                'AD-Domain-Services'
                'GPMC',
                'RSAT-AD-Tools' 
                'RSAT-AD-PowerShell'
                'RSAT-AD-AdminCenter'
                'RSAT-ADDS-Tools'

            )) {
            WindowsFeature $feature.Replace('-','') {
                Ensure = 'Present';
                Name = $feature;
                IncludeAllSubFeature = $False;
            }
        } #End foreach

            xADDomain FirstDC {
                DomainName = $Node.DomainName
                DomainAdministratorCredential = $Credential
                SafemodeAdministratorPassword = $Credential
                DatabasePath = $Node.DCDatabasePath
                LogPath = $Node.DCLogPath
                SysvolPath = $Node.SysvolPath 
                DependsOn = '[WindowsFeature]ADDomainServices'
            }  
        
        #Add OU, Groups, and Users


            xADOrganizationalUnit IT {
                Name = 'IT'
                Ensure = 'Present'
                Path = $Node.DomainDN
                ProtectedFromAccidentalDeletion = $False
                DependsOn = '[xADDomain]FirstDC'
            }

            xADOrganizationalUnit Dev {
                Name = 'Dev'
                Ensure = 'Present'
                Path = $Node.DomainDN
                ProtectedFromAccidentalDeletion = $False
                DependsOn = '[xADDomain]FirstDC'
            }

            xADOrganizationalUnit Marketing {
                Name = 'Marketing'
                Ensure = 'Present'
                Path = $Node.DomainDN
                ProtectedFromAccidentalDeletion = $False
                DependsOn = '[xADDomain]FirstDC'
            }

            xADOrganizationalUnit Sales {
                Name = 'Sales'
                Ensure = 'Present'
                Path = $Node.DomainDN
                ProtectedFromAccidentalDeletion = $False
                DependsOn = '[xADDomain]FirstDC'
            }

            xADOrganizationalUnit Accounting {
                Name = 'Accounting'
                Ensure = 'Present'
                Path = $Node.DomainDN
                ProtectedFromAccidentalDeletion = $False
                DependsOn = '[xADDomain]FirstDC'
            }

            xADOrganizationalUnit JEA_Operators {
                Name = 'JEA_Operators'
                Ensure = 'Present'
                Path = $Node.DomainDN
                ProtectedFromAccidentalDeletion = $False
                DependsOn = '[xADDomain]FirstDC'
            }

            # Users
            xADUser IT1 {
                DomainName = $node.DomainName
                Path = "OU=IT,$($node.DomainDN)"
                UserName = 'DonJ'
                GivenName = 'Don'
                Surname = 'Jones'
                DisplayName = 'Don Jones'
                Description = 'The Main guy'
                Department = 'IT'
                Enabled = $true
                Password = $Credential
                DomainAdministratorCredential = $Credential
                PasswordNeverExpires = $true
                DependsOn = '[xADDomain]FirstDC'
            }

            xADUser IT2 {
                DomainName = $node.DomainName
                Path = "OU=IT,$($node.DomainDN)"
                UserName = 'Jasonh'
                GivenName = 'Jason'
                Surname = 'Helmick'
                DisplayName = 'Jason Helmick'
                Description = 'The Fun guy'
                Department = 'IT'
                Enabled = $true
                Password = $Credential
                DomainAdministratorCredential = $Credential
                PasswordNeverExpires = $true
                DependsOn = '[xADDomain]FirstDC'
            }

            xADUser IT3 {
                DomainName = $node.DomainName
                Path = "OU=IT,$($node.DomainDN)"
                UserName = 'GregS'
                GivenName = 'Greg'
                Surname = 'Shields'
                DisplayName = 'Greg Shields'
                Description = 'The Janitor'
                Department = 'IT'
                Enabled = $true
                Password = $Credential
                DomainAdministratorCredential = $Credential
                PasswordNeverExpires = $true
                DependsOn = '[xADDomain]FirstDC'
            }

            xADUser Dev1 {
                DomainName = $node.DomainName
                Path = "OU=Dev,$($node.DomainDN)"
                UserName = 'SimonA'
                GivenName = 'Simon'
                Surname = 'Allardice'
                DisplayName = 'Simon Allardice'
                Description = 'The Brilliant one'
                Department = 'Dev'
                Enabled = $true
                Password = $Credential
                DomainAdministratorCredential = $Credential
                PasswordNeverExpires = $true
                DependsOn = '[xADDomain]FirstDC'
            }

            xADUser Acct1 {
                DomainName = $node.DomainName
                Path = "OU=Accounting,$($node.DomainDN)"
                UserName = 'AaronS'
                GivenName = 'Aaron'
                Surname = 'Smith'
                DisplayName = 'Aaron Smith'
                Description = 'Accountant'
                Department = 'Accounting'
                Enabled = $true
                Password = $Credential
                DomainAdministratorCredential = $Credential
                PasswordNeverExpires = $true
                DependsOn = '[xADDomain]FirstDC'
            }

            xADUser Acct2 {
                DomainName = $node.DomainName
                Path = "OU=Accounting,$($node.DomainDN)"
                UserName = 'AndreaS'
                GivenName = 'Andrea'
                Surname = 'Smith'
                DisplayName = 'Andrea Smith'
                Description = 'Accountant'
                Department = 'Accounting'
                Enabled = $true
                Password = $Credential
                DomainAdministratorCredential = $Credential
                PasswordNeverExpires = $true
                DependsOn = '[xADDomain]FirstDC'
            }

            xADUser Acct3 {
                DomainName = $node.DomainName
                Path = "OU=Accounting,$($node.DomainDN)"
                UserName = 'AndyS'
                GivenName = 'Andy'
                Surname = 'Smith'
                DisplayName = 'Andy Smith'
                Description = 'Accountant'
                Department = 'Accounting'
                Enabled = $true
                Password = $Credential
                DomainAdministratorCredential = $Credential
                PasswordNeverExpires = $true
                DependsOn = '[xADDomain]FirstDC'
            }

            xADUser Sales1 {
                DomainName = $node.DomainName
                Path = "OU=Sales,$($node.DomainDN)"
                UserName = 'SamS'
                GivenName = 'Sam'
                Surname = 'Smith'
                DisplayName = 'Sam Smith'
                Description = 'Sales'
                Department = 'Sales'
                Enabled = $true
                Password = $Credential
                DomainAdministratorCredential = $Credential
                PasswordNeverExpires = $true
                DependsOn = '[xADDomain]FirstDC'
            }

            xADUser Sales2 {
                DomainName = $node.DomainName
                Path = "OU=Sales,$($node.DomainDN)"
                UserName = 'SonyaS'
                GivenName = 'Sonya'
                Surname = 'Smith'
                DisplayName = 'Sonya Smith'
                Description = 'Sales'
                Department = 'Sales'
                Enabled = $true
                Password = $Credential
                DomainAdministratorCredential = $Credential
                PasswordNeverExpires = $true
                DependsOn = '[xADDomain]FirstDC'
            }

            xADUser Sales3 {
                DomainName = $node.DomainName
                Path = "OU=Sales,$($node.DomainDN)"
                UserName = 'SamanthaS'
                GivenName = 'Samantha'
                Surname = 'Smith'
                DisplayName = 'Samantha Smith'
                Description = 'Sales'
                Department = 'Sales'
                Enabled = $true
                Password = $Credential
                DomainAdministratorCredential = $Credential
                PasswordNeverExpires = $true
                DependsOn = '[xADDomain]FirstDC'
            }

            xADUser Market1 {
                DomainName = $node.DomainName
                Path = "OU=Marketing,$($node.DomainDN)"
                UserName = 'MarkS'
                GivenName = 'Mark'
                Surname = 'Smith'
                DisplayName = 'Mark Smith'
                Description = 'Marketing'
                Department = 'Marketing'
                Enabled = $true
                Password = $Credential
                DomainAdministratorCredential = $Credential
                PasswordNeverExpires = $true
                DependsOn = '[xADDomain]FirstDC'
            }

            xADUser Market2 {
                DomainName = $node.DomainName
                Path = "OU=Marketing,$($node.DomainDN)"
                UserName = 'MonicaS'
                GivenName = 'Monica'
                Surname = 'Smith'
                DisplayName = 'Monica Smith'
                Description = 'Marketing'
                Department = 'Marketing'
                Enabled = $true
                Password = $Credential
                DomainAdministratorCredential = $Credential
                PasswordNeverExpires = $true
                DependsOn = '[xADDomain]FirstDC'
            }

            xADUser Market3 {
                DomainName = $node.DomainName
                Path = "OU=Marketing,$($node.DomainDN)"
                UserName = 'MattS'
                GivenName = 'Matt'
                Surname = 'Smith'
                DisplayName = 'Matt Smith'
                Description = 'Marketing'
                Department = 'Marketing'
                Enabled = $true
                Password = $Credential
                DomainAdministratorCredential = $Credential
                PasswordNeverExpires = $true
                DependsOn = '[xADDomain]FirstDC'
            }

            xADUser JEA1 {
                DomainName = $node.DomainName
                Path = "OU=JEA_Operators,$($node.DomainDN)"
                UserName = 'JimJ'
                GivenName = 'Jim'
                Surname = 'Jea'
                DisplayName = 'Jim Jea'
                Description = 'JEA'
                Department = 'IT'
                Enabled = $true
                Password = $Credential
                DomainAdministratorCredential = $Credential
                PasswordNeverExpires = $true
                DependsOn = '[xADDomain]FirstDC'
            }

            xADUser JEA2 {
                DomainName = $node.DomainName
                Path = "OU=JEA_Operators,$($node.DomainDN)"
                UserName = 'JillJ'
                GivenName = 'Jill'
                Surname = 'Jea'
                DisplayName = 'Jill Jea'
                Description = 'JEA'
                Department = 'IT'
                Enabled = $true
                Password = $Credential
                DomainAdministratorCredential = $Credential
                PasswordNeverExpires = $true
                DependsOn = '[xADDomain]FirstDC'
            }
 
            #Groups
            xADGroup ITG1 {
                GroupName = 'IT'
                Path = "OU=IT,$($node.DomainDN)"
                Category = 'Security'
                GroupScope = 'Universal'
                Members = 'DonJ', 'Jasonh', 'GregS'
                DependsOn = '[xADDomain]FirstDC'
            }

            xADGroup SalesG1 {
                GroupName = 'Sales'
                Path = "OU=Sales,$($node.DomainDN)"
                Category = 'Security'
                GroupScope = 'Universal'
                Members = 'SamS', 'SonyaS', 'SamanthaS'
                DependsOn = '[xADDomain]FirstDC'
            }

            xADGroup MKG1 {
                GroupName = 'Marketing'
                Path = "OU=Marketing,$($node.DomainDN)"
                Category = 'Security'
                GroupScope = 'Universal'
                Members = 'MarkS', 'MonicaS', 'MattS'
                DependsOn = '[xADDomain]FirstDC'
            }

            xADGroup AccountG1 {
                GroupName = 'Accounting'
                Path = "OU=Accounting,$($node.DomainDN)"
                Category = 'Security'
                GroupScope = 'Universal'
                Members = 'AaronS', 'AndreaS', 'AndyS'
                DependsOn = '[xADDomain]FirstDC'
            }

            xADGroup JEAG1 {
                GroupName = 'JEA Operators'
                Path = "OU=JEA_Operators,$($node.DomainDN)"
                Category = 'Security'
                GroupScope = 'Universal'
                Members = 'JimJ', 'JillJ'
                DependsOn = '[xADDomain]FirstDC'
            }
       
    } #end nodes DC

#endregion 

#region Web config
   node $AllNodes.Where({$_.Role -eq 'Web'}).NodeName {
        
        foreach ($feature in @(
                'web-Server'
 
            )) {
            WindowsFeature $feature.Replace('-','') {
                Ensure = 'Present'
                Name = $feature
                IncludeAllSubFeature = $False
            }
        }
        
    }#end Web Config


#region DomainJoin config
   node $AllNodes.Where({$_.Role -eq 'DomainJoin'}).NodeName {

    $DomainCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ("$($node.DomainName)\$($Credential.UserName)", $Credential.Password)
 
        xWaitForADDomain DscForestWait {
            DomainName = $Node.DomainName
            DomainUserCredential = $DomainCredential
            RetryCount = '20'
            RetryIntervalSec = '60'
        }

         xComputer JoinDC {
            Name = $Node.NodeName
            DomainName = $Node.DomainName
            Credential = $DomainCredential
            DependsOn = '[xWaitForADDomain]DSCForestWait'
        }
    }#end DomianJoin Config
#endregion

} # End AllNodes
#endregion

AutoLab -OutputPath .\ -ConfigurationData .\*.psd1

