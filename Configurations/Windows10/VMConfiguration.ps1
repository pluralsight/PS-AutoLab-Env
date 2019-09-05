#requires -version 5.0

<# Notes:

Authors: Jason Helmick,Melissa (Missy) Januszko, and Jeff Hicks

The bulk of this DC, DHCP, ADCS config is authored by Melissa (Missy) Januszko and Jason Helmick.
Currently on her public DSC hub located here: https://github.com/majst32/DSC_public.git


Disclaimer

This example code is provided without copyright and AS IS.  It is free for you to use and modify.
Note: These demos should not be run as a script. These are the commands that I use in the
demonstrations and would need to be modified for your environment.

#>

Configuration AutoLab {

$LabData = Import-PowerShellDataFile -Path .\VMConfigurationData.psd1
$Secure = ConvertTo-SecureString -String "$($labdata.allnodes.labpassword)" -AsPlainText -Force
$credential = New-Object -typename Pscredential -ArgumentList Administrator, $secure

Import-DscResource -ModuleName "PSDesiredStateConfiguration" -ModuleVersion "1.1"
Import-DscResource -ModuleName "xPSDesiredStateConfiguration" -ModuleVersion "8.9.0.0"
Import-DscResource -ModuleName "xComputerManagement" -ModuleVersion "1.8.0.0"
Import-DscResource -ModuleName "xNetworking" -ModuleVersion "5.7.0.0"
Import-DscResource -ModuleName "xWindowsUpdate" -ModuleVersion "2.8.0.0"
Import-DscResource -ModuleName "xPendingReboot" -ModuleVersion "0.3.0.0"

    Node $AllNodes.Where({$true}).NodeName {
         xComputer ComputerName {
            Name = $Node.NodeName
            WorkGroupName = "Lab"
        }
         user Administrator {
            UserName = "Administrator"
            Disabled = $false
            Password = $credential
            PasswordChangeRequired = $false
            PasswordNeverExpires = $True
         }

         #create a local account with the same name as the person
         #running this config
         user $env:username {
            UserName = $env:username
            Disabled = $false
            Password = $credential
            PasswordChangeRequired = $false
            PasswordNeverExpires = $True
         }

         #add the user to the local Administrators group
         group Administrators {
             GroupName = "Administrators"
             MembersToInclude = $env:username
             DependsOn = "[user]$($env:username)"
         }

         #force a reboot after completing everything
         xPendingReboot Complete {
            Name = "Post-Config Reboot"
            SkipPendingComputerRename = $True
            DependsOn = @("[group]Administrators","[xComputer]ComputerName","[user]Administrator")
         }

#region LCM configuration
        LocalConfigurationManager {
            RebootNodeIfNeeded   = $true
            AllowModuleOverwrite = $true
            ConfigurationMode = 'ApplyOnly'
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
                Address = $node.DefaultGateway
                AddressFamily = $node.AddressFamily
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
                InterfaceAlias = $node.InterfaceAlias
                ConnectionSpecificSuffix = $node.DnsConnectionSuffix
            }
        }
    } #End IF

#endregion

#region Firewall Rules

    $FireWallRules = $labdata.Allnodes.FirewallRuleNames

        foreach ($Rule in $FireWallRules) {
        xFirewall $Rule {
            Name = $Rule
            Enabled = 'True'
         }
        } #End foreach
    }
#endregion

#region RSAT config
   node $AllNodes.Where({$_.Role -eq 'RSAT'}).NodeName {
        # Adds RSAT

        xHotfix RSAT {
            Id = 'KB2693643'
            Path = 'c:\Resources\WindowsTH-RSAT_WS2016-x64.msu'
            Ensure = 'Present'
        }

    } #end RSAT Config

#region RDP config
   node $AllNodes.Where({$_.Role -eq 'RDP'}).NodeName {
        # Adds RDP support and opens Firewall rules

        Registry RDP {
            Key = 'HKLM:\System\ControlSet001\Control\Terminal Server'
            ValueName = 'fDenyTSConnections'
            ValueType = 'Dword'
            ValueData = '0'
            Ensure = 'Present'
        }
        foreach ($Rule in @(
                'RemoteDesktop-UserMode-In-TCP',
                'RemoteDesktop-UserMode-In-UDP',
                'RemoteDesktop-Shadow-In-TCP'
        )) {
        xFirewall $Rule {
            Name = $Rule
            Enabled = 'True'
            DependsOn = '[Registry]RDP'
        }
    } # End RDP
    }
#endregion
}

AutoLab -OutputPath .\ -ConfigurationData .\VMConfigurationData.psd1

