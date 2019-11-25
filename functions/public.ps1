#region Get-PSAutoLabSetting
Function Get-PSAutoLabSetting {
    [cmdletbinding()]
    Param()

    $psver = $PSVersionTable
    Try {
        $cimos = Get-CimInstance -class Win32_operatingsystem -Property caption, FreePhysicalMemory, TotalVisibleMemorySize -ErrorAction Stop
        $os = $cimos.caption
        $mem = $cimos.TotalVisibleMemorySize
        $pctFree = [math]::round(($cimos.FreePhysicalMemory / $cimos.TotalVisibleMemorySize) * 100, 2)
    }
    Catch {
        $os = ""
        $mem = 0
        $pctFree = 0
    }

    [pscustomobject]@{
        PSVersion     = $psver.PSVersion
        PSEdition     = $psver.PSEdition
        OS            = $os
        IsElevated    = (Test-IsAdministrator)
        HyperV        = (Get-Item $env:windir\System32\vmms.exe).versioninfo.productversion
        PSAutolab     = (Get-Module -name PSAutolab -ListAvailable | Sort-Object -Property Version -Descending).version
        Lability      = (Get-Module -name Lability -ListAvailable | Sort-Object -Property Version -Descending).version
        Pester        = (Get-Module -name Pester -ListAvailable | Sort-Object -Property Version -Descending | Select-Object -first 1).version
        MemoryGB      = ($mem * 1kb) / 1GB -as [int]
        PctFreeMemory = $pctFree
    }
}

#endregion

#region Invoke-RefreshHost
Function Invoke-RefreshHost {
    [cmdletbinding(SupportsShouldProcess)]
    [alias("Refresh-Host")]
    Param(
        [Parameter(Position = 0, HelpMessage = "The path to your Autolab configuration path, ie C:\Autolab\ConfigurationPath")]
        [ValidateNotNullorEmpty()]
        [ValidateScript( { Test-Path $_ })]
        [string]$Destination = (Get-LabHostDefault).configurationpath
    )

    #test if a new version of lability is required
    if ($pscmdlet.ShouldProcess("version $LabilityVersion", "Check for Lability Requirements")) {
        _LabilityCheck -requiredVersion $LabilityVersion
    }

    # Setup Path Variables
    $SourcePath = $ConfigurationPath

    Write-Host "Updating configuration files from $sourcePath" -ForegroundColor Cyan
    if ($pscmdlet.ShouldProcess($Destination, "Copy configurations")) {
        if (Test-Path $Destination) {
            Copy-Item -Path $SourcePath\* -recurse -Destination $Destination -force
        }
        else {
            Write-Warning "Can't find target path $Destination."
        }
    }

    Write-Host "This process will not remove any configurations that have been deleted from the module." -ForegroundColor yellow
}
#endregion

