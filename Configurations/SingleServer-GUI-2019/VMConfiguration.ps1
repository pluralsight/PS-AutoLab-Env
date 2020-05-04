<# Notes:

Authors: Jason Helmick and Melissa (Missy) Januszko

The bulk of this DC, DHCP, ADCS config is authored by Melissa (Missy) Januszko and Jason Helmick.
Currently on her public DSC hub located here: https://github.com/majst32/DSC_public.git

Additional contributors of note: Jeff Hicks

Disclaimer
This example code is provided without copyright and AS IS.  It is free for you to use and modify.

#>

Configuration AutoLab {

    $LabData = Import-PowerShellDataFile -Path $PSScriptRoot\*.psd1
    $Secure = ConvertTo-SecureString -String "$($labdata.allnodes.labpassword)" -AsPlainText -Force
    $credential = New-Object -typename Pscredential -ArgumentList Administrator, $secure

    #region DSC Resources
    Import-DSCresource -Modulename @{ModuleName = "PSDesiredStateConfiguration";ModuleVersion="1.1"},
    @{ModuleName = "xPSDesiredStateConfiguration"; ModuleVersion = "9.1.0"},
    @{ModuleName = "xComputerManagement"; ModuleVersion = "4.1.0.0"},
    @{ModuleName = "xNetworking"; ModuleVersion = "5.7.0.0"},
    @{ModuleName = 'xWindowsUpdate'; ModuleVersion = '2.8.0.0'},
    @{ModuleName = 'xPendingReboot'; ModuleVersion = '0.4.0.0'}

    #endregion
    #region All Nodes
    node $AllNodes.Where({$true}).NodeName {
        #endregion
        #region LCM configuration

        LocalConfigurationManager {
            RebootNodeIfNeeded   = $true
            AllowModuleOverwrite = $true
            ConfigurationMode    = 'ApplyOnly'
        }

        #endregion

        #region TLS Settings in registry

        registry TLS {
            Ensure = "present"
            Key =  'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NetFramework\v4.0.30319' 
            ValueName = 'SchUseStrongCrypto'
            ValueData = '1'
            ValueType = 'DWord'
        }

        #endregion

        #region Remove PowerShell v2

        WindowsFeature PS2 {
            Name = 'PowerShell-V2'
            Ensure = 'Absent'
        }

        #region

        #region IPaddress settings

        If (-not [System.String]::IsNullOrEmpty($node.IPAddress)) {
            xIPAddress 'PrimaryIPAddress' {
                IPAddress      = $node.IPAddress
                InterfaceAlias = $node.InterfaceAlias
                AddressFamily  = $node.AddressFamily
            }

            If (-not [System.String]::IsNullOrEmpty($node.DefaultGateway)) {
                xDefaultGatewayAddress 'PrimaryDefaultGateway' {
                    InterfaceAlias = $node.InterfaceAlias
                    Address        = $node.DefaultGateway
                    AddressFamily  = $node.AddressFamily
                }
            }

            If (-not [System.String]::IsNullOrEmpty($node.DnsServerAddress)) {
                xDnsServerAddress 'PrimaryDNSClient' {
                    Address        = $node.DnsServerAddress
                    InterfaceAlias = $node.InterfaceAlias
                    AddressFamily  = $node.AddressFamily
                }
            }

            If (-not [System.String]::IsNullOrEmpty($node.DnsConnectionSuffix)) {
                xDnsConnectionSuffix 'PrimaryConnectionSuffix' {
                    InterfaceAlias           = $node.InterfaceAlias
                    ConnectionSpecificSuffix = $node.DnsConnectionSuffix
                }
            }
        } #End IF

        #endregion

        #region Firewall Rules

        $LabData = Import-PowerShellDataFile .\*.psd1
        $FireWallRules = $labdata.Allnodes.FirewallRuleNames

        foreach ($Rule in $FireWallRules) {
            xFirewall $Rule {
                Name    = $Rule
                Enabled = 'True'
            }
        } #End foreach

    } #end Firewall Rules
    #endregion


    #region RSAT config
    node $AllNodes.Where( {$_.Role -eq 'RSAT'}).NodeName {
        # Adds RSAT

        xHotfix RSAT {
            Id         = 'KB2693643'
            Path       = 'c:\Resources\WindowsTH-RSAT_WS2016-x64.msu'
            Credential = $DomainCredential
            DependsOn  = '[xcomputer]JoinDC'
            Ensure     = 'Present'
        }

        xPendingReboot Reboot {
            Name      = 'AfterRSATInstall'
            DependsOn = '[xHotFix]RSAT'
        }


    }#end RSAT Config

    #region RDP config
    node $AllNodes.Where( {$_.Role -eq 'RDP'}).NodeName {
        # Adds RDP support and opens Firewall rules

        Registry RDP {
            Key       = 'HKLM:\System\ControlSet001\Control\Terminal Server'
            ValueName = 'fDenyTSConnections'
            ValueType = 'Dword'
            ValueData = '0'
            Ensure    = 'Present'
        }
        foreach ($Rule in @(
                'RemoteDesktop-UserMode-In-TCP',
                'RemoteDesktop-UserMode-In-UDP',
                'RemoteDesktop-Shadow-In-TCP'
            )) {
            xFirewall $Rule {
                Name      = $Rule
                Enabled   = 'True'
                DependsOn = '[Registry]RDP'
            }
        } # End RDP
    }
    #endregion

} # End AllNodes
#endregion

AutoLab -OutputPath $PSScriptRoot -ConfigurationData $PSScriptRoot\*.psd1

