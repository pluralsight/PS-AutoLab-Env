<#
Disclaimer

This code is provided without copyright and “AS IS”.  It is free for you to use and modify under the MIT license.
Note: All scripts require WMF 5 or above, and to run from PowerShell using "Run as Administrator"

#>
#Requires -version 5.0
#Requires -runasadministrator

Clear-Host
Write-Host -ForegroundColor Green -Object @"

    This is the Shutdown-Lab script. This script will perform the following:
    
    * Shutdown the Lab environment
    
    Next Steps:

    When the configurations have finished, you can checkpoint the VM's with:
    .\Snapshot-Lab.ps1

    To quickly rebuild the labs from the checkpoint, run:
    .\Refresh-Lab.ps1

    To start the lab environment:
    .\Run-Lab.ps1

    To destroy the lab environment:
    .\wipe-lab.ps1

"@

Pause

Write-Host -ForegroundColor Cyan -Object 'Stoping the lab environment'
# Creates the lab environment without making a Hyper-V Snapshot
Stop-Lab -ConfigurationData .\*.psd1 

Write-Host -ForegroundColor Green -Object @"

 Next Steps:

    When the configurations have finished, you can checkpoint the VM's with:
    .\Snapshot-Lab.ps1

    To quickly rebuild the labs from the checkpoint, run:
    .\Refresh-Lab.ps1

    To start the lab environment:
    .\Run-Lab.ps1

    To destroy the lab environment:
    .\wipe-lab.ps1

"@

