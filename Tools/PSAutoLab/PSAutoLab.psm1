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

#region Setup-Lab
Function Setup-Lab {
    Param (
        [string]$Path = $PSScriptRoot
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
        Run-Lab

        Run the following to validatae when configurations have converged:
        Validate-Lab

        To enable Internet access for the VM's, run:
        Enable-Internet

        To stop the lab VM's:
        Shutdown-lab

        When the configurations have finished, you can checkpoint the VM's with:
        Snapshot-Lab

        To quickly rebuild the labs from the checkpoint, run:
        Refresh-Lab

        To destroy the lab to build again:
        Wipe-Lab   

"@



}
#endregion Setup-lab

#region Run-Lab
Function Setup-Lab {
    [cmdletbinding(SupportsShouldProcess)]
    Param (
        [string]$Path = $PSScriptRoot,
        [switch]$IgnorePendingReboot
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
    if ($PSCmdlet.ShouldProcess('.\VMConfiguration.ps1')) {
        .\VMConfiguration.ps1
    }
    # Build the lab without a snapshot
    #
    Write-Host -ForegroundColor Cyan -Object 'Building the lab environment'
    # Creates the lab environment without making a Hyper-V Snapshot

    $Password = ConvertTo-SecureString -String "$($labdata.allnodes.labpassword)" -AsPlainText -Force 
    $startParams = @{
        ConfigurationData = ".\*.psd1"
        Path              = ".\"
        NoSnapshot        = $True 
        Password          = $Password
    }
    if ($IgnorePendingReboot) {
        $startParams.Add("IgnorePendingReboot", $True)
    }

    if ($PSCmdlet.ShouldProcess($($startParams | Out-String))) {
        Start-LabConfiguration @startParams 
        # Disable secure boot for VM's
        Get-VM ( Get-LabVM -ConfigurationData .\*.psd1 ).Name -OutVariable vm
        Set-VMFirmware -VM $vm -EnableSecureBoot Off -SecureBootTemplate MicrosoftUEFICertificateAuthority


        Write-Host -ForegroundColor Green -Object @"

        Next Steps:
        
        When complete, run:
        Run-Lab

        Run the following to validatae when configurations have converged:
        Validate-Lab

        To enable Internet access for the VM's, run:
        Enable-Internet

        To stop the lab VM's:
        Shutdown-lab

        When the configurations have finished, you can checkpoint the VM's with:
        Snapshot-Lab

        To quickly rebuild the labs from the checkpoint, run:
        Refresh-Lab

        To destroy the lab to build again:
        Wipe-Lab   

"@

    } #should process

}#endregion setup-lab

#region Enable-Internet
Function Enable-Internet {
    Param (
        [string]$Path = $PSScriptRoot
    )

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
        Run-Lab

        And run:
        Validate-Lab

"@
}
#endregion Enable-Internet

#region Validate-Lab
Function Validate-Lab {
    Param (
        [string]$Path = $PSScriptRoot
    )

    Write-Host "[$(Get-Date)] Starting the VM testing process. This could take some time complete. Errors are expected until all tests complete successfully." -ForegroundColor Cyan
    #Start-sleep -Seconds 300
    $Complete = $False

    do {

    $test= Invoke-Pester -Script .\VMValidate.Test.ps1 -quiet -PassThru

    if ($test.Failedcount -eq 0) {
        $Complete = $True
    }
    else {
        300..1 | foreach {
        Write-progress -Activity "VM Completion Test" -Status "Tests failed" -CurrentOperation "Waiting until next test run" -SecondsRemaining $_
        Start-sleep -Seconds 1
        }

        Write-Progress -Activity "VM Completion Test" -Completed
    }
    } until ($Complete)

    #re-run test one more time to show everything that was tested.
    Invoke-Pester -Script .\VMValidate.Test.ps1

    Write-Host "[$(Get-Date)] VM setup and configuration complete. It is recommended that you snapshot the VMs with Snapshot-Lab.ps1." -ForegroundColor Green


}
#endregion Validate-Lab

#region Shutdown-Lab
Function Shutdown-Lab {
    Param (
        [string]$Path = $PSScriptRoot
    )

    Write-Host -ForegroundColor Green -Object @"

        This is the Shutdown-Lab script. This script will perform the following:
    
        * Shutdown the Lab environment:

"@

    Write-Host -ForegroundColor Cyan -Object 'Stopping the lab environment'
    # Creates the lab environment without making a Hyper-V Snapshot
    Stop-Lab -ConfigurationData .\*.psd1 

    Write-Host -ForegroundColor Green -Object @"

     Next Steps:

        When the configurations have finished, you can checkpoint the VM's with:
        Snapshot-Lab

        To quickly rebuild the labs from the checkpoint, run:
        Refresh-Lab

        To start the lab environment:
        Run-Lab

        To destroy the lab environment:
        Wipe-Lab

"@
}
#endregion Shutdown-Lab

#region Snapshot-Lab
Function Snapshot-Lab {
    Param (
        [string]$Path = $PSScriptRoot
    )

    Write-Host -ForegroundColor Green -Object @"

        This is the Snapshot-Lab script. This script will perform the following:
    
        * Snapshot the lab environment for easy and fast rebuilding
    
        Note! This should be done after the configurations have finished

"@

    Write-Host -ForegroundColor Cyan -Object 'Snapshot the lab environment'
    # Creates the lab environment without making a Hyper-V Snapshot
    Stop-Lab -ConfigurationData .\*.psd1 
    Checkpoint-Lab -ConfigurationData .\*.psd1 -SnapshotName LabConfigured

    Write-Host -ForegroundColor Green -Object @"

       Next Steps:

        To start the lab environment, run:
        Run-Lab

        To quickly rebuild the labs from the checkpoint, run:
        Refresh-Lab

        To stop the lab environment, run:
        Shutdown-Lab

"@
}
#endregion

#region Refresh-Lab
Function Refresh-Lab {
    Param (
        [string]$Path = $PSScriptRoot
    )

    Write-Host -ForegroundColor Green -Object @"

        This is the Refresh-Lab script. This script will perform the following:
    
        * Refresh the lab from a previous Snapshot 
    
        Note! This can only be done if you created a snapshot!
        Snapshot-lab

"@

    Write-Host -ForegroundColor Cyan -Object 'Snapshot the lab environment'
    # Creates the lab environment without making a Hyper-V Snapshot
    Stop-Lab -ConfigurationData .\*.psd1 
    Restore-Lab -ConfigurationData .\*.psd1 -SnapshotName LabConfigured -force

    Write-Host -ForegroundColor Green -Object @"

        Next Steps:

        To start the lab environment, run:
        Run-Lab

        To stop the lab environment, run:
        Shutdown-Lab

        To destroy this lab, run:
        Wipe-Lab

"@
}
#endregion Refresh-Lab

#region Wipe-Lab
Function Wipe-Lab {
    Param (
        [string]$Path = $PSScriptRoot
    )

    Write-Host -ForegroundColor Green -Object @"

        This is the wipe-Lab script. This script will perform the following:
    
        * Wipe the lab and VM's from your system 

"@

    Pause

    Write-Host -ForegroundColor Cyan -Object 'Removing the lab environment'
    # Stop the VM's
    Stop-Lab -ConfigurationData .\*.psd1
    # Remove .mof iles 
    Remove-Item -Path .\*.mof
    # Delete NAT
    $LabData = Import-PowerShellDataFile -Path .\*.psd1
    $NatName = $Labdata.AllNodes.IPNatName
    Remove-NetNat -Name $NatName 
    # Delete vM's
    Remove-LabConfiguration -ConfigurationData .\*.psd1 -RemoveSwitch
    Remove-Item -Path "$((Get-LabHostDefault).DifferencingVHdPath)\*" -Force


    Write-Host -ForegroundColor Green -Object @"

        Next Steps:

        Run the following and follow the onscreen instructions:
        Setup-Lab

        When complete, run:
        Run-Lab

        Run the following to validate when configurations have converged:
        Validate-Lab

        To enable Internet access for the VM's, run:
        Enable-Internet

        To stop the lab VM's:
        Shutdown-lab

        When the configurations have finished, you can checkpoint the VM's with:
        Snapshot-Lab

        To quickly rebuild the labs from the checkpoint, run:
        Refresh-Lab

        To destroy the lab to build again:
        Wipe-Lab


"@
}
#endregion Wipe-Lab

#region Unattend-Lab
Function Unattend-Lab {
    [cmdletbinding(SupportsShouldProcess)]
    Param (
        [string]$Path = $PSScriptRoot,
        [switch]$IgnorePendingReboot
    )

    Write-Host -ForegroundColor Green -Object @"

       This runs Setup-Lab, Run-Lab, and validate-Lab
    
"@
 
    Write-Host -ForegroundColor Cyan -Object 'Starting the lab environment'


    Setup-Lab @psboundparameters
    Run-Lab
    Enable-Internet
    Validate-Lab

    Write-Host -ForegroundColor Green -Object @"

        To stop the lab VM's:
        Shutdown-lab

        When the configurations have finished, you can checkpoint the VM's with:
        Snapshot-Lab

        To quickly rebuild the labs from the checkpoint, run:
        Refresh-Lab

"@

}
#endregion Unattend-Lab