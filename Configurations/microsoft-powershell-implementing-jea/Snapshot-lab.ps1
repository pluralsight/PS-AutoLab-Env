<#
Disclaimer

This code is provided without copyright and “AS IS”.  It is free for you to use and modify under the MIT license.
Note: All scripts require WMF 5 or above, and to run from PowerShell using "Run as Administrator"

#>
#Requires -version 5.0
#Requires -runasadministrator

Clear-Host
Write-Host -ForegroundColor Green -Object @"

    This is the Snapshot-Lab script. This script will perform the following:
    
    * Snapshot the lab environment for easy and fast rebuilding
    
    Note! This should be done after the configurations have finished

    Next Steps:

    To quickly rebuild the labs from the checkpoint, run:
    .\Refresh-Lab.ps1

    To stop the lab environment, run:
    .\shutdown-lab.ps1

"@

Pause

Write-Host -ForegroundColor Cyan -Object 'Snapshot the lab environment'
# Creates the lab environment without making a Hyper-V Snapshot
Stop-Lab -ConfigurationData .\*.psd1 
Checkpoint-Lab -ConfigurationData .\*.psd1 -SnapshotName LabConfigured

Write-Host -ForegroundColor Green -Object @"

   Next Steps:

    To start the lab environment, run:
    .\Run-Lab.ps1

    To quickly rebuild the labs from the checkpoint, run:
    .\Refresh-Lab.ps1

    To stop the lab environment, run:
    .\shutdown-lab.ps1

"@

