Configuration TestLab {

    param (
        [Parameter()] 
        [ValidateNotNull()] 
        [PSCredential] $Credential = (Get-Credential -Credential 'Administrator')
    )
   Import-Dscresource -Module xWebAdministration, PSDesiredStateConfiguration ,xComputermanagement, xNetworking

    node $AllNodes.Where({$true}).NodeName {
        LocalConfigurationManager {
            RebootNodeIfNeeded   = $true
            AllowModuleOverwrite = $true
            ConfigurationMode = 'ApplyOnly'
           # CertificateID = $node.Thumbprint;
        }

        if (-not [System.String]::IsNullOrEmpty($node.IPAddress)) {
            xIPAddress 'PrimaryIPAddress' {
                IPAddress      = $node.IPAddress
                InterfaceAlias = $node.InterfaceAlias
                SubnetMask     = $node.SubnetMask
                AddressFamily  = $node.AddressFamily
            }

            if (-not [System.String]::IsNullOrEmpty($node.DefaultGateway)) {
                xDefaultGatewayAddress 'PrimaryDefaultGateway' {
                    InterfaceAlias = $node.InterfaceAlias
                    Address = $node.DefaultGateway
                    AddressFamily = $node.AddressFamily
                }
            }
            
            if (-not [System.String]::IsNullOrEmpty($node.DnsServerAddress)) {
                xDnsServerAddress 'PrimaryDNSClient' {
                    Address        = $node.DnsServerAddress
                    InterfaceAlias = $node.InterfaceAlias
                    AddressFamily  = $node.AddressFamily
                }
            }
            
            if (-not [System.String]::IsNullOrEmpty($node.DnsConnectionSuffix)) {
                xDnsConnectionSuffix 'PrimaryConnectionSuffix' {
                    InterfaceAlias = $node.InterfaceAlias
                    ConnectionSpecificSuffix = $node.DnsConnectionSuffix
                }
            }
            
        } #end if IPAddress
        
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
            Name = 'FPS-ICMP6-ERQ-In'
            DisplayName = 'File and Printer Sharing (Echo Request - ICMPv6-In)'
            Description = 'Echo request messages are sent as ping requests to other nodes.'
            Direction = 'Inbound'
            Action = 'Allow'
            Enabled = 'True'
            Profile = 'Any'
        }
    } #end nodes ALL
  
    node $AllNodes.Where({$_.Role -in 'Web'}).NodeName {
        ## Flip credential into username@domain.com
        $domainCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ("$($Credential.UserName)@$($node.DomainName)", $Credential.Password)

        xComputer 'Hostname' {
            Name = $node.NodeName
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
                Ensure = 'Present'
                Name = $feature
                IncludeAllSubFeature = $False
            }
        }
        
       
    } #end nodes
    
 
} #end Configuration Example

TestLab -OutputPath .\ -ConfigurationData .\TestLab.psd1