#region Invoke-SetupHost
Function Invoke-SetupHost {
    [CmdletBinding(SupportsShouldProcess)]
    [alias("Setup-Host")]
    Param(
        [Parameter(HelpMessage = "Specify the parent path. The default is C:\Autolab. The command will create the folder.")]
        [string]$DestinationPath = "C:\Autolab"
    )

    # Setup Path Variables
    #use module defined variable
    $SourcePath = $ConfigurationPath

    Clear-Host

    Write-Host -ForegroundColor Green -Object @"

    This is the Setup-Host script. This script will perform the following:

    * For PowerShell Remoting, configure the host 'TrustedHosts' value to *
    * Install the Lability module from PSGallery
    * Update the Pester module if necessary
    * Install Hyper-V
    * Create the $DestinationPath folder (DO NOT DELETE)
    * Copy configurations and resources to $DestinationPath
    * You will then need to reboot the host before continuing

"@

    Write-Host -ForegroundColor Yellow -Object @"

    !!IMPORTANT SECURITY NOTE!!

    This module will set trusted hosts to connect to any machine on the local network. This is NOT a recommended
    security practice. It is assumed you are installing this module on a non-production machine
    and are willing to accept this potential risk for the sake of a training and test environment.

    If you do not want to proceed, press Ctrl-C.
"@

    Pause

    # For remoting commands to VM's - have the host set trustedhosts
    Enable-PSRemoting -force -SkipNetworkProfileCheck

    Write-Host -ForegroundColor Cyan -Object "Setting TrustedHosts so that remoting commands to VMs work properly"
    $trust = Get-Item -Path WSMan:\localhost\Client\TrustedHosts
    if (($Trust.Value -eq "*") -or ($trust.Value -match "<local>")) {
        Write-Host -ForegroundColor Green -Object "TrustedHosts is already set to *. No changes needed"
    }
    else {
        $add = '<local>' # Jeffs idea - 'DC,S*,Client*,192.168.3.' - need to automate this, not hard code
        Write-Host -ForegroundColor Cyan -Object "Adding $add to TrustedHosts"
        Set-Item -Path WSMan:\localhost\Client\TrustedHosts -Value $add -Concatenate -force
    }

    # Lability install
    Install-PackageProvider -Name Nuget -ForceBootstrap

    Get-PackageSource -Name PSGallery | Set-PackageSource -Trusted -Force -ForceBootstrap | Out-Null

    <#
 Test if the current version of Lability is already installed. If so, do nothing.
 If an older version is installed, update the version, otherwise install the latest version.
#>

    #update Pester as needed
    _PesterCheck

    #use the module defined variable and a private function
    if ($pscmdlet.ShouldProcess("Lability $labilityVersion", "Install or Update Lability")) {
        _LabilityCheck $LabilityVersion
        Import-Module Lability
    }

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

    $HostStatus = Test-LabHostConfiguration
    If (-Not $HostStatus ) {
        Write-Host -ForegroundColor Cyan "Starting to Initialize host and install Hyper-V"
        if ($pscmdlet.shouldprocess($DirDef.ConfigurationPath)) {
            Start-LabHostConfiguration -ErrorAction SilentlyContinue
        }
    }

    ###### COPY Configs to host machine
    Write-Host -ForegroundColor Cyan -Object "Copying configs to $($DirDef.ConfigurationPath)"
    if ($pscmdlet.ShouldProcess($DirDef.ConfigurationPath, "Copy configurations")) {
        Copy-Item -Path $SourcePath\* -recurse -Destination $DirDef.ConfigurationPath -force
    }

    if ($pscmdlet.ShouldProcess($env:computername, "Prompt for restart")) {

        Write-Host -ForegroundColor Green -Object @"

        The localhost is about to reboot.
        After the reboot, open a Windows PowerShell prompt, navigate to a configuration directory
        $($DirDef.ConfigurationPath)\<yourconfigfolder>
        And run:

        PS $($DirDef.ConfigurationPath)\<yourconfigfolder>Setup-Lab -ignorependingreboot
        or
        PS $($DirDef.ConfigurationPath)\<yourconfigfolder>Unattend-Lab -ignorependingreboot

"@

        Write-Warning "System needs to reboot, especially if you just installed Hyper-V."
        $reboot = Read-Host "Do you wish to reboot now? (y/n)"
        If ($reboot -eq 'y') {
            Write-Output "Rebooting now"
            Restart-Computer
        }
    } #whatif

}
#endregion

