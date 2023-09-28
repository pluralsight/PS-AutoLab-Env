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

Function Invoke-SetupHost {
    [CmdletBinding(SupportsShouldProcess)]
    [alias("Setup-Host")]
    Param(
        [string]$DestinationPath = "C:\Autolab"
    )

    # Setup Path Variables
    $SourcePath = $PSScriptRoot

    Clear-Host
    Write-Host -ForegroundColor Cyan -Object "The default installation path is $DestinationPath"
    $result = Read-Host "Would you like to change the default path? (y/n)"
    If ($Result -eq 'y') {
        $DestinationPath = Read-Host "Enter complete path including drive letter"
        Write-Output "New path is $DestinationPath"
    }


    Write-Host -ForegroundColor Green -Object @"

    This is the Setup-Host script. This script will perform the following:

    * For PowerShell Remoting, configure the host 'TrustedHosts' value to *
    * Install the Lability module from PSGallery
    * Install Hyper-V
    * Create the $DestinationPath folder (DO NOT DELETE)
    * Copy configurations and resources to $DestinationPath
    * You will then need to reboot the host before continuing

    Note! - You may delete the folder $SourcePath when this setup finished and the system
            has been rebooted.

"@

    Write-Host -ForegroundColor Yellow -Object @"

    !!IMPORTANT SECURITY NOTE!!

    This module will set trusted hosts to connect to ANY remote machine. This is NOT a recommended
    security practice. It is assumed you are installing this module on a non-production machine
    and are willing to accept this potential risk for the sake of a training and test environment.

    If you do not want to proceed, press Ctrl-C.
"@

    Pause

    # For remoting commands to VM's - have the host set trustedhosts
    Enable-PSremoting -force -SkipNetworkProfileCheck

    Write-Host -ForegroundColor Cyan -Object "Setting TrustedHosts so that remoting commands to VMs work properly"
    $trust = Get-Item -Path WSMan:\localhost\Client\TrustedHosts
    if ($Trust.Value -eq "*") {
        Write-Host -ForegroundColor Green -Object "TrustedHosts is already set to *. No changes needed"
    }
    else {
        $add = '*' # Jeffs idea - 'DC,S*,Client*,192.168.3.' - need to automate this, not hard code
        Write-Host -ForegroundColor Cyan -Object "Adding $add to TrustedHosts"
        Set-Item -Path WSMan:\localhost\Client\TrustedHosts -Value $add -Concatenate -force
    }

    # Lability install

    Get-PackageSource -Name PSGallery | Set-PackageSource -Trusted -Force -ForceBootstrap | Out-Null

    <#
 Test if the current version of Lability is already installed. If so, do nothing.
 If an older version is installed, update the version, otherwise install the latest version.
#>

    $requiredVersion = '0.18.0'
    $LabilityMod = Get-Module -Name Lability -ListAvailable | Sort-Object Version -Descending
    if (-Not $LabilityMod) {
        Write-Host -ForegroundColor Cyan "Installing Lability Module version $requiredVersion for the lab build"
        Install-Module -Name Lability -RequiredVersion $requiredVersion -Force
    }
    elseif ($LabilityMod[0].Version.ToString() -eq $requiredVersion) {
        Write-Host "Version $requiredVersion of Lability is already installed" -ForegroundColor Cyan
    }
    elseif ($LabilityMod[0]) {
        Write-Host -ForegroundColor Cyan "Updating Lability Module for the lab build"
        Update-Module -Name Lability -force #-RequiredVersion $requiredVersion -Force
    }

    # Install PSAutoLab Module
   # Write-Host -ForegroundColor Cyan "Installing PSAutoLab Module for the lab build"
   # Copy-Item -Path "$SourcePath\Tools\PSAutoLab" -Destination 'C:\Program Files\WindowsPowerShell\Modules' -Recurse -Force

    # Set Lability folder structure
    $DirDef = @{
        ConfigurationPath   = "$DestinationPath\Configurations"
        DifferencingVhdPath = "$DestinationPath\VMVirtualHardDisks"
        HotfixPath          = "$DestinationPath\Hotfixes"
        IsoPath             = "$DestinationPath\ISOs"
        ModuleCachePath     = "C:\ProgramData\Lability\Modules"
        ParentVhdPath       = "$DestinationPath\MasterVirtualHardDisks"
        ResourcePath        = "$DestinationPath\Resources"
    }

    Set-LabHostDefault @DirDef

    # Setup host Environment.
    # Dev Note -- Should use If state with Test-LabHostConfiguration -- it returns true or false

    $HostStatus = Test-LabHostConfiguration
    If ($HostStatus -eq $False) {
        Write-Host -ForegroundColor Cyan "Starting to Initialize host and install Hyper-V"
        Start-LabHostConfiguration -ErrorAction SilentlyContinue
    }

    ###### COPY Configs to host machine
    Write-Host -ForegroundColor Cyan -Object "Copying configs to $DestinationPath\Configurations"
    Copy-item -Path $SourcePath\Configurations\* -recurse -Destination $DestinationPath\Configurations -force

    Write-Host -ForegroundColor Green -Object @"

    The Host is about to reboot.
    After the reboot, open Powershell, navigate to a configuration directory
    $DestinationPath\Configuration\<yourconfigfolder>
    And run:

    PS $DestinationPath\Configuration\<yourconfigfolder>Setup-Lab -ignorependingreboot
    or
    PS $DestinationPath\Configuration\<yourconfigfolder>Unattend-Lab -ignorependingreboot

"@

    Write-Host -ForegroundColor Yellow -Object "Note! - You may delete the folder $SourcePath when this setup finished and the system has been rebooted."

    Write-Warning "System needs to reboot"
    $reboot = Read-Host "Do you wish to reboot now? (y/n)"
    If ($reboot -eq 'y') {
        Write-Output "Rebooting now"
        Restart-Computer
    }




}

