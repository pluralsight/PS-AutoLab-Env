<#
Disclaimer

This code is provided without copyright and “AS IS”.  It is free for you to use and modify under the MIT license.
Note: All scripts require WMF 5 or above, and to run from PowerShell using "Run as Administrator"

#>
#Requires -version 5.0
#Requires -runasadministrator

Clear-Host
Write-Host -ForegroundColor Green -Object @"

   This runs Setup-Lab, Run-Lab, and validate-Lab
    
"@
 
Write-Host -ForegroundColor Cyan -Object 'Starting the lab environment'

Pause

.\Setup-Lab.ps1
.\Run-Lab.ps1
.\Validate-Lab.ps1

Write-Host -ForegroundColor Green -Object @"

    To stop the lab VM's:
    .\Shutdown-lab.ps1

    When the configurations have finished, you can checkpoint the VM's with:
    .\Snapshot-Lab.ps1

    To quickly rebuild the labs from the checkpoint, run:
    .\Refresh-Lab.ps1

"@