#region Setup-Lab
Function Invoke-SetupLab {
    [cmdletbinding(SupportsShouldProcess)]
    [Alias("Setup-Lab")]
    Param (
        [Parameter(HelpMessage = "The path to the configuration folder. Normally, you should run all commands from within the configuration folder.")]
        [ValidateNotNullorEmpty()]
        [ValidateScript( { Test-Path $_ })]
        [string]$Path = ".",
        [switch]$IgnorePendingReboot
    )

    $Path = Convert-Path $path
    $labname = Split-Path $Path -leaf
    $LabData = Import-PowerShellDataFile -Path $(Join-Path $Path -childpath *.psd1)
    $DSCResources = $LabData.NonNodeData.Lability.DSCResource
    if (-Not $DSCResources) {
        Write-Warning "Failed to find DSC Resource information. Are you in a directory with configuration data .psd1 file?"
        #bail out
        return
    }

    Write-Host -ForegroundColor Green -Object @"

        This is the Setup-Lab script. This script will perform the following:

        * Run the configs to generate the required .mof files
        Note! - If there is an error creating the .mofs, the setup will fail

        * Run the lab setup
        Note! If this is the first time you have run this, it can take several
        hours to download the ISO files and resources depending on the configuration.
        You may also see new drives being added and removed as the ISO is mounted
        and converted. This step should only happen the first time you run this
        command.

        ** Possible problem
        If the downloads finish but the script doesn't continue (pauses),
        press the Enter key once and it should continue

        *You will be able to wipe and rebuild this lab without needing to perform
        the downloads again.
"@

    # Install DSC Resource modules specified in the .PSD1

    Write-Host -ForegroundColor Cyan -Object 'Installing required DSCResource modules from PSGallery'
    Write-Host -ForegroundColor Yellow -Object 'You may need to say "yes" to a Nuget Provider'
    #force updating/installing nuget to bypass the prompt
    [void](Install-PackageProvider -Name nuget -Force -ForceBootstrap)

    Foreach ($DSCResource in $DSCResources) {
        #test if current version is installed otherwise update or install it
        $dscmod = Get-Module -FullyQualifiedName @{Modulename = $DSCResource.name; ModuleVersion = $DSCResource.RequiredVersion } -ListAvailable

        if ((-not $dscmod ) -or ($dscmod.version -ne $DSCResource.RequiredVersion)) {
            Write-Host "install $($dscresource.name) version $($DSCResource.requiredversion)" -ForegroundColor yellow
            if ($pscmdlet.ShouldProcess($DSCResource.name, "Install-Module")) {
                Install-Module -Name $DSCResource.Name -RequiredVersion $DSCResource.RequiredVersion
            }
        }
        elseif ($dscmod.version -ne ($DSCResource.RequiredVersion -as [version])) {
            Write-Host "Update $($dscmod.name) to version $($DSCResource.requiredversion)" -ForegroundColor cyan
            if ($pscmdlet.ShouldProcess($DSCResource.name, "Update-Module")) {
                Update-Module -Name $DSCResource.Name -RequiredVersion $DSCResource.RequiredVersion
            }
        }
        else {
            Write-Host "$($dscmod.name) [v$($dscmod.version)] requires no updates." -ForegroundColor green
        }
    }

    # Run the config to generate the .mof files
    Write-Host -ForegroundColor Cyan -Object 'Build the .Mof files from the configs'
    $vmconfig = Join-Path -Path $path -ChildPath 'VMConfiguration.ps1'
    if ($PSCmdlet.ShouldProcess($vmConfig)) {
        . $VMConfig
    }
    # Build the lab without a snapshot
    #
    Write-Host -ForegroundColor Cyan -Object "Building the lab environment for $labname"
    # Creates the lab environment without making a Hyper-V Snapshot

    $Password = ConvertTo-SecureString -String "$($labdata.allnodes.labpassword)" -AsPlainText -Force
    $startParams = @{
        ConfigurationData   = Import-PowerShellDataFile -path (Join-Path -path $path -childpath "VMConfigurationdata.psd1")
        Path                = $Path
        NoSnapshot          = $True
        Password            = $Password
        IgnorePendingReboot = $True
        WarningAction       = "SilentlyContinue"
        ErrorAction         = "stop"
    }

    # $startParams | Out-String | Write-Host -ForegroundColor cyan
    if ($PSCmdlet.ShouldProcess($labname, "Start-LabConfiguration")) {
        Try {
            Start-LabConfiguration @startParams
        }
        Catch {
            Write-Host "Failed to start lab configuration." -foreground red
            throw $_
        }
        # Disable secure boot for VM's
        Get-VM ( Get-LabVM -ConfigurationData "$path\*.psd1" ).Name -OutVariable vm
        Set-VMFirmware -VM $vm -EnableSecureBoot Off -SecureBootTemplate MicrosoftUEFICertificateAuthority

        Write-Host -ForegroundColor Green -Object @"

        Next Steps:

        When this task is complete, run:
        Run-Lab

        To enable Internet access for the VM's, run:
        Enable-Internet

        Run the following to validate when configurations have converged:
        Validate-Lab

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
    [cmdletbinding(SupportsShouldProcess)]
    [alias("Run-Lab")]
    Param (
        [Parameter(HelpMessage = "The path to the configuration folder. Normally, you should run all commands from within the configuration folder.")]
        [ValidateNotNullorEmpty()]
        [ValidateScript( { Test-Path $_ })]
        [string]$Path = "."
    )

    $Path = Convert-Path $path

    Write-Host -ForegroundColor Green -Object @"

        This is the Run-Lab script. This script will perform the following:

        * Start the Lab environment

        Note! If this is the first time you have run this, it can take up to an hour
        for the DSC configurations to apply and converge.

"@

    $labname = Split-Path (Get-Location) -leaf
    $datapath = Join-Path $(Convert-Path $path) -childpath "*.psd1"
    Write-Host -ForegroundColor Cyan -Object "Starting the lab environment from $datapath"
    $data = Import-PowerShellDataFile -path $datapath
    # Creates the lab environment without making a Hyper-V Snapshot
    if ($pscmdlet.ShouldProcess($labname, "Start Lab")) {

        try {
            Start-Lab -ConfigurationData $data -ErrorAction Stop
        }
        Catch {
            Write-Warning "Failed to start lab. Are you running this in the correct configuration directory? $($_.exception.message)"
            #bail out because no other commands are likely to work
            return
        }
        Write-Host -ForegroundColor Green -Object @"

        Next Steps:

        To enable Internet access for the VM's, run:
        Enable-Internet

        Run the following to validatae when configurations have converged:
        Validate-Lab

        To stop the lab VM's:
        Shutdown-lab

        When the configurations have finished, you can checkpoint the VM's with:
        Snapshot-Lab

        To quickly rebuild the labs from the checkpoint, run:
        Refresh-Lab

        To destroy the lab to build again:
        Wipe-Lab


"@
    } #whatif
}
#endregion setup-lab

#region Enable-Internet
Function Enable-Internet {
    [cmdletbinding(SupportsShouldProcess)]
    Param (
        [Parameter(HelpMessage = "The path to the configuration folder. Normally, you should run all commands from within the configuration folder.")]
        [ValidateNotNullorEmpty()]
        [ValidateScript( { Test-Path $_ })]
        [string]$Path = "."
    )

    $Path = Convert-Path $path
    Write-Host -ForegroundColor Green -Object @"

        This is the Enable-Internet script. This script will perform the following:

        * Enable Internet to the VM's using NAT

        * Note! - If this generates an error, you are already enabled, or one of the default settings below
                  does not match your .PSD1 configuration

"@

    $LabData = Import-PowerShellDataFile -Path $path\*.psd1
    $LabSwitchName = $labdata.NonNodeData.Lability.Network.name
    $GatewayIP = $Labdata.AllNodes.DefaultGateway
    $GatewayPrefix = $Labdata.AllNodes.SubnetMask
    $NatNetwork = $Labdata.AllNodes.IPnetwork
    $NatName = $Labdata.AllNodes.IPNatName

    $Index = Get-NetAdapter -name "vethernet ($LabSwitchName)" | Select-Object -ExpandProperty InterfaceIndex

    if ($pscmdlet.ShouldProcess("Interface index $index", "New-NetIPAddress")) {
        New-NetIPAddress -InterfaceIndex $Index -IPAddress $GatewayIP -PrefixLength $GatewayPrefix -ErrorAction SilentlyContinue
    }

    # Creating the NAT on Server 2016 -- maybe not work on 2012R2
    if ($pscmdlet.ShouldProcess($NatName, "New-NetNat")) {
        New-NetNat -Name $NatName -InternalIPInterfaceAddressPrefix $NatNetwork -ErrorAction SilentlyContinue
    }

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
        [Parameter(HelpMessage = "The path to the configuration folder. Normally, you should run all commands from within the configuration folder.")]
        [ValidateNotNullorEmpty()]
        [ValidateScript(
            { Test-Path $_ })]
        [string]$Path = "."
    )

    $Path = Convert-Path $path

    $msg = @"
    [$(Get-Date)]
    Starting the VM testing process. This could take some time to
    complete depending on the complexity of the configuration. You can press
    Ctrl+C at any time to break out of the testing loop.

    If you feel the test is taking too long, break out of the testing loop
    and manually run the test:

    invoke-pester .\vmvalidate.test.ps1

    If only one of the VMs appears to be failing, you might try stopping
    and restarting it with the Hyper-V Manager or the cmdlets:

    Stop-VM <vmname>
    Start-VM <vmname>

    Errors are expected until all tests complete successfully.

"@
    Write-Host $msg  -ForegroundColor Cyan

    $Complete = $False

    #define a resolved path to the test file
    $testPath = Join-Path -path $path -ChildPath VMValidate.test.ps1
    do {


        $test = Invoke-Pester -Script $testpath -Show none -PassThru

        if ($test.Failedcount -eq 0) {
            $Complete = $True
        }
        else {
            #test every 5 minutes
            300..1 | ForEach-Object {
                Write-Progress -Activity "VM Completion Test" -Status "Tests failed" -CurrentOperation "Waiting until next test run" -SecondsRemaining $_
                Start-Sleep -Seconds 1
            }
        }
    } until ($Complete)

    #re-run test one more time to show everything that was tested.
    Invoke-Pester -Script $path\VMValidate.Test.ps1

    Write-Progress -Activity "VM Completion Test" -Completed
    Write-Host "[$(Get-Date)] VM setup and configuration complete. It is recommended that you snapshot the VMs with Snapshot-Lab" -ForegroundColor Green

}
#endregion Validate-Lab

