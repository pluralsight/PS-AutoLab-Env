Configuration GUILab {

    param (
        [Parameter()] 
        [ValidateNotNull()] 
        [PSCredential] $Credential = (Get-Credential -Credential 'Administrator')
    )
    Import-DSCresource -ModuleName PSDesiredStateConfiguration,
        @{ModuleName="xActiveDirectory";ModuleVersion="2.13.0.0"},
        @{ModuleName="xComputerManagement";ModuleVersion="1.8.0.0"},
        @{ModuleName="xNetworking";ModuleVersion="2.11.0.0"},
        @{ModuleName="XADCSDeployment";ModuleVersion="1.0.0.0"},
        @{ModuleName="xDhcpServer";ModuleVersion="1.5.0.0"}

    node $AllNodes.Where({$true}).NodeName {
#region LCM configuration
        
        LocalConfigurationManager {
            RebootNodeIfNeeded   = $true;
            AllowModuleOverwrite = $true;
            ConfigurationMode = 'ApplyOnly';
           # CertificateID = $node.Thumbprint;
        }

#endregion
  
#region IPaddress settings and computer anme 

        xComputer ComputerName { 
            Name = $Node.NodeName 
        }     

        xIPAddress 'PrimaryIPAddress' {
            IPAddress      = $node.IPAddress;
            InterfaceAlias = $node.InterfaceAlias;
            SubnetMask     = $node.SubnetMask;
            AddressFamily  = $node.AddressFamily;
        }
         
        xDefaultGatewayAddress 'PrimaryDefaultGateway' {
            InterfaceAlias = $node.InterfaceAlias;
            Address = $node.DefaultGateway;
            AddressFamily = $node.AddressFamily;
        }
                        
        xDnsServerAddress 'PrimaryDNSClient' {
            Address        = $node.DnsServerAddress;
            InterfaceAlias = $node.InterfaceAlias;
            AddressFamily  = $node.AddressFamily;
        }
            
        xDnsConnectionSuffix 'PrimaryConnectionSuffix' {
            InterfaceAlias = $node.InterfaceAlias;
            ConnectionSpecificSuffix = $node.DnsConnectionSuffix;
        }
            
#endregion

#region Firewall Rules
        
        xFirewall 'FPS-ICMP4-ERQ-In' {
            Name = 'FPS-ICMP4-ERQ-In';
            DisplayName = 'File and Printer Sharing (Echo Request - ICMPv4-In)';
            Description = 'Echo request messages are sent as ping requests to other nodes.';
            Direction = 'Inbound';
            Action = 'Allow';
            Enabled = 'True';
            Profile = 'Any';
        }

        xFirewall 'FPS-ICMP6-ERQ-In' {
            Name = 'FPS-ICMP6-ERQ-In';
            DisplayName = 'File and Printer Sharing (Echo Request - ICMPv6-In)';
            Description = 'Echo request messages are sent as ping requests to other nodes.';
            Direction = 'Inbound';
            Action = 'Allow';
            Enabled = 'True';
            Profile = 'Any';
        }

        xFirewall 'FPS-SMB-In-TCP' {
            Name = 'FPS-SMB-In-TCP';
            DisplayName = 'File and Printer Sharing (SMB-In)';
            Description = 'Inbound rule for File and Printer Sharing to allow Server Message Block transmission and reception via Named Pipes. [TCP 445]';
            Direction = 'Inbound';
            Action = 'Allow';
            Enabled = 'True';
            Profile = 'Any';
        }
#Endregion
                  
    } #end nodes ALL

#region Domain Controller config

    node $AllNodes.Where({$_.Role -in 'DC'}).NodeName {

        ## Flip credential into username@domain.com
        $domainCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ("$($Credential.UserName)@$($node.DomainName)", $Credential.Password);
    }
#endregion

  
    node $AllNodes.Where({$_.Role -in 'Web'}).NodeName {
        ## Flip credential into username@domain.com
        $domainCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ("$($Credential.UserName)@$($node.DomainName)", $Credential.Password);

        xComputer 'Hostname' {
            Name = $node.NodeName;
        }
        
        ## Hack to fix DependsOn with hypens "bug" :(
        foreach ($feature in @(
                'web-Server'
                #'GPMC',
                #'RSAT-AD-Tools',
                #'DHCP',
                #'RSAT-DHCP'
            )) {
            WindowsFeature $feature.Replace('-','') {
                Ensure = 'Present';
                Name = $feature;
                IncludeAllSubFeature = $False;
            }
        }
        
       
    } #end nodes DC
    
 
} #end Configuration Example

TestLab -OutputPath .\ -ConfigurationData .\TestLab.psd1
