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
            Lability_MinimumMemory      = 2GB
            Lability_MaximumMemory      = 4GB
            SecureBoot                  = $false
            Lability_Media              = '2022_x64_Standard_EN_Core_Eval'

            },
            <#
            Available Roles for computers
            DC = Domain Controller
            DHCP = Dynamic Host Configuration Protocol
            ADCS = Active Directory Certificate Services - plus autoenrollment GPO's and DSC and web server certs
            Web = Basic web server
            RSAT = Remote Server Administration Tools for the client
            RDP = enables RDP and opens up required firewall rules
            DomainJoin = joins a computer to the domain
            #>

        @{
            NodeName                = 'SERVER1'
            IPAddress               = '192.168.3.22'
            Role                   = @('RDP')
            Lability_BootOrder      = 20
            Lability_Media          = '2022_x64_Standard_EN_Core_Eval'
            Lability_ProcessorCount = 1
            Lability_StartupMemory  = 2147483648
        }
        ) #all nodes

    NonNodeData = @{
        Lability = @{

            # You can uncomment this line to add a prefix to the virtual machine name.
            # It will not change the guest computername
            # See https://github.com/pluralsight/PS-AutoLab-Env/blob/master/Detailed-Setup-Instructions.md
            # for more information.

            #EnvironmentPrefix = 'AutoLab-'

            Network     = @( # Virtual switch in Hyper-V
                @{ Name = 'LabNet'; Type = 'Internal'; NetAdapterName = 'Ethernet'; AllowManagementOS = $true; }
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

        } #lability
    } #nonNodeData
}
