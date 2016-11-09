<# Notes:

Authors: Jason Helmick and Melissa (Missy) Janusko
Additional contributors of note: Jeff Hicks

Note: 
This module should not be considered to follow best practices. This is a collection of 'Control' scripts,
that use helping information that does not follow Advanced Function best practices.
This is intentional for the benefit and ease of use for students less familiar with PowerShell.
The goal was to make maintainence of the control scripts easier.
    
       
Disclaimer

This example code is provided without copyright and AS IS.  It is free for you to use and modify.
Note: These demos should not be run as a script. These are the commands that I use in the 
demonstrations and would need to be modified for your environment.

#> 

#Requires -version 5.0
#Requires -runasadministrator

Function Setup-Lab {
    Param (
        $Path = $PSScriptRoot
    )
    Write-Host -ForegroundColor Green -Object @"

        This is the Setup-Lab script. This script will perform the following:
        * Run the configs to generate the required .mof files
        Note! - If there is an error creating the .mofs, the setup will fail
        
        * Run the lab setup
        Note! If this is the first time you have run this, it can take several
        hours to download the .ISO's and resources.
        This only occurs the first time.

        **Possible problem, if the downloads finish but the script doesn't continue (pauses)
            Hit the return key once and it will continue

        *You will be able to wipe and rebuild this lab without needing to perform
        the downloads again.
"@

    # Install DSC Resource modules specified in the .PSD1
    Write-Host -ForegroundColor Cyan -Object 'Installing required DSCResource modules from PSGallery'
    Write-Host -ForegroundColor Yellow -Object 'You may need to say "yes" to a Nuget Provider'
    $LabData = Import-PowerShellDataFile -Path .\*.psd1
    $DSCResources = $LabData.NonNodeData.Lability.DSCResource

    Foreach ($DSCResource in $DSCResources) {

        Install-Module -Name $($DSCResource).Name -RequiredVersion $($DSCResource).RequiredVersion

    }

    # Run the config to generate the .mof files
    Write-Host -ForegroundColor Cyan -Object 'Build the .Mof files from the configs'
    .\VMConfiguration.ps1

    # Build the lab without a snapshot
    #
    Write-Host -ForegroundColor Cyan -Object 'Building the lab environment'
    # Creates the lab environment without making a Hyper-V Snapshot

    $Password = ConvertTo-SecureString -String "$($labdata.allnodes.labpassword)" -AsPlainText -Force 
    Start-LabConfiguration -ConfigurationData .\*.psd1 -path .\ -NoSnapshot -Password $Password
    # Disable secure boot for VM's
    Get-VM ( Get-LabVM -ConfigurationData .\*.psd1 ).Name -OutVariable vm
    Set-VMFirmware -VM $vm -EnableSecureBoot Off -SecureBootTemplate MicrosoftUEFICertificateAuthority


    Write-Host -ForegroundColor Green -Object @"

        Next Steps:
        
        When complete, run:
        .\Run-Lab.ps1

        Run the following to validatae when configurations have converged:
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



}
