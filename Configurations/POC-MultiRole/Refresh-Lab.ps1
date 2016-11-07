<#
Disclaimer

This code is provided without copyright and “AS IS”.  It is free for you to use and modify under the MIT license.
Note: All scripts require WMF 5 or above, and to run from PowerShell using "Run as Administrator"

#>
#Requires -version 5.0
#Requires -runasadministrator

Write-Host -ForegroundColor Green -Object @"

    This is the Refresh-Lab script. This script will perform the following:
    
    * Refresh the lab from a previous Snapshot 
    
    Note! This can only be done if you created a snapshot!
    .\Snapshot-lab.ps1

"@

Write-Host -ForegroundColor Cyan -Object 'Snapshot the lab environment'
# Creates the lab environment without making a Hyper-V Snapshot
Stop-Lab -ConfigurationData .\*.psd1 
Restore-Lab -ConfigurationData .\*.psd1 -SnapshotName LabConfigured -force

Write-Host -ForegroundColor Green -Object @"

    Next Steps:

    To start the lab environment, run:
    .\run-lab.ps1

    To stop the lab environment, run:
    .\shutdown-lab.ps1

    To destroy this lab, run:
    .\Wipe-Lab.ps1

"@

