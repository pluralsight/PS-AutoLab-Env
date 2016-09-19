@{
    AllNodes = @(
        @{
            NodeName = '*'
            
            # Common networking
            InterfaceAlias = 'Ethernet'
            DefaultGateway = '192.168.3.1'
            SubnetMask = 24
            AddressFamily = 'IPv4'
            DnsServerAddress = '192.168.3.10'
            
            # DHCP Server Data
            DHCPName = 'LabNet'
            DHCPIPStartRange = '192.168.3.200'
            DHCPIPEndRange = '192.168.3.250'
            DHCPSubnetMask = '255.255.255.0'
            DHCPState = 'Active'
            DHCPAddressFamily = 'IPv4'
            DHCPLeaseDuration = '00:08:00'
            DHCPScopeID = '192.168.3.0'
            DHCPDnsServerIPAddress = '192.168.3.10'
            DHCPRouter = '192.168.3.1'
            
            # Domain and Domain Controller information
            DomainName = "Company.Pri"
            DomainDN = "DC=Company,DC=Pri"
            DCDatabasePath = "C:\NTDS"
            DCLogPath = "C:\NTDS"
            SysvolPath = "C:\Sysvol"
            PSDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser = $true 
            
            # ADCS Certificate Services information
            CACN = 'Company.Pri'
            CADNSuffix = "C=US,L=Phoenix,S=Arizona,O=Company"
            CADatabasePath = "C:\windows\system32\CertLog"
            CALogPath = "C:\CA_Logs"
            CAType = 'EnterpriseRootCA'
            ADCSCryptoProviderName = 'RSA#Microsoft Software Key Storage Provider'
            ADCSHashAlgorithmName = 'SHA256'
            ADCSKeyLength = 2048
            ADCSValidityPeriod = 'Years'
            ADCSValidityPeriodUnits = 2
            
            # How to install certificates on machines
            #CertificateFile = "$env:AllUsersProfile\Lability\Certificates\LabClient.cer";
            #Thumbprint = 'AAC41ECDDB3B582B133527E4DE0D2F8FEB17AAB2';
            
            # LAbility custom settings
            Lability_SwitchName = 'LabNet'
            Lability_ProcessorCount = 1
            Lability_StartupMemory = 1GB
            Lability_Media = '2016TP5_x64_Standard_EN' # Can be Core,Win10,2012R2,nano
                                                       # 2016TP5_x64_Standard_Core_EN
                                                       # WIN10_x64_Enterprise_EN_Eval
        }
        @{
            NodeName = 'DC'
            IPAddress = '192.168.3.10'
            #Role = 'DC', 'DHCP', 'ADCS'
            Lability_BootOrder = 10
            Lability_BootDelay = 180 # Number of seconds to delay before others
            Lability_timeZone = 'US Mountain Standard Time' #[System.TimeZoneInfo]::GetSystemTimeZones()
        }
        @{
            NodeName = 'S1'
            IPAddress = '192.168.3.50'
            #Role = 'Server'
            Lability_BootOrder = 20
            Lability_timeZone = 'US Mountain Standard Time' #[System.TimeZoneInfo]::GetSystemTimeZones()
        }
        @{
            NodeName = 'S2'
            IPAddress = '192.168.3.51'
            #Role = 'Server'
            Lability_BootOrder = 20
            Lability_timeZone = 'US Mountain Standard Time' #[System.TimeZoneInfo]::GetSystemTimeZones()

        }
        @{
            NodeName = 'Client'
            IPAddress = '192.168.3.100'
            #Role = 'Client'
            Lability_ProcessorCount = 2
            Lability_StartupMemory = 2GB
            Lability_Media = 'WIN10_x64_Enterprise_EN_Eval'
            Lability_BootOrder = 20
            Lability_timeZone = 'US Mountain Standard Time' #[System.TimeZoneInfo]::GetSystemTimeZones()
        }
        
        
    );
    NonNodeData = @{
        Lability = @{
            EnvironmentPrefix = 'PS-GUI-'; # this will prefix the VM names if using multiple lab environemnts
                                       # at the same time.
            Media = @(); # Custom media additions that are different than the supplied defaults (media.json)
            Network = @(
                @{ Name = 'LabNet'; Type = 'Internal'; NetAdapterName = 'Ethernet'; AllowManagementOS = $true;}
                # Can create Multiple switches
                # @{ Name = 'Corpnet'; Type = 'External'; NetAdapterName = 'Ethernet'; AllowManagementOS = $true; }
            );
            DSCResource = @(
                ## Download published version from the PowerShell Gallery
                ## The 'GitHub# provider can download modules directly from a GitHub repository, for example:
                ## @{ Name = 'Lability'; Provider = 'GitHub'; Owner = 'VirtualEngine'; Repository = 'Lability'; Branch = 'dev'; }
        
                @{ Name = 'xActiveDirectory'; MinimumVersion="2.13.0.0"; Provider = 'PSGallery'; },
                @{ Name = 'xComputerManagement'; MinimumVersion = '1.8.0.0'; Provider = 'PSGallery'; }
                @{ Name = 'xNetworking'; MinimumVersion = '2.11.0.0'; Provider = 'PSGallery'; }
                @{ Name = 'xADCSDeployment'; MinimumVersion = '1.0.0.0'; Provider = 'PSGallery'; }
                @{ Name = 'xDhcpServer'; MinimumVersion = '1.5.0.0'; Provider = 'PSGallery';  }

            );
        };
    };
};
