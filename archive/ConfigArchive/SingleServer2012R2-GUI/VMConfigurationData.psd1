<# Notes:

Authors: Jason Helmick, Melissa (Missy) Januszko, and Jeff Hicks

The bulk of this DC, DHCP, ADCS config is authored by Melissa (Missy) Januszko and Jason Helmick.
Currently on her public DSC hub located here: https://github.com/majst32/DSC_public.git

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
            DnsServerAddress            = '1.1.1.1'

            # Firewall settings to enable
            FirewallRuleNames           = @(
                'FPS-ICMP4-ERQ-In',
                'FPS-ICMP6-ERQ-In',
                'FPS-SMB-In-TCP',
                'WMI-WINMGMT-In-TCP-NoScope',
                'WMI-WINMGMT-Out-TCP-NoScope',
                'WMI-WINMGMT-In-TCP',
                'WMI-WINMGMT-Out-TCP'
            )

            PSDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser        = $true

            # Lability default node settings
            Lability_SwitchName         = 'LabNet'
            Lability_ProcessorCount     = 1
            Lability_MinimumMemory      = 1GB
            Lability_MaximumMemory      = 4GB
            SecureBoot                  = $false
            Lability_Media              = '2012R2_x64_Standard_EN_V5_1_Eval'

            <#

            Id                                      Description
            --                                      -----------
            2019_x64_Standard_EN_Eval               Windows Server 2019 Standard 64bit English Evaluation with Desktop Experience
            2019_x64_Standard_EN_Core_Eval          Windows Server 2019 Standard 64bit English Evaluation
            2019_x64_Datacenter_EN_Eval             Windows Server 2019 Datacenter 64bit English Evaluation with Desktop Experience
            2019_x64_Datacenter_EN_Core_Eval        Windows Server 2019 Datacenter Evaluation in Core mode
            2016_x64_Standard_EN_Eval               Windows Server 2016 Standard 64bit English Evaluation
            2016_x64_Standard_Core_EN_Eval          Windows Server 2016 Standard Core 64bit English Evaluation
            2016_x64_Datacenter_EN_Eval             Windows Server 2016 Datacenter 64bit English Evaluation
            2016_x64_Datacenter_Core_EN_Eval        Windows Server 2016 Datacenter Core 64bit English Evaluation
            2016_x64_Standard_Nano_EN_Eval          Windows Server 2016 Standard Nano 64bit English Evaluation
            2016_x64_Datacenter_Nano_EN_Eval        Windows Server 2016 Datacenter Nano 64bit English Evaluation
            2012R2_x64_Standard_EN_Eval             Windows Server 2012 R2 Standard 64bit English Evaluation
            2012R2_x64_Standard_EN_V5_Eval          Windows Server 2012 R2 Standard 64bit English Evaluation with WMF 5
            2012R2_x64_Standard_EN_V5_1_Eval        Windows Server 2012 R2 Standard 64bit English Evaluation with WMF 5.1
            2012R2_x64_Standard_Core_EN_Eval        Windows Server 2012 R2 Standard Core 64bit English Evaluation
            2012R2_x64_Standard_Core_EN_V5_Eval     Windows Server 2012 R2 Standard Core 64bit English Evaluation with WMF 5
            2012R2_x64_Standard_Core_EN_V5_1_Eval   Windows Server 2012 R2 Standard Core 64bit English Evaluation with WMF 5.1
            2012R2_x64_Datacenter_EN_Eval           Windows Server 2012 R2 Datacenter 64bit English Evaluation
            2012R2_x64_Datacenter_EN_V5_Eval        Windows Server 2012 R2 Datacenter 64bit English Evaluation with WMF 5
            2012R2_x64_Datacenter_EN_V5_1_Eval      Windows Server 2012 R2 Datacenter 64bit English Evaluation with WMF 5.1
            2012R2_x64_Datacenter_Core_EN_Eval      Windows Server 2012 R2 Datacenter Core 64bit English Evaluation
            2012R2_x64_Datacenter_Core_EN_V5_Eval   Windows Server 2012 R2 Datacenter Core 64bit English Evaluation with WMF 5
            2012R2_x64_Datacenter_Core_EN_V5_1_Eval Windows Server 2012 R2 Datacenter Core 64bit English Evaluation with WMF 5.1
            WIN81_x64_Enterprise_EN_Eval            Windows 8.1 64bit Enterprise English Evaluation
            WIN81_x64_Enterprise_EN_V5_Eval         Windows 8.1 64bit Enterprise English Evaluation with WMF 5
            WIN81_x64_Enterprise_EN_V5_1_Eval       Windows 8.1 64bit Enterprise English Evaluation with WMF 5.1
            WIN81_x86_Enterprise_EN_Eval            Windows 8.1 32bit Enterprise English Evaluation
            WIN81_x86_Enterprise_EN_V5_Eval         Windows 8.1 32bit Enterprise English Evaluation with WMF 5
            WIN81_x86_Enterprise_EN_V5_1_Eval       Windows 8.1 32bit Enterprise English Evaluation with WMF 5.1
            WIN10_x64_Enterprise_EN_Eval            Windows 10 64bit Enterprise 1903 English Evaluation
            WIN10_x86_Enterprise_EN_Eval            Windows 10 32bit Enterprise 1903 English Evaluation
            WIN10_x64_Enterprise_LTSC_EN_Eval       Windows 10 64bit Enterprise LTSC 2019 English Evaluation
            WIN10_x86_Enterprise_LTSC_EN_Eval       Windows 10 32bit Enterprise LTSC 2019 English Evaluation
            #>
        },

        <#    Available Roles for computers
        DC = Domain Controller
        DHCP = Dynamic Host Configuration Protocol
        ADCS = Active Directory Certificate SErvices - plus autoenrollment GPO's and DSC and web server certs
        Web = Basic web server
        RSAT = Remote Server Administration Tools for the client
        RDP = enables RDP and opens up required firewall rules
        DomainJoin = joins a computer to the domain
#>

        @{
            NodeName                = 'S12R2GUI'
            IPAddress               = '192.168.3.122'
            Lability_BootOrder      = 20
            Lability_timeZone       = 'US Mountain Standard Time'
            Lability_Media          = '2012R2_x64_Standard_EN_V5_1_Eval'
            Lability_ProcessorCount = 1
            Lability_StartupMemory  = 4GB
            Lability_MinimumMemory  = 4GB
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
            Network     = @( # Virtual switch in Hyper-V
                @{ Name = 'LabNet'; Type = 'Internal'; NetAdapterName = 'Ethernet'; AllowManagementOS = $true }
            )
            DSCResource = @(
                ## Download published version from the PowerShell Gallery or Github
                @{ Name = 'xPSDesiredStateConfiguration'; RequiredVersion = '9.1.0'; Provider = 'PSGallery' },
                @{ Name = 'xComputerManagement'; RequiredVersion = '4.1.0.0'; Provider = 'PSGallery' },
                @{ Name = 'xNetworking'; RequiredVersion = '5.7.0.0'; Provider = 'PSGallery' }

            )
            Resource    = @(
                @{ }
            )
        }
    }
}