#region Shutdown-Lab
Function Invoke-ShutdownLab {
    [cmdletbinding(SupportsShouldProcess)]
    [alias("Shutdown-Lab")]
    Param (
        [Parameter(HelpMessage = "The path to the configuration folder. Normally, you should run all commands from within the configuration folder.")]
        [ValidateNotNullorEmpty()]
        [ValidateScript( { Test-Path $_ })]
        [string]$Path = "."
    )

    $Path = Convert-Path $path
    Write-Host -ForegroundColor Green -Object @"

        This is the Shutdown-Lab command. It will perform the following:

        * Shutdown the Lab environment:

"@

    $labname = Split-Path $path -leaf
    Write-Host -ForegroundColor Cyan -Object 'Stopping the lab environment'
    # Creates the lab environment without making a Hyper-V Snapshot
    if ($pscmdlet.ShouldProcess($labname, "Stop-Lab")) {
        Try {
            Stop-Lab -ConfigurationData $path\*.psd1 -erroraction Stop
        }
        Catch {
            Write-Warning "Failed to stop lab. Are you running this in the correct configuration directory? $($_.exception.message)"
            #bail out because no other commands are likely to work
            return
        }
    }

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
    [cmdletbinding(SupportsShouldProcess)]
    [alias("Snapshot-Lab")]
    Param (
        [Parameter(HelpMessage = "The path to the configuration folder. Normally, you should run all commands from within the configuration folder.")]
        [ValidateNotNullorEmpty()]
        [ValidateScript( { Test-Path $_ })]
        [string]$Path = ".",
        [Parameter(HelpMessage = "Specify a name for the virtual machine checkpoint")]
        [ValidateNotNullorEmpty()]
        [string]$SnapshotName = "LabConfigured"
    )

    $Path = Convert-Path $path

    Write-Host -ForegroundColor Green -Object @"

        This is the Snapshot-Lab command. It will perform the following:

        * Snapshot the lab environment for easy and fast rebuilding

        Note! This should be done after the configurations have finished

"@
    $labname = Split-Path $Path -leaf
    Write-Host -ForegroundColor Cyan -Object 'Snapshot the lab environment'
    # Creates the lab environment without making a Hyper-V Snapshot
    if ($pscmdlet.ShouldProcess($labname, "Stop-Lab")) {

        Try {
            Stop-Lab -ConfigurationData $path\*.psd1 -ErrorAction Stop
        }
        Catch {
            Write-Warning "Failed to stop lab. Are you running this in the correct configuration directory? $($_.exception.message)"
            #bail out because no other commands are likely to work
            return
        }

    }
    if ($pscmdlet.ShouldProcess($labname, "Checkpoint-Lab")) {
        Checkpoint-Lab -ConfigurationData $path\*.psd1 -SnapshotName $SnapshotName
    }

    Write-Host -ForegroundColor Green -Object @"

       Next Steps:

        To start the lab environment, run:
        Run-Lab

        To quickly rebuild the labs from the checkpoint, run:
        Refresh-Lab

"@
}
#endregion