#region Setup-Lab
Function Invoke-SetupLab {
    [cmdletbinding(SupportsShouldProcess)]
    [Alias("Setup-Lab")]
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

    $Password = ConvertTo-SecureString -String "$($LabData.AllNodes.LabPassword)" -AsPlainText -Force
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

}
#endregion Setup-lab

#region Run-Lab
Function Invoke-RunLab {
    [cmdletbinding()]
    [alias("Run-Lab")]
    Param (
        [string]$Path = $PSScriptRoot
    )

    Write-Host -ForegroundColor Green -Object @"

        This is the Run-Lab script. This script will perform the following:

        * Start the Lab environment

        Note! If this is the first time you have run this, it can take up to an hour
        for the DSC configs to apply.
        This only occurs the first time.

"@

    Write-Host -ForegroundColor Cyan -Object 'Starting the lab environment'
    # Creates the lab environment without making a Hyper-V Snapshot
    Start-Lab -ConfigurationData .\*.psd1

    Write-Host -ForegroundColor Green -Object @"

        Next Steps:

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
#endregion setup-lab

#region Enable-Internet
Function Enable-Internet {
    [cmdletbinding()]
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
    $LabSwitchName = $LabData.NonNodeData.Lability.Network.name
    $GatewayIP = $LabData.AllNodes.DefaultGateway
    $GatewayPrefix = $LabData.AllNodes.SubnetMask
    $NatNetwork = $LabData.AllNodes.IPnetwork
    $NatName = $LabData.AllNodes.IPNatName


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
Function Invoke-ValidateLab {
    [cmdletbinding()]
    [alias("Validate-Lab")]
    Param (
        [string]$Path = $PSScriptRoot
    )

    Write-Host "[$(Get-Date)] Starting the VM testing process. This could take some time complete. Errors are expected until all tests complete successfully." -ForegroundColor Cyan
    #Start-sleep -Seconds 300
    $Complete = $False

    do {

        $test = Invoke-Pester -Script .\VMValidate.Test.ps1 -quiet -PassThru

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
Function Invoke-ShutdownLab {
    [cmdletbinding()]
    [alias("Shutdown-Lab")]
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
Function Invoke-SnapshotLab {
    [cmdletbinding()]
    [alias("Snapshot-Lab")]
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
Function Invoke-RefreshLab {
    [cmdletbinding()]
    [alias("Refresh-Lab")]
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
Function Invoke-WipeLab {
    [cmdletbinding()]
    [alias("Wipe-Lab")]
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
    $NatName = $LabData.AllNodes.IPNatName
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
Function Invoke-UnattendLab {
    [cmdletbinding(SupportsShouldProcess)]
    [alias("Unattend-Lab")]
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