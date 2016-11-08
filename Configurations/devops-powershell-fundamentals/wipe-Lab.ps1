<#
Disclaimer

This code is provided without copyright and “AS IS”.  It is free for you to use and modify under the MIT license.
Note: All scripts require WMF 5 or above, and to run from PowerShell using "Run as Administrator"

#>
#Requires -version 5.0
#Requires -runasadministrator

Clear-Host
Write-Host -ForegroundColor Green -Object @"

    This is the wipe-Lab script. This script will perform the following:
    
    * Wipe the lab and VM's from your system 
    

    Next Steps:

    To start the lab environment, run:
    .\Setup-lab.ps1


"@

Pause

Write-Host -ForegroundColor Cyan -Object 'Removing the lab environment'
# Creates the lab environment without making a Hyper-V Snapshot
Stop-Lab -ConfigurationData .\*.psd1 
Remove-Item -Path .\*.mof
Remove-LabConfiguration -ConfigurationData .\*.psd1 -RemoveSwitch


Write-Host -ForegroundColor Green -Object @"

    Next Steps:

    To start the lab environment, run:
    .\Setup-lab.ps1

"@