#region Refresh-Lab
Function Invoke-RefreshLab {
    [cmdletbinding(SupportsShouldProcess)]
    [alias("Refresh-Lab")]
    Param (
        [Parameter(HelpMessage = "The path to the configuration folder. Normally, you should run all commands from within the configuration folder.")]
        [ValidateNotNullorEmpty()]
        [ValidateScript( { Test-Path $_ })]
        [string]$Path = ".",
        [Parameter(HelpMessage = "Specify a name for the virtual machine checkpoint")]
        [ValidateNotNullorEmpty()]
        [string]$SnapshotName = "LabConfigured"
    )

    $Path = Convert-Path $path

    Write-Host -ForegroundColor Green -Object @"

        This command will perform the following:

        * Refresh the lab from a previous Snapshot

        You will be prompted to restore the snapshot
        for each VM, although the prompt won't show
        you the virtual machine name.

        Note! This can only be done if you created a
        snapshot using Snapshot-Lab

"@
    $labname = Split-Path $path -leaf
    Write-Host -ForegroundColor Cyan -Object 'Restore the lab environment from a snapshot'

    Try {
        if ($pscmdlet.ShouldProcess($labname, "Stop-Lab")) {
            Stop-Lab -ConfigurationData $path\*.psd1 -ErrorAction Stop
        }
    }
    Catch {
        Write-Warning "Failed to stop lab. Are you running this in the correct configuration directory? $($_.exception.message)"
        #bail out because no other commands are likely to work
        return
    }

    if ($pscmdlet.ShouldProcess($SnapshotName, "Restore-Lab")) {
        Restore-Lab -ConfigurationData $path\*.psd1 -SnapshotName $SnapshotName -force
    }

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
    [cmdletbinding(SupportsShouldProcess)]
    [alias("Wipe-Lab")]
    Param (
        [Parameter(HelpMessage = "The path to the configuration folder. Normally, you should run all commands from within the configuration folder.")]
        [ValidateNotNullorEmpty()]
        [ValidateScript( { Test-Path $_ })]
        [string]$Path = ".",
        [Parameter(HelpMessage = "Remove the VM Switch. It is retained by default")]
        [switch]$RemoveSwitch,
        [Parameter(HelpMessage = "Remove lab elements with no prompting.")]
        [switch]$Force
    )

    $Path = Convert-Path $path

    Write-Host -ForegroundColor Green -Object @"

        This command will perform the following:

        * Wipe the lab and VM's from your system for this configuration

        If you intend to rebuild labs or run other configurations you
        do not need to remove the LabNat PolicyStore Local.

        Press Ctrl+C to abort this command.

"@

    if (-Not $Force) {
        Pause
    }

    $removeParams = @{
        ConfigurationData = "$path\*.psd1"
    }

    if ($force) {
        $removeParams.Add("confirm", $False)
    }
    $labname = Split-Path $path -leaf
    Write-Host -ForegroundColor Cyan -Object "Removing the lab environment for $labname"

    # Stop the VM's
    if ($pscmdlet.ShouldProcess("VMs", "Stop-Lab")) {

        Try {
            Stop-Lab -ConfigurationData $path\*.psd1 -ErrorAction Stop
        }
        Catch {
            Write-Warning "Failed to stop lab. Are you running this in the correct configuration directory? $($_.exception.message)"
            #bail out because no other commands are likely to work
            return
        }
    }
    # Remove .mof iles
    Remove-Item -Path $path\*.mof

    if ($RemoveSwitch) {
        $removeParams.Add("RemoveSwitch", $True)
        # Delete NAT
        $LabData = Import-PowerShellDataFile -Path $path\*.psd1
        $NatName = $Labdata.AllNodes.IPNatName
        if ($pscmdlet.ShouldProcess("LabNat", "Remove NetNat")) {
            Remove-NetNat -Name $NatName
        }
    }
    # Delete vM's
    if ($pscmdlet.ShouldProcess("VMConfigurationData.psd1", "Remove lab configuration")) {

        Remove-LabConfiguration @removeParams
    }

    #only delete the VHD files associated with the configuration as you might have more than one configuration
    #running
    $nodes = ($labdata.allnodes.nodename).where( { $_ -ne '*' })
    Get-ChildItem (Get-LabHostDefault).differencingVHDPath | Where-Object { $nodes -contains $_.basename } | Remove-Item
    #Remove-Item -Path "$((Get-LabHostDefault).DifferencingVHdPath)\*" -Force

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
        [Parameter(HelpMessage = "The path to the configuration folder. Normally, you should run all commands from within the configuration folder.")]
        [ValidateNotNullorEmpty()]
        [ValidateScript( { Test-Path $_ })]
        [string]$Path = ".",
        [switch]$AsJob
    )

    $Path = Convert-Path $path


    $sb = {
        [cmdletbinding()]
        Param([string]$Path, [bool]$WhatIf)

        $WhatIfPreference = $WhatIf
        [void]$psboundparameters.remove("WhatIf")

        $msg = @"

        This runs Setup-Lab, Run-Lab, and Validate-Lab commands
        Starting the lab environment
"@

        Write-Host $msg -ForegroundColor Green

        if ($pscmdlet.ShouldProcess("Setup-Lab", "Run Unattended")) {
            Invoke-SetupLab @psboundparameters
        }
        if ($pscmdlet.ShouldProcess("Run-Lab", "Run Unattended")) {
            Invoke-RunLab @psboundparameters
        }
        if ($pscmdlet.ShouldProcess("Enable-Internet", "Run Unattended")) {
            Enable-Internet @psboundparameters
        }
        if ($pscmdlet.ShouldProcess("Validate-Lab", "Run Unattended")) {
            Invoke-ValidateLab @psboundparameters
        }


        $msg = @"

        Unattended setup is complete.

        To stop the lab VM's:
        Shutdown-lab

        When the configurations have finished, you can checkpoint the VM's with:
        Snapshot-Lab

        To quickly rebuild the labs from the checkpoint, run:
        Refresh-Lab
"@
        Write-Host $msg -ForegroundColor Green
    } #close scriptblock

    $icmParams = @{
        Computername = $env:computername
        ArgumentList = @($Path, $WhatIfPreference)
        Scriptblock  = $sb
    }

    if ($asjob) {
        $icmParams.Add("AsJob", $True)
    }
    Invoke-Command @icmParams
}
#endregion Unattend-Lab

