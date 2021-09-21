#requires -version 5.1

<# Notes:

Authors: Jason Helmick,Melissa (Missy) Januszko, and Jeff Hicks

The bulk of this DC, DHCP, ADCS config is authored by Melissa (Missy) Januszko and Jason Helmick.
Currently on her public DSC hub located here: https://github.com/majst32/DSC_public.git

Disclaimer
This example code is provided without copyright and AS IS.  It is free for you to use and modify.

#>


Configuration AutoLab {

    $LabData = Import-PowerShellDataFile -Path $PSScriptroot\VMConfigurationData.psd1
    $Secure = ConvertTo-SecureString -String "$($labdata.allnodes.labpassword)" -AsPlainText -Force
    $credential = New-Object -typename Pscredential -ArgumentList Administrator, $secure

    Import-DscResource -ModuleName "PSDesiredStateConfiguration" -ModuleVersion "1.1"
    Import-DscResource -ModuleName "xPSDesiredStateConfiguration" -ModuleVersion "9.1.0"
    Import-DscResource -ModuleName "xComputerManagement" -ModuleVersion "4.1.0.0"
    Import-DscResource -ModuleName "xNetworking" -ModuleVersion "5.7.0.0"
    Import-DscResource -ModuleName "xWindowsUpdate" -ModuleVersion "2.8.0.0"
    Import-DscResource -ModuleName "xPendingReboot" -ModuleVersion "0.4.0.0"

    Node $AllNodes.Where( { $true }).NodeName {
        xComputer ComputerName {
            Name          = $Node.NodeName
            WorkGroupName = "Lab"
        }

        #region TLS Settings in registry

        registry TLS {
            Ensure = "present"
            Key =  'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NetFramework\v4.0.30319'
            ValueName = 'SchUseStrongCrypto'
            ValueData = '1'
            ValueType = 'DWord'
        }

        #endregion

        user Administrator {
            UserName               = "Administrator"
            Disabled               = $false
            Password               = $credential
            PasswordChangeRequired = $false
            PasswordNeverExpires   = $True
        }

        #create a local account with the same name as the person
        #running this config
        user $env:username {
            UserName               = $env:username
            Disabled               = $false
            Password               = $credential
            PasswordChangeRequired = $false
            PasswordNeverExpires   = $True
        }

        #add the user to the local Administrators group
        group Administrators {
            GroupName        = "Administrators"
            MembersToInclude = $env:username
            DependsOn        = "[user]$($env:username)"
        }

        #force a reboot after completing everything
        xPendingReboot Complete {
            Name                      = "Post-Config Reboot"
            SkipPendingComputerRename = $True
            DependsOn                 = @("[group]Administrators", "[xComputer]ComputerName", "[user]Administrator")
        }

        #region LCM configuration
        LocalConfigurationManager {
            RebootNodeIfNeeded   = $true
            AllowModuleOverwrite = $true
            ConfigurationMode    = 'ApplyOnly'
        }
        #endregion

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

        $FireWallRules = $labdata.Allnodes.FirewallRuleNames

        foreach ($Rule in $FireWallRules) {
            xFirewall $Rule {
                Name    = $Rule
                Enabled = 'True'
            }
        } #End foreach
    }
    #endregion

    #region RSAT config
    node $AllNodes.Where( { $_.Role -eq 'RSAT' }).NodeName {
        Script RSAT {
            # Adds RSAT which is now a Windows Capability in Windows 10
                   TestScript = {
                       $rsat = @(
                           'Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0',
                           'Rsat.BitLocker.Recovery.Tools~~~~0.0.1.0',
                           'Rsat.CertificateServices.Tools~~~~0.0.1.0',
                           'Rsat.DHCP.Tools~~~~0.0.1.0',
                           'Rsat.Dns.Tools~~~~0.0.1.0',
                           'Rsat.FailoverCluster.Management.Tools~~~~0.0.1.0',
                           'Rsat.FileServices.Tools~~~~0.0.1.0',
                           'Rsat.GroupPolicy.Management.Tools~~~~0.0.1.0',
                           'Rsat.IPAM.Client.Tools~~~~0.0.1.0',
                           'Rsat.ServerManager.Tools~~~~0.0.1.0'
                       )
                       $packages = $rsat | ForEach-Object { Get-WindowsCapability -Online -Name $_ }
                       if ($packages.state -contains "NotPresent") {
                           Return $False
                       }
                       else {
                           Return $True
                       }
                   } #test

                   GetScript  = {
                       $rsat = @(
                           'Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0',
                           'Rsat.BitLocker.Recovery.Tools~~~~0.0.1.0',
                           'Rsat.CertificateServices.Tools~~~~0.0.1.0',
                           'Rsat.DHCP.Tools~~~~0.0.1.0',
                           'Rsat.Dns.Tools~~~~0.0.1.0',
                           'Rsat.FailoverCluster.Management.Tools~~~~0.0.1.0',
                           'Rsat.FileServices.Tools~~~~0.0.1.0',
                           'Rsat.GroupPolicy.Management.Tools~~~~0.0.1.0',
                           'Rsat.IPAM.Client.Tools~~~~0.0.1.0',
                           'Rsat.ServerManager.Tools~~~~0.0.1.0'
                       )
                       $packages = $rsat | ForEach-Object { Get-WindowsCapability -Online -Name $_ } | Select-Object Displayname, State
                       $installed = $packages.Where({ $_.state -eq "Installed" })
                       Return @{Result = "$($installed.count)/$($packages.count) RSAT features installed" }
                   } #get

                   SetScript  = {
                       $rsat = @(
                           'Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0',
                           'Rsat.BitLocker.Recovery.Tools~~~~0.0.1.0',
                           'Rsat.CertificateServices.Tools~~~~0.0.1.0',
                           'Rsat.DHCP.Tools~~~~0.0.1.0',
                           'Rsat.Dns.Tools~~~~0.0.1.0',
                           'Rsat.FailoverCluster.Management.Tools~~~~0.0.1.0',
                           'Rsat.FileServices.Tools~~~~0.0.1.0',
                           'Rsat.GroupPolicy.Management.Tools~~~~0.0.1.0',
                           'Rsat.IPAM.Client.Tools~~~~0.0.1.0',
                           'Rsat.ServerManager.Tools~~~~0.0.1.0'
                       )
                       foreach ($item in $rsat) {
                           $pkg = Get-WindowsCapability -Online -Name $item
                           if ($item.state -ne 'Installed') {
                               Add-WindowsCapability -Online -Name $item
                           }
                       }

                   } #set

               } #rsat script resource


    } #end RSAT Config

    #region RDP config
    node $AllNodes.Where( { $_.Role -eq 'RDP' }).NodeName {
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
}

AutoLab -OutputPath $PSScriptRoot -ConfigurationData $PSScriptRoot\VMConfigurationData.psd1

