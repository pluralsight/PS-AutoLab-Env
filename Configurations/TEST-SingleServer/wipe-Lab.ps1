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

    Run the following and follow the onscreen instructions:
    .\Setup-Lab.ps1

    When complete, run:
    .\Run-Lab.ps1

    Run the following to validate when configurations have converged:
    .\Validate-Lab.ps1

    To enable Internet access for the VM's, run:
    .\Enable-Internet.ps1

    To stop the lab VM's:
    .\Shutdown-lab.ps1

    When the configurations have finished, you can checkpoint the VM's with:
    .\Snapshot-Lab.ps1

    To quickly rebuild the labs from the checkpoint, run:
    .\Refresh-Lab.ps1

    To destroy the lab to build again:
    .\Wipe-Lab.ps1 
"@