#region Get-LabSnapshot
Function Get-LabSnapshot {
    [cmdletbinding()]
    Param (
        [Parameter(HelpMessage = "The path to the configuration folder. Normally, you should run all commands from within the configuration folder.")]
        [ValidateNotNullorEmpty()]
        [ValidateScript( { Test-Path $_ })]
        [string]$Path = "."
    )

    Write-Verbose "Starting $($myinvocation.mycommand)"

    $Path = Convert-Path $path
    Write-Verbose "Getting mofs from $(Convert-Path $Path)"

    $VMs = (Get-ChildItem -path $path -filter *.mof -exclude *meta* -recurse).Basename
    if ($VMs) {

        Write-Verbose "Getting VMSnapshots for $($VMs -join ',')"

        $snaps = Get-VMSnapshot -vmname  $VMs
        if ($snaps) {
            $snaps
            Write-Host "All VMs in the configuration should belong to the same snapshot if you want to use Refresh-Lab." -foreground green
        }
        else {
            Write-Host "No VM snapshots found for lab machines in $path." -ForegroundColor yellow
        }
    }
    else {
        Write-Warning "No configuration MOF files found in $Path."
    }

    Write-Verbose "Ending $($myinvocation.mycommand)"
}

#endregion

#region Update-Lab

Function Update-Lab {
    [cmdletbinding()]
    Param(
        [Parameter(HelpMessage = "The path to the configuration folder. Normally, you should run all commands from within the configuration folder.")]
        [ValidateNotNullorEmpty()]
        [ValidateScript( { Test-Path $_ })]
        [string]$Path = ".",
        [switch]$AsJob
    )

    Begin {
        Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"
        $data = Import-PowerShellDataFile -Path $path\*.psd1

        $upParams = @{
            VMName     = $null
            Credential = $null
        }
        if ($AsJob) {
            Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Will update as background job"
            $upParams.Add("AsJob", $True)
        }
    } #begin

    Process {
        Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Updating Lab"
        if ($data) {
            $pass = ConvertTo-SecureString -String $data.AllNodes.labpassword -AsPlainText -Force
            $domain = $data.AllNodes.domainName
            $domcred = New-Object PSCredential -ArgumentList "$($domain)\administrator", $pass
            $wgcred = New-Object PSCredential -ArgumentList "administrator", $pass

            #get defined nodes
            $nodes = ($data.allnodes).where( { $_.nodename -ne '*' })
            foreach ($node in $nodes) {
                Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] ... $($node.nodename)"

                #verify VM is running
                $vm = Get-VM -name $node.Nodename
                if ($vm.state -ne 'running') {
                    Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] ... Starting VM $($node.nodename)"
                    $vm | Start-VM
                    Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] ... Waiting 30 seconds to give VM time to boot"
                    Start-Sleep -seconds 30
                }

                $upParams.VMName = $node.nodename
                if ($node.role -contains "DC" -or $node.role -contains "DomainJoin") {
                    $upParams.Credential = $domcred
                }
                else {
                    $upParams.Credential = $wgcred
                }

                Invoke-WUUpdate @upParams
            }
        }
        else {
            Throw "Failed to find lab configuration data"
        }

    } #process

    End {
        Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"

    } #end

} #close Update-Lab

#endregion