@{
    AllNodes = @(
        @{
            NodeName = '*'
            
            # Common networking
            InterfaceAlias = 'Ethernet'
            DefaultGateway = '192.168.3.1'
            SubnetMask = 24
            AddressFamily = 'IPv4'
            DnsServerAddress = '4.2.2.2'
            
            
            # LAbility custom settings
            Lability_SwitchName = 'LabNet'
            Lability_ProcessorCount = 2
            Lability_StartupMemory = 2GB
            Lability_Media = '2016TP5_x64_Standard_EN' # Can be Core,Win10,2012R2,nano
                                                       # 2016TP5_x64_Standard_Core_EN
                                                       # WIN10_x64_Enterprise_EN_Eval
        }
        @{
            NodeName = 'Server'
            IPAddress = '192.168.3.5'
            Role = 'Server'
            Lability_timeZone = 'US Mountain Standard Time' #[System.TimeZoneInfo]::GetSystemTimeZones()
        }
        
    );
    NonNodeData = @{
        Lability = @{
            # EnvironmentPrefix = 'PS-GUI-'; # this will prefix the VM names if using multiple lab environemnts
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
