Configuration TestLab {
<#
    Requires the following custom DSC resources:
        xComputerManagement (v1.4.0.0 or later): https://github.com/PowerShell/xComputerManagement
        xNetworking/dev (v2.7.0.0 or later):     https://github.com/PowerShell/xNetworking
        xActiveDirectory (v2.9.0.0 or later):    https://github.com/PowerShell/xActiveDirectory
        xSmbShare (v1.1.0.0 or later):           https://github.com/PowerShell/xSmbShare
        xDhcpServer (v1.3.0 or later):           https://github.com/PowerShell/xDhcpServer
        xDnsServer (v1.5.0 or later):            https://github.com/PowerShell/xDnsServer
#>
    param (
        [Parameter()] 
        [ValidateNotNull()] 
        [PSCredential] $Credential = (Get-Credential -Credential 'Administrator')
    )
   Import-Dscresource -Module xWebAdministration, PSDesiredStateConfiguration ,xComputermanagement, xNetworking
   # Import-DscResource -Module xComputerManagement, xNetworking, xActiveDirectory;
   # Import-DscResource -Module xSmbShare, PSDesiredStateConfiguration;
   # Import-DscResource -Module xDHCPServer, xDnsServer;

    node $AllNodes.Where({$true}).NodeName {
        LocalConfigurationManager {
            RebootNodeIfNeeded   = $true;
            AllowModuleOverwrite = $true;
            ConfigurationMode = 'ApplyOnly';
           # CertificateID = $node.Thumbprint;
        }

        if (-not [System.String]::IsNullOrEmpty($node.IPAddress)) {
            xIPAddress 'PrimaryIPAddress' {
                IPAddress      = $node.IPAddress;
                InterfaceAlias = $node.InterfaceAlias;
                SubnetMask     = $node.SubnetMask;
                AddressFamily  = $node.AddressFamily;
            }

            if (-not [System.String]::IsNullOrEmpty($node.DefaultGateway)) {
                xDefaultGatewayAddress 'PrimaryDefaultGateway' {
                    InterfaceAlias = $node.InterfaceAlias;
                    Address = $node.DefaultGateway;
                    AddressFamily = $node.AddressFamily;
                }
            }
            
            if (-not [System.String]::IsNullOrEmpty($node.DnsServerAddress)) {
                xDnsServerAddress 'PrimaryDNSClient' {
                    Address        = $node.DnsServerAddress;
                    InterfaceAlias = $node.InterfaceAlias;
                    AddressFamily  = $node.AddressFamily;
                }
            }
            
            if (-not [System.String]::IsNullOrEmpty($node.DnsConnectionSuffix)) {
                xDnsConnectionSuffix 'PrimaryConnectionSuffix' {
                    InterfaceAlias = $node.InterfaceAlias;
                    ConnectionSpecificSuffix = $node.DnsConnectionSuffix;
                }
            }
            
        } #end if IPAddress
        
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
    } #end nodes ALL
  
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
