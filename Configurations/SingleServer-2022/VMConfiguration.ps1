
Configuration AutoLab {

    $LabData = Import-PowerShellDataFile -Path $PSScriptRoot\*.psd1
    $Secure = ConvertTo-SecureString -String "$($LabData.AllNodes.LabPassword)" -AsPlainText -Force
    $credential = New-Object -TypeName PSCredential -ArgumentList Administrator, $secure

    #region DSC Resources
    Import-DSCresource -ModuleName 'PSDesiredStateConfiguration' -ModuleVersion '1.1'
    Import-DSCResource -ModuleName 'xPSDesiredStateConfiguration' -ModuleVersion  '9.1.0'
    Import-DSCResource -ModuleName 'xComputerManagement' -ModuleVersion  '4.1.0.0'
    Import-DSCResource -ModuleName 'xNetworking' -ModuleVersion  '5.7.0.0'

    #endregion
    #region All Nodes
    node $AllNodes.Where( { $true }).NodeName {
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
            Ensure    = 'present'
            Key       = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NetFramework\v4.0.30319'
            ValueName = 'SchUseStrongCrypto'
            ValueData = '1'
            ValueType = 'DWord'
        }

        #endregion

        #region Remove PowerShell v2

        WindowsFeature PS2 {
            Name   = 'PowerShell-V2'
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

        $LabData = Import-PowerShellDataFile -Path $PSScriptRoot\*.psd1
        $FireWallRules = $LabData.AllNodes.FirewallRuleNames

        foreach ($Rule in $FireWallRules) {
            xFirewall $Rule {
                Name    = $Rule
                Enabled = 'True'
            }
        } #End foreach

    } #end Firewall Rules
    #endregion

} # End AllNodes
#endregion

AutoLab -OutputPath $PSScriptRoot -ConfigurationData $PSScriptRoot\*.psd1

