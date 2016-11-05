<#
Disclaimer

This code is provided without copyright and “AS IS”.  It is free for you to use and modify under the MIT license.
Note: All scripts require WMF 5 or above, and to run from PowerShell using "Run as Administrator"

#>
#Requires -version 5.0
#Requires -runasadministrator

Clear-Host
Write-Host -ForegroundColor Green -Object @"

    This is the Run-Lab script. This script will perform the following:
    
    * Start the Lab environment
    
    Note! If this is the first time you have run this, it can take up to an hour
    for the DSC configs to apply. 
    This only occurs the first time.

    *You will be able to wipe and rebuild this lab without needing to perform
    the configuration process again if you:

    Next Steps:

    To stop the lab VM's:
    .\Shutdown-lab.ps1
    
    When the configurations have finished, you can checkpoint the VM's with:
    .\Snapshot-Lab.ps1

    To quickly rebuild the labs from the checkpoint, run:
    .\Refresh-Lab.ps1

"@

Pause

Write-Host -ForegroundColor Cyan -Object 'Starting the lab environment'
# Creates the lab environment without making a Hyper-V Snapshot
Start-Lab -ConfigurationData .\*.psd1 

Write-Host -ForegroundColor Green -Object @"

    Next Steps:
    To stop the lab VM's:
    .\Shutdown-lab.ps1

    When the configurations have finished, you can checkpoint the VM's with:
    .\Snapshot-Lab.ps1

    To quickly rebuild the labs from the checkpoint, run:
    .\Refresh-Lab.ps1

"@

