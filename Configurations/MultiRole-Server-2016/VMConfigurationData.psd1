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
            DnsServerAddress            = '192.168.3.10'

            # Firewall settings to enable
            FirewallRuleNames           = @(
                'FPS-ICMP4-ERQ-In';
                'FPS-ICMP6-ERQ-In';
                'FPS-SMB-In-TCP'
            )

            # Domain and Domain Controller information
            DomainName                  = "Company.Pri"
            DomainDN                    = "DC=Company,DC=Pri"
            DCDatabasePath              = "C:\NTDS"
            DCLogPath                   = "C:\NTDS"
            SysvolPath                  = "C:\Sysvol"
            PSDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser        = $true

            # DHCP Server Data
            DHCPName                    = 'LabNet'
            DHCPIPStartRange            = '192.168.3.200'
            DHCPIPEndRange              = '192.168.3.250'
            DHCPSubnetMask              = '255.255.255.0'
            DHCPState                   = 'Active'
            DHCPAddressFamily           = 'IPv4'
            DHCPLeaseDuration           = '00:08:00'
            DHCPScopeID                 = '192.168.3.0'
            DHCPDnsServerIPAddress      = '192.168.3.10'
            DHCPRouter                  = '192.168.3.1'

            # ADCS Certificate Services information
            CACN                        = 'Company.Pri'
            CADNSuffix                  = "C=US,L=Phoenix,S=Arizona,O=Company"
            CADatabasePath              = "C:\windows\system32\CertLog"
            CALogPath                   = "C:\CA_Logs"
            ADCSCAType                  = 'EnterpriseRootCA'
            ADCSCryptoProviderName      = 'RSA#Microsoft Software Key Storage Provider'
            ADCSHashAlgorithmName       = 'SHA256'
            ADCSKeyLength               = 2048
            ADCSValidityPeriod          = 'Years'
            ADCSValidityPeriodUnits     = 2

            # Lability default node settings
            Lability_SwitchName         = 'LabNet'
            Lability_ProcessorCount     = 1
            Lability_MinimumMemory      = 1GB
            SecureBoot                  = $false
            Lability_Media              = '2016_x64_Standard_Core_EN_Eval'
        }
        <#

Id                                      Arch Media Description
--                                      ---- ----- -----------
2019_x64_Standard_EN_Eval                x64   ISO Windows Server 2019 Standard 64bit English Evaluation with Desktop Experience
2019_x64_Standard_EN_Core_Eval           x64   ISO Windows Server 2019 Standard 64bit English Evaluation
2019_x64_Datacenter_EN_Eval              x64   ISO Windows Server 2019 Datacenter 64bit English Evaluation with Desktop Experience
2019_x64_Datacenter_EN_Core_Eval         x64   ISO Windows Server 2019 Datacenter Evaluation in Core mode
2016_x64_Standard_EN_Eval                x64   ISO Windows Server 2016 Standard 64bit English Evaluation
2016_x64_Standard_Core_EN_Eval           x64   ISO Windows Server 2016 Standard Core 64bit English Evaluation
2016_x64_Datacenter_EN_Eval              x64   ISO Windows Server 2016 Datacenter 64bit English Evaluation
2016_x64_Datacenter_Core_EN_Eval         x64   ISO Windows Server 2016 Datacenter Core 64bit English Evaluation
2016_x64_Standard_Nano_EN_Eval           x64   ISO Windows Server 2016 Standard Nano 64bit English Evaluation
2016_x64_Datacenter_Nano_EN_Eval         x64   ISO Windows Server 2016 Datacenter Nano 64bit English Evaluation
2012R2_x64_Standard_EN_Eval              x64   ISO Windows Server 2012 R2 Standard 64bit English Evaluation
2012R2_x64_Standard_EN_V5_Eval           x64   ISO Windows Server 2012 R2 Standard 64bit English Evaluation with WMF 5
2012R2_x64_Standard_EN_V5_1_Eval         x64   ISO Windows Server 2012 R2 Standard 64bit English Evaluation with WMF 5.1
2012R2_x64_Standard_Core_EN_Eval         x64   ISO Windows Server 2012 R2 Standard Core 64bit English Evaluation
2012R2_x64_Standard_Core_EN_V5_Eval      x64   ISO Windows Server 2012 R2 Standard Core 64bit English Evaluation with WMF 5
2012R2_x64_Standard_Core_EN_V5_1_Eval    x64   ISO Windows Server 2012 R2 Standard Core 64bit English Evaluation with WMF 5.1
2012R2_x64_Datacenter_EN_Eval            x64   ISO Windows Server 2012 R2 Datacenter 64bit English Evaluation
2012R2_x64_Datacenter_EN_V5_Eval         x64   ISO Windows Server 2012 R2 Datacenter 64bit English Evaluation with WMF 5
2012R2_x64_Datacenter_EN_V5_1_Eval       x64   ISO Windows Server 2012 R2 Datacenter 64bit English Evaluation with WMF 5.1
2012R2_x64_Datacenter_Core_EN_Eval       x64   ISO Windows Server 2012 R2 Datacenter Core 64bit English Evaluation
2012R2_x64_Datacenter_Core_EN_V5_Eval    x64   ISO Windows Server 2012 R2 Datacenter Core 64bit English Evaluation with WMF 5
2012R2_x64_Datacenter_Core_EN_V5_1_Eval  x64   ISO Windows Server 2012 R2 Datacenter Core 64bit English Evaluation with WMF 5.1
WIN81_x64_Enterprise_EN_Eval             x64   ISO Windows 8.1 64bit Enterprise English Evaluation
WIN81_x64_Enterprise_EN_V5_Eval          x64   ISO Windows 8.1 64bit Enterprise English Evaluation with WMF 5
WIN81_x64_Enterprise_EN_V5_1_Eval        x64   ISO Windows 8.1 64bit Enterprise English Evaluation with WMF 5.1
WIN81_x86_Enterprise_EN_Eval             x86   ISO Windows 8.1 32bit Enterprise English Evaluation
WIN81_x86_Enterprise_EN_V5_Eval          x86   ISO Windows 8.1 32bit Enterprise English Evaluation with WMF 5
WIN81_x86_Enterprise_EN_V5_1_Eval        x86   ISO Windows 8.1 32bit Enterprise English Evaluation with WMF 5.1
WIN10_x64_Enterprise_20H2_EN_Eval        x64   ISO Windows 10 64bit Enterprise 2009 English Evaluation (20H2)
WIN10_x86_Enterprise_20H2_EN_Eval        x86   ISO Windows 10 32bit Enterprise 2009 English Evaluation
WIN10_x64_Enterprise_LTSC_EN_Eval        x64   ISO Windows 10 64bit Enterprise LTSC 2019 English Evaluation
WIN10_x86_Enterprise_LTSC_EN_Eval        x86   ISO Windows 10 32bit Enterprise LTSC 2019 English Evaluation

        #>

        <#    Available Roles for computers
        DC = Domain Controller
        DHCP = Dynamic Host Configuration Protocol
        ADCS = Active Directory Certificate SErvices - plus autoenrollment GPO's and DSC and web server certs
        Web = Basic web server
        RSAT = Remote Server Administration Tools for the client
        RDP = enables RDP and opens up required firewall rules
        DomainJoin = joions a computer to the domain
