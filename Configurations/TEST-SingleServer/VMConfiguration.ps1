<# Notes:

Authors: Jason Helmick and Melissa (Missy) Janusko

The bulk of this DC, DHCP, ADCS config is authored by Melissa (Missy) Januszko and Jason Helmick.
Currently on her public DSC hub located here: https://github.com/majst32/DSC_public.git

Additional contributors of note: Jeff Hicks

       
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
        @{ModuleName="xPSDesiredStateConfiguration";ModuleVersion="4.0.0.0"},
        @{ModuleName="xActiveDirectory";ModuleVersion="2.13.0.0"},
        @{ModuleName="xComputerManagement";ModuleVersion="1.8.0.0"},
        @{ModuleName="xNetworking";ModuleVersion="2.12.0.0"},
        @{ModuleName="xDhcpServer";ModuleVersion="1.5.0.0"},
        @{ModuleName='xWindowsUpdate';ModuleVersion = '2.5.0.0'},
        @{ModuleName='xPendingReboot';ModuleVersion = '0.3.0.0'}

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

    $DomainCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ("$($node.DomainName)\$($Credential.UserName)", $Credential.Password)
         
        xComputer ComputerName { 
            Name = $Node.NodeName 
        }            

        ## Hack to fix DependsOn with hypens "bug" :(
        foreach ($feature in @(
                'DNS',                           
                'AD-Domain-Services',
                'RSAT-AD-Tools', 
                'RSAT-AD-PowerShell'
                #For Gui, might like
                #'RSAT-DNS-Server',                    
                #'GPMC, 
                #'RSAT-AD-AdminCenter',
                #'RSAT-ADDS-Tools'

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
    $OUs = (Get-Content .\AD-OU.json | ConvertFrom-Json)
    $Users = (Get-Content .\AD-Users.json | ConvertFrom-Json)
    $Groups = (Get-Content .\AD-Group.json | ConvertFrom-Json)

    
        foreach ($OU in $OUs) {
            xADOrganizationalUnit $OU.Name {
            Path = $node.DomainDN
            Name = $OU.Name
            Description = $OU.Description
            ProtectedFromAccidentalDeletion = $False
            Ensure = "Present"
            DependsOn = '[xADDomain]FirstDC'
        }
        } #OU
        
        foreach ($user in $Users) {
        
            xADUser $user.samaccountname {
                Ensure = "Present"
                Path = $user.distinguishedname.split(",",2)[1]
                DomainName = $node.domainname
                Username = $user.samaccountname
                GivenName = $user.givenname
                Surname = $user.Surname
                DisplayName = $user.Displayname
                Description = $user.description
                Department = $User.department
                Enabled = $true
                Password = $DomainCredential
                DomainAdministratorCredential = $DomainCredential
                PasswordNeverExpires = $True
                DependsOn = '[xADDomain]FirstDC'
            }
        } #user

        Foreach ($group in $Groups) {
            xADGroup $group.Name {
                GroupName = $group.name
                Ensure = 'Present'
                Path = $group.distinguishedname.split(",",2)[1]
                Category = $group.GroupCategory
                GroupScope = $group.GroupScope
                Members = $group.members
                DependsOn = '[xADDomain]FirstDC'
            }
        }

       
    } #end nodes DC

#endregion 

#region DHCP
    node $AllNodes.Where({$_.Role -eq 'DHCP'}).NodeName {

        foreach ($feature in @(
                'DHCP',
                'RSAT-DHCP'
            )) {

            WindowsFeature $feature.Replace('-','') {
                Ensure = 'Present';
                Name = $feature;
                IncludeAllSubFeature = $False;
                DependsOn = '[xADDomain]FirstDC'
            }
        } #End foreach  
        
        xDhcpServerAuthorization 'DhcpServerAuthorization' {
            Ensure = 'Present';
            DependsOn = '[WindowsFeature]DHCP'
        }
        
        xDhcpServerScope 'DhcpScope' {
            Name = $Node.DHCPName;
            IPStartRange = $Node.DHCPIPStartRange
            IPEndRange = $Node.DHCPIPEndRange
            SubnetMask = $Node.DHCPSubnetMask
            LeaseDuration = $Node.DHCPLeaseDuration
            State = $Node.DHCPState
            AddressFamily = $Node.DHCPAddressFamily
            DependsOn = '[WindowsFeature]DHCP'
        }

        xDhcpServerOption 'DhcpOption' {
            ScopeID = $Node.DHCPScopeID
            DnsServerIPAddress = $Node.DHCPDnsServerIPAddress
            Router = $node.DHCPRouter
            AddressFamily = $Node.DHCPAddressFamily
            DependsOn = '[xDhcpServerScope]DhcpScope'
        }  
 
    } #end DHCP Config
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
#endregion

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

#region RSAT config
   node $AllNodes.Where({$_.Role -eq 'RSAT'}).NodeName {
        
        xHotfix RSAT {
            Id = 'KB2693643'
            Path = 'c:\Resources\WindowsTH-RSAT_WS2016-x64.msu'
            Credential = $DomainCredential
            DependsOn = '[xcomputer]JoinDC'
            Ensure = 'Present'
        }

        xPendingReboot Reboot { 
            Name = 'AfterRSATInstall'
            DependsOn = '[xHotFix]RSAT'
        }

        
    }#end RSAT Config
#endregion
} # End AllNodes
#endregion

AutoLab -OutputPath .\ -ConfigurationData .\*.psd1

