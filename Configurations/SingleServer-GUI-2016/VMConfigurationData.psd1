<# Notes:

Authors: Jason Helmick and Melissa (Missy) Januszko

The bulk of this DC, DHCP, ADCS config is authored by Melissa (Missy) Januszko and Jason Helmick.
Currently on her public DSC hub located here: https://github.com/majst32/DSC_public.git

Additional contributors of note: Jeff Hicks

Disclaimer
This example code is provided without copyright and AS IS.  It is free for you to use and modify.

#>

@{
    AllNodes    = @(
        @{
            NodeName                    = '*'

            # Lab Password - assigned to Administrator and Users
            LabPassword                 = 'P@ssw0rd'

            # Common networking
            InterfaceAlias              = 'Ethernet'
            DefaultGateway              = '192.168.3.1'
            SubnetMask                  = 24
            AddressFamily               = 'IPv4'
            IPNetwork                   = '192.168.3.0/24'
            IPNatName                   = 'LabNat'
            DnsServerAddress            = '4.2.2.2'

            # Firewall settings to enable
            FirewallRuleNames           = @(
                'FPS-ICMP4-ERQ-In';
                'FPS-ICMP6-ERQ-In';
                'FPS-SMB-In-TCP'
            )

            PSDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser        = $true

            # Lability default node settings
            Lability_SwitchName         = 'LabNet'
            Lability_ProcessorCount     = 1
            Lability_MinimumMemory      = 1GB
            SecureBoot                  = $false
            Lability_Media              = '2016_x64_Standard_Core_EN_Eval'
        }

        <#    Available Roles for computers
        DC = Domain Controller
        DHCP = Dynamic Host Configuration Protocol
        ADCS = Active Directory Certificate SErvices - plus autoenrollment GPO's and DSC and web server certs
        Web = Basic web server
        RSAT = Remote Server Administration Tools for the client
        RDP = enables RDP and opens up required firewall rules
        DomainJoin = joons a computer to the domain
#>

        @{
            NodeName               = 'S1'
            IPAddress              = '192.168.3.75'
            #Role = 'DomainJoin' # example of multiple roles @('DomainJoin', 'Web')
            Role                   = 'RDP' #@('DomainJoin', 'Web', 'RDP')
            Lability_BootOrder     = 20
            Lability_timeZone      = 'US Mountain Standard Time' #[System.TimeZoneInfo]::GetSystemTimeZones()
            Lability_Media         = '2016_x64_Standard_EN_Eval'
            Lability_StartupMemory = 4GB
            Lability_MinimumMemory = 4GB
        }

    )

    NonNodeData = @{
        Lability = @{
            # You can uncomment this line to add a prefix to the virtual machine name.
            # It will not change the guest computername
            # See https://github.com/pluralsight/PS-AutoLab-Env/blob/master/Detailed-Setup-Instructions.md
            # for more information.

            #EnvironmentPrefix = 'AutoLab-'
            Media       = (
                @{
                    ## This media is a replica of the default '2016_x64_Standard_Nano_EN_Eval' media
                    ## with the additional 'Microsoft-NanoServer-DSC-Package' package added.
                    Id              = '2016_x64_Standard_Nano_DSC_EN_Eval'
                    Filename        = '2016_x64_EN_Eval.iso'
                    Description     = 'Windows Server 2016 Standard Nano 64bit English Evaluation'
                    Architecture    = 'x64'
                    ImageName       = 'Windows Server 2016 SERVERSTANDARDNANO'
                    MediaType       = 'ISO'
                    OperatingSystem = 'Windows'
                    Uri             = 'http://download.microsoft.com/download/1/6/F/16FA20E6-4662-482A-920B-1A45CF5AAE3C/14393.0.160715-1616.RS1_RELEASE_SERVER_EVAL_X64FRE_EN-US.ISO'
                    Checksum        = '18A4F00A675B0338F3C7C93C4F131BEB'
                    CustomData      = @{
                        SetupComplete = 'CoreCLR'
                        PackagePath   = '\NanoServer\Packages'
                        PackageLocale = 'en-US'
                        WimPath       = '\NanoServer\NanoServer.wim'
                        Package       = @(
                            'Microsoft-NanoServer-Guest-Package',
                            'Microsoft-NanoServer-DSC-Package'
                        )
                    }
                }
            ) # Custom media additions that are different than the supplied defaults (media.json)
            Network     = @( # Virtual switch in Hyper-V
                @{ Name = 'LabNet'; Type = 'Internal'; NetAdapterName = 'Ethernet'; AllowManagementOS = $true }
            )
            DSCResource = @(
                ## Download published version from the PowerShell Gallery or Github
                @{ Name = 'xComputerManagement'; RequiredVersion = '4.1.0.0'; Provider = 'PSGallery' },
                @{ Name = 'xNetworking'; RequiredVersion = '5.7.0.0'; Provider = 'PSGallery' },
                @{ Name = 'xWindowsUpdate' ; RequiredVersion = '2.8.0.0'; Provider = 'PSGallery' },
                @{ Name = 'xPSDesiredStateConfiguration'; RequiredVersion = '9.1.0';Provider = 'PSGallery' }
                @{ Name = 'ComputerManagementDSC'; RequiredVersion = '8.5.0'; Provider = 'PSGallery' }
            )
            Resource    = @(
                @{
                    Id       = 'Win10RSAT'
                    Filename = 'WindowsTH-RSAT_WS2016-x64.msu'
                    Uri      = 'https://download.microsoft.com/download/1/D/8/1D8B5022-5477-4B9A-8104-6A71FF9D98AB/WindowsTH-RSAT_WS2016-x64.msu'
                    Expand   = $false
                    #DestinationPath = '\software' # Default is resources folder
                }
            )
        }
    }
}