#>
        @{
            NodeName                = 'DC1'
            IPAddress               = '192.168.3.10'
            Role                    = @('DC', 'DHCP', 'ADCS')
            Lability_BootOrder      = 10
            Lability_BootDelay      = 60 # Number of seconds to delay before others
            Lability_timeZone       = 'US Mountain Standard Time' #[System.TimeZoneInfo]::GetSystemTimeZones()
            Lability_Media          = '2016_x64_Standard_Core_EN_Eval'
            Lability_MinimumMemory  = 2GB
            Lability_ProcessorCount = 2
            CustomBootStrap         = @'
                    # This must be set to handle larger .mof files
                    Set-Item -path wsman:\localhost\maxenvelopesize -value 1000
'@
        }

        @{
            NodeName           = 'S1'
            IPAddress          = '192.168.3.50'
            #Role = 'DomainJoin' # example of multiple roles @('DomainJoin', 'Web')
            Role               = @('DomainJoin', 'Web')
            Lability_BootOrder = 20
            Lability_timeZone  = 'US Mountain Standard Time' #[System.TimeZoneInfo]::GetSystemTimeZones()
            Lability_Media     = '2016_x64_Standard_Core_EN_Eval'
        }
<#
@{
    NodeName                = 'N1'
    IPAddress               = '192.168.3.60'
    #Role = 'Nano'
    Lability_BootOrder      = 20
    Lability_Media          = '2016_x64_Standard_Nano_DSC_EN_Eval'
    Lability_ProcessorCount = 1
    Lability_StartupMemory  = 1GB
}
#>

        @{
            NodeName                = 'Cli1'
            IPAddress               = '192.168.3.100'
            Role                    = @('domainJoin', 'RSAT', 'RDP')
            Lability_ProcessorCount = 2
            Lability_MinimumMemory  = 2GB
            Lability_Media          = 'WIN10_x64_Enterprise_20H2_EN_Eval'
            Lability_BootOrder      = 20
            Lability_timeZone       = 'US Mountain Standard Time' #[System.TimeZoneInfo]::GetSystemTimeZones()
            Lability_Resource       = @()
            CustomBootStrap         = @'
                    # To enable PSRemoting on the client
                    Enable-PSRemoting -SkipNetworkProfileCheck -Force;
'@
        }
        #>

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
                    <#
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
                        #>
                }
            ) # Custom media additions that are different than the supplied defaults (media.json)
            Network     = @( # Virtual switch in Hyper-V
                @{ Name = 'LabNet'; Type = 'Internal'; NetAdapterName = 'Ethernet'; AllowManagementOS = $true }
            )
            DSCResource = @(
                ## Download published version from the PowerShell Gallery or Github
                @{ Name = 'xActiveDirectory'; RequiredVersion = '3.0.0.0'; Provider = 'PSGallery' },
                @{ Name = 'xComputerManagement'; RequiredVersion = '4.1.0.0'; Provider = 'PSGallery' },
                @{ Name = 'xNetworking'; RequiredVersion = '5.7.0.0'; Provider = 'PSGallery' },
                @{ Name = 'xDhcpServer'; RequiredVersion = '3.0.0'; Provider = 'PSGallery' },
                @{ Name = 'xWindowsUpdate' ; RequiredVersion = '2.8.0.0'; Provider = 'PSGallery' },
                @{ Name = 'xPSDesiredStateConfiguration'; RequiredVersion = '9.1.0';Provider = 'PSGallery' }
                @{ Name = 'xADCSDeployment'; RequiredVersion = '1.4.0.0';Provider = 'PSGallery' }

            )
            Resource    = @(
                @{

                }
            )
        }
    }
}
