<#
Disclaimer

This code is provided without copyright and “AS IS”.  It is free for you to use and modify under the MIT license.
Note: All scripts require WMF 5 or above, and to run from PowerShell using "Run as Administrator"

#>
#Requires -version 5.0
#Requires -runasadministrator

Clear-Host
Write-Host -ForegroundColor Green -Object @"

    This is the Enable-Internet script. This script will perform the following:
    
    * Enable Internet to the VM's 
    
    * Note! - If this generates an error, you are already enabled, or one of the default settings below
                does not match your .PSD1 configuration
   
    *DevNote! - Currently working on a better solution to pull those values

"@



    $LabData = Import-PowerShellDataFile -Path .\*.psd1
    $LabSwitchName = $labdata.NonNodeData.Lability.Network.name 
    $GatewayIP = $Labdata.AllNodes.DefaultGateway
    $GatewayPrefix = $Labdata.AllNodes.SubnetMask
    $NatNetwork = $Labdata.AllNodes.IPnetwork
    $NatName = $Labdata.AllNodes.IPNatName


    $Index = Get-NetAdapter -name "vethernet ($LabSwitchName)" | Select-Object -ExpandProperty InterfaceIndex
    New-NetIPAddress -InterfaceIndex $Index -IPAddress $GatewayIP -PrefixLength $GatewayPrefix -ErrorAction SilentlyContinue
    # Creating the NAT on Server 2016 -- maybe not work on 2012R2
    New-NetNat -Name $NatName -InternalIPInterfaceAddressPrefix $NatNetwork -ErrorAction SilentlyContinue   

Write-Host -ForegroundColor Green -Object @"

    Next Steps:
    
    When complete, run:
    .\Run-Lab.ps1

    And run:
    .\Validate-Lab.ps1

"@

