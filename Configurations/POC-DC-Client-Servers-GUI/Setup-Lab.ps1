<#
Disclaimer

This code is provided without copyright and “AS IS”.  It is free for you to use and modify under the MIT license.
Note: All scripts require WMF 5 or above, and to run from PowerShell using "Run as Administrator"

#>
#Requires -version 5.0
#Requires -runasadministrator

Clear-Host
Write-Host -ForegroundColor Green -Object @"

    This is the Setup-Lab script. This script will perform the following:
    * Run the configs to generate the required .mof files
    Note! - If there is an error creating the .mofs, the setup will fail
    
    * Run the lab setup
    Note! If this is the first time you have run this, it can take several
    hours to downlaod the .ISO's and resources.
    This only occures the first time.

    *You will be able to wipe and rebuild this lab without needing to perform
    the downloads again.

    Next Steps:
    When complete, run:
    .\Run-Lab.ps1

    When the configurations have finished, you can checkpoint the VM's with:
    .\Snapshot-Lab.ps1

    To quickly rebuild the labs from the checkpoint, run:
    .\Refresh-Lab.ps1

    To destroy the lab to build again:
    .\Wipe-Lab.ps1

    To enable Internet access for the VM's, run:
    .\Enable-Internet.ps1

"@

Pause

# Run the config to generate the .mof files
Write-Host -ForegroundColor Cyan -Object 'Build the .Mof files from the configs'
Write-Host -ForegroundColor Yellow -Object 'If this fails, the lab build will fail'
.\DC-Client-Servers-GUI.ps1

# Build the lab without a snapshot
#
Write-Host -ForegroundColor Cyan -Object 'Building the lab environment'
# Creates the lab environement without making a Hyper Snapshot
Start-LabConfiguration -ConfigurationData .\DC-Client-Servers-GUI.psd1 -Verbose -path .\

Write-Host -ForegroundColor Green -Object @"

    Next Steps:
    To enable Internet access for the VM's, run:
    .\Enable-Internet.ps1

    When complete, run:
    .\Run-Lab.ps1

"@

Pause

