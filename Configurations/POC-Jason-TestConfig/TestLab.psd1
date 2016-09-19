@{
    AllNodes = @(
        @{
            NodeName = '*';
            InterfaceAlias = 'Ethernet';
            DefaultGateway = '192.168.3.1';
            SubnetMask = 24;
            AddressFamily = 'IPv4';
            DnsServerAddress = '192.168.3.10';
            DomainName = 'company.pri';
            PSDscAllowPlainTextPassword = $true;
            #CertificateFile = "$env:AllUsersProfile\Lability\Certificates\LabClient.cer";
            #Thumbprint = 'AAC41ECDDB3B582B133527E4DE0D2F8FEB17AAB2';
            PSDscAllowDomainUser = $true; # Removes 'It is not recommended to use domain credential for node X' messages
            Lability_SwitchName = 'LabNet';
            Lability_ProcessorCount = 1;
            Lability_StartupMemory = 1GB;
            #Lability_Media = '2016TP5_x64_Standard_EN';
            #WIN10_x64_Enterprise_EN_Eval
            #2016TP5_x64_Standard_Core_EN
        }
        @{
            NodeName = 'web1';
            IPAddress = '192.168.3.50';
            DnsServerAddress = '4.2.2.2';
            Role = 'web';
            Lability_ProcessorCount = 1;
            Lability_Media = '2016TP5_x64_Standard_EN';
        }
        @{
            NodeName = 'web2';
            IPAddress = '192.168.3.51';
            DnsServerAddress = '4.2.2.2';
            Role = 'web';
            Lability_ProcessorCount = 1;
            Lability_Media = '2016TP5_x64_Standard_Core_EN';
        }
        @{
            NodeName = 'Client';
            IPAddress = '192.168.3.100';
            DnsServerAddress = '4.2.2.2';
            Role = 'Client';
            Lability_ProcessorCount = 2;
            Lability_StartupMemory = 2GB;
            Lability_Media = 'WIN10_x64_Enterprise_EN_Eval';
        }
        
        
    );
    NonNodeData = @{
        Lability = @{
           EnvironmentPrefix = 'Prefix-';
            Media = @();
            Network = @(
                @{ Name = 'LabNet'; Type = 'Internal'; NetAdapterName = 'Ethernet'}
                #@{ Name = 'Internet'; Type = 'Internal'; }
                # @{ Name = 'Corpnet'; Type = 'External'; NetAdapterName = 'Ethernet'; AllowManagementOS = $true; }
                <#
                    IPAddress: The desired IP address.
                    InterfaceAlias: Alias of the network interface for which the IP address should be set. <- Use NetAdapterName
                    DefaultGateway: Specifies the IP address of the default gateway for the host. <- Not needed for internal switch
                    Subnet: Local subnet CIDR (used for cloud routing).
                    AddressFamily: IP address family: { IPv4 | IPv6 }
                #>
            );
            DSCResource = @(
                ## Download published version from the PowerShell Gallery
                @{ Name = 'xWebAdministration'; MinimumVersion = '1.13.0.0'; Provider = 'PSGallery'; }
                @{ Name = 'xComputerManagement'; MinimumVersion = '1.3.0.0'; Provider = 'PSGallery'; }
                ## If not specified, the provider defaults to the PSGallery.
               # @{ Name = 'xSmbShare'; MinimumVersion = '1.1.0.0'; }
                @{ Name = 'xNetworking'; MinimumVersion = '2.7.0.0'; }
               # @{ Name = 'xActiveDirectory'; MinimumVersion = '2.9.0.0'; }
               # @{ Name = 'xDnsServer'; MinimumVersion = '1.5.0.0'; }
               # @{ Name = 'xDhcpServer'; MinimumVersion = '1.3.0.0'; }
                ## The 'GitHub# provider can download modules directly from a GitHub repository, for example:
                ## @{ Name = 'Lability'; Provider = 'GitHub'; Owner = 'VirtualEngine'; Repository = 'Lability'; Branch = 'dev'; }
            );
        };
    };
};
