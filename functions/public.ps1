#region Get-LabSummary

Function Get-LabSummary {
    [cmdletbinding()]
    [Alias("Setup-Lab")]
    Param (
        [Parameter(Position = 0, ValueFromPipeline, HelpMessage = "The PATH to the lab configuration folder. Normally, you should run all commands from within the configuration folder. Do not include the psd1 file name.")]
        [ValidateNotNullorEmpty()]
        [ValidateScript( {Test-Path $_ })]
        [string]$Path = "."
    )

    Begin {
        Write-Verbose "Starting $($myinvocation.mycommand)"
    }
    Process {
        $Path = Convert-Path $path
        Write-Verbose "Searching in $path for VMConfigurationData.psd1"
        $psd1 = $(Join-Path $Path -childpath Vmconfigurationdata.psd1)

        if (Test-Path $psd1) {
            $labname = Split-Path $Path -leaf
            Write-Verbose "getting summary for $labname"

            #could also use the Get-LabMedia command from the Lability module
            $media = [ordered]@{
                '2019_x64_Standard_EN_Eval'               = 'Windows Server 2019 Standard 64bit English Evaluation with Desktop Experience'
                '2019_x64_Standard_EN_Core_Eval'          = 'Windows Server 2019 Standard 64bit English Evaluation'
                '2019_x64_Datacenter_EN_Eval'             = 'Windows Server 2019 Datacenter 64bit English Evaluation with Desktop Experience'
                '2019_x64_Datacenter_EN_Core_Eval'        = 'Windows Server 2019 Datacenter Evaluation in Core mode'
                '2016_x64_Standard_EN_Eval'               = 'Windows Server 2016 Standard 64bit English Evaluation'
                '2016_x64_Standard_Nano_DSC_EN_Eval'      = 'Windows Server 2016 Standard Nano 64bit English Evaluation'
                '2016_x64_Standard_Core_EN_Eval'          = 'Windows Server 2016 Standard Core 64bit English Evaluation'
                '2016_x64_Datacenter_EN_Eval'             = 'Windows Server 2016 Datacenter 64bit English Evaluation'
                '2016_x64_Datacenter_Core_EN_Eval'        = 'Windows Server 2016 Datacenter Core 64bit English Evaluation'
                '2016_x64_Standard_Nano_EN_Eval'          = 'Windows Server 2016 Standard Nano 64bit English Evaluation'
                '2016_x64_Datacenter_Nano_EN_Eval'        = 'Windows Server 2016 Datacenter Nano 64bit English Evaluation'
                '2012R2_x64_Standard_EN_Eval'             = 'Windows Server 2012 R2 Standard 64bit English Evaluation'
                '2012R2_x64_Standard_EN_V5_Eval'          = 'Windows Server 2012 R2 Standard 64bit English Evaluation with WMF 5'
                '2012R2_x64_Standard_EN_V5_1_Eval'        = 'Windows Server 2012 R2 Standard 64bit English Evaluation with WMF 5.1'
                '2012R2_x64_Standard_Core_EN_Eval'        = 'Windows Server 2012 R2 Standard Core 64bit English Evaluation'
                '2012R2_x64_Standard_Core_EN_V5_Eval'     = 'Windows Server 2012 R2 Standard Core 64bit English Evaluation with WMF 5'
                '2012R2_x64_Standard_Core_EN_V5_1_Eval'   = 'Windows Server 2012 R2 Standard Core 64bit English Evaluation with WMF 5.1'
                '2012R2_x64_Datacenter_EN_Eval'           = 'Windows Server 2012 R2 Datacenter 64bit English Evaluation'
                '2012R2_x64_Datacenter_EN_V5_Eval'        = 'Windows Server 2012 R2 Datacenter 64bit English Evaluation with WMF 5'
                '2012R2_x64_Datacenter_EN_V5_1_Eval'      = 'Windows Server 2012 R2 Datacenter 64bit English Evaluation with WMF 5.1'
                '2012R2_x64_Datacenter_Core_EN_Eval'      = 'Windows Server 2012 R2 Datacenter Core 64bit English Evaluation'
                '2012R2_x64_Datacenter_Core_EN_V5_Eval'   = 'Windows Server 2012 R2 Datacenter Core 64bit English Evaluation with WMF 5'
                '2012R2_x64_Datacenter_Core_EN_V5_1_Eval' = 'Windows Server 2012 R2 Datacenter Core 64bit English Evaluation with WMF 5.1'
                'WIN81_x64_Enterprise_EN_Eval'            = 'Windows 8.1 64bit Enterprise English Evaluation'
                'WIN81_x64_Enterprise_EN_V5_Eval'         = 'Windows 8.1 64bit Enterprise English Evaluation with WMF 5'
                'WIN81_x64_Enterprise_EN_V5_1_Eval'       = 'Windows 8.1 64bit Enterprise English Evaluation with WMF 5.1'
                'WIN81_x86_Enterprise_EN_Eval'            = 'Windows 8.1 32bit Enterprise English Evaluation'
                'WIN81_x86_Enterprise_EN_V5_Eval'         = 'Windows 8.1 32bit Enterprise English Evaluation with WMF 5'
                'WIN81_x86_Enterprise_EN_V5_1_Eval'       = 'Windows 8.1 32bit Enterprise English Evaluation with WMF 5.1'
                'WIN10_x64_Enterprise_EN_Eval'            = 'Windows 10 64bit Enterprise 1903 English Evaluation'
                'WIN10_x86_Enterprise_EN_Eval'            = 'Windows 10 32bit Enterprise 1903 English Evaluation'
                'WIN10_x64_Enterprise_LTSC_EN_Eval'       = 'Windows 10 64bit Enterprise LTSC 2019 English Evaluation'
                'WIN10_x86_Enterprise_LTSC_EN_Eval'       = 'Windows 10 32bit Enterprise LTSC 2019 English Evaluation'
            }
            Write-Verbose "Getting node data from $psd1"
            $Nodes = (Import-PowerShellDataFile -Path $psd1).allNodes

            $nodes.where( {$_.Nodename -ne '*'}).Foreach( {
                    if ($_.lability_startupmemory) {
                        $mem = $_.lability_startupmemory
                    }
                    elseif ($_.lability_MinimumMemory) {
                        $mem = $_.lability_minimummemory
                    }
                    else {
                        $mem = $nodes[0].Lability_MinimumMemory
                    }
                    if ($_.Lability_ProcessorCount) {
                        $ProcCount = $_.Lability_ProcessorCount
                    }
                    else {
                        $ProcCount = 1
                    }
                    [pscustomobject]@{
                        PSTypeName   = "PSAutolabVM"
                        Computername = $_.NodeName
                        InstallMedia = $_.lability_media
                        Description  = $media[$_.lability_media]
                        Role         = $_.Role
                        IPAddress    = $_.IPAddress
                        MemoryGB     = $mem / 1GB
                        Processors   = $ProcCount
                        Lab          = $labname
                    }
                })
        }
        else {
            Write-Warning "Failed to find $psd1."
        }
    } #process

    End {
        Write-Verbose "Ending $($myinvocation.mycommand)"
    }
}

#endregion

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

    #get Autolab folder if installed and free hard drive space
    Try {
        $LabHost = Lability\Get-LabHostDefault -ErrorAction stop
        $AutoLab = Split-Path $LabHost.ConfigurationPath
        $free = (Get-Volume $autolab[0]).SizeRemaining
    }
    Catch {
        $AutoLab = "NotFound"
        $free = (Get-Volume C).SizeRemaining  #Assume C drive
    }

    [pscustomobject]@{
        AutoLab         = $Autolab
        PSVersion       = $psver.PSVersion
        PSEdition       = $psver.PSEdition
        OS              = $os
        FreeSpaceGB     = [math]::Round($free / 1GB, 2)
        MemoryGB        = ($mem * 1kb) / 1GB -as [int]
        PctFreeMemory   = $pctFree
        Processor       = (Get-CimInstance -classname Win32_Processor -property Name).Name
        IsElevated      = (Test-IsAdministrator)
        RemotingEnabled = $(try {[void](Test-WSMan -erroraction stop); $True} catch { $false})
        HyperV          = (Get-Item $env:windir\System32\vmms.exe).versioninfo.productversion
        PSAutolab       = (Get-Module -name PSAutolab -ListAvailable | Sort-Object -Property Version -Descending).version
        Lability        = (Get-Module -name Lability -ListAvailable | Sort-Object -Property Version -Descending).version
        Pester          = (Get-Module -name Pester -ListAvailable | Sort-Object -Property Version -Descending).version
        PowerShellGet   = (Get-Module -name PowerShellGet -ListAvailable | Sort-Object -Property Version -Descending | Select-Object -first 1).version
        PSDesiredStateConfiguration = (Get-Module -name PSDesiredStateConfiguration -ListAvailable | Sort-Object -Property Version -Descending | Select-Object -first 1).version
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
        [string]$Destination = (Get-LabHostDefault).configurationpath,
        [switch]$SkipPublisherCheck
    )

    #test if a new version of lability is required
    if ($pscmdlet.ShouldProcess("version $LabilityVersion", "Check for Lability Requirements")) {
        _LabilityCheck -requiredVersion $LabilityVersion -skipPublishercheck:$SkipPublisherCheck
    }

    #test and update Pester as needed
    if ($pscmdlet.ShouldProcess("version $PesterVersion", "Check for required Pester version")) {
        _PesterCheck
    }

    # Setup Path Variables
    $SourcePath = $ConfigurationPath

    Microsoft.PowerShell.Utility\Write-Host "Updating configuration files from $sourcePath" -ForegroundColor Cyan
    if ($pscmdlet.ShouldProcess($Destination, "Copy configurations")) {
        if (Test-Path $Destination) {
            Copy-Item -Path $SourcePath\* -recurse -Destination $Destination -force
        }
        else {
            Write-Warning "Can't find target path $Destination."
        }
    }

    Microsoft.PowerShell.Utility\Write-Host "This process will not remove any configurations that have been deleted from the module." -ForegroundColor yellow
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

    Clear-Host

    # Setup Path Variables
    #use module defined variable
    $SourcePath = $ConfigurationPath

    Write-Verbose "Starting $($invocation.mycommand)"
    Write-Verbose "SourcePath = $SourcePath"

    Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Green -Object @"

    This is the Setup-Host script. This script will perform the following:

    * For PowerShell Remoting, configure the host 'TrustedHosts' value to *
    * Install the Lability module from PSGallery
    * Update the Pester module if necessary
    * Install Hyper-V
    * Create the $DestinationPath folder (DO NOT DELETE)
    * Copy configurations and resources to $DestinationPath
    * You will then need to reboot the host before continuing

"@

    Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Yellow -Object @"

    !!IMPORTANT SECURITY NOTE!!

    This module will set trusted hosts to connect to any machine on the local network.
    This is NOT a recommended security practice. It is assumed you are installing this
    module on a non-production machine and are willing to accept this potential risk
    for the sake of a training and test environment.

    If you do not want to proceed, press Ctrl-C.
"@

    Pause

    # For remoting commands to VM's - have the host set trustedhosts
    Write-Verbose "Enable PSRemoting"
    Enable-PSRemoting -force -SkipNetworkProfileCheck

    Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Cyan -Object "Setting TrustedHosts so that remoting commands to VMs work properly"
    $trust = Get-Item -Path WSMan:\localhost\Client\TrustedHosts
    if (($Trust.Value -eq "*") -or ($trust.Value -match "<local>")) {
        Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Green -Object "TrustedHosts is already set to *. No changes needed"
    }
    else {
        $add = '<local>' # Jeffs idea - 'DC,S*,Client*,192.168.3.' - need to automate this, not hard code
        Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Cyan -Object "Adding $add to TrustedHosts"
        Set-Item -Path WSMan:\localhost\Client\TrustedHosts -Value $add -Concatenate -force
    }

    # Lability install
    Write-Verbose "Bootstrapping Nuget install"
    Install-PackageProvider -Name Nuget -ForceBootstrap
    Write-Verbose "Setting PSGallery as a trusted package source"
    Get-PackageSource -Name PSGallery | Set-PackageSource -Trusted -Force -ForceBootstrap | Out-Null

    <#
 Test if the current version of Lability is already installed. If so, do nothing.
 If an older version is installed, update the version, otherwise install the latest version.
#>

    #update Pester as needed
    Write-Verbose "Calling internal Pester check"
    _PesterCheck

    #use the module defined variable and a private function
    if ($pscmdlet.ShouldProcess("Lability $labilityVersion", "Install or Update Lability")) {
        Write-Verbose "Calling internal Lability check"
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

    Write-Verbose "Set-LabHostDefault"
    Lability\Set-LabHostDefault @DirDef

    Write-Verbose "Test-LabHostConfiguration"
    $HostStatus = Lability\Test-LabHostConfiguration
    If (-Not $HostStatus ) {
        Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Cyan "Starting to Initialize host and install Hyper-V"
        if ($pscmdlet.shouldprocess($DirDef.ConfigurationPath,"Lability\Start-LabHostConfiguration")) {
            Lability\Start-LabHostConfiguration -ErrorAction SilentlyContinue
        }
    }

    ###### COPY Configs to host machine
    Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Cyan -Object "Copying configs to $($DirDef.ConfigurationPath)"
    if ($pscmdlet.ShouldProcess($DirDef.ConfigurationPath, "Copy configurations")) {
        Copy-Item -Path $SourcePath\* -recurse -Destination $DirDef.ConfigurationPath -force
    }

    if ($pscmdlet.ShouldProcess($env:computername, "Prompt for restart")) {

        Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Green -Object @"

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
    Write-Verbose "Ending $($invocation.mycommand)"
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
        [switch]$IgnorePendingReboot,
        [Parameter(HelpMessage = "Override any configuration specified time zone and use the local time zone on this computer.")]
        [switch]$UseLocalTimeZone,
        [Parameter(HelpMessage = "Run the command but suppress all status messages.")]
        [switch]$NoMessages
    )

    Write-Verbose "Starting $($myinvocation.mycommand)"

    $Path = Convert-Path $path
    $labname = Split-Path $Path -leaf
    $LabData = Import-PowerShellDataFile -Path $(Join-Path $Path -childpath *.psd1)
    $DSCResources = $LabData.NonNodeData.Lability.DSCResource
    if (-Not $DSCResources) {
        Write-Warning "Failed to find DSC Resource information. Are you in a directory with configuration data .psd1 file?"
        #bail out
        return
    }

    if (-Not $NoMessages) {

        Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Green -Object @"

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
    }

    if ($UseLocalTimeZone) {
        #modifying this old code since it doesn't translate properly from some
        #non-US locations. (Issue #227)
        # $localtz = [System.TimeZone]::CurrentTimeZone.StandardName
        $localtz = (Get-TimeZone).ID
        Write-Verbose "Using local time zone $localtz"
        if ($LabData.allnodes.count -gt 1) {
            if (-Not $NoMessages) {
                Microsoft.PowerShell.Utility\Write-Host "Overriding configured time zones to use $localtz" -ForegroundColor yellow
            }
            $nodes = $labdata.allnodes.where( {$_.nodename -ne "*"})
            foreach ($node in $nodes) {
               # $tz = $node.Lability_timezone
                $node.Lability_timeZone = $localtz
            }
        }
        else {
            if (-Not $NoMessages) {
                Microsoft.PowerShell.Utility\Write-Host "Updating Allnodes to $localtz" -ForegroundColor Yellow
            }
            $LabData.AllNodes.Lability_TimeZone = $localtz
        }
    } #use local timezone

    $LabData.allnodes | Out-String | Write-Verbose

    Write-Verbose "Install DSC Resource modules specified in the .PSD1"

    If (-Not $NoMessages) {
        Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Cyan -Object 'Installing required DSCResource modules from PSGallery'
        Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Yellow -Object 'You may need to say "yes" to a Nuget Provider'
    }
    #force updating/installing nuget to bypass the prompt
    [void](Install-PackageProvider -Name nuget -Force -ForceBootstrap)

    Foreach ($DSCResource in $DSCResources) {
        #test if current version is installed otherwise update or install it
        $dscmod = Get-Module -FullyQualifiedName @{Modulename = $DSCResource.name; ModuleVersion = $DSCResource.RequiredVersion } -ListAvailable

        if ((-not $dscmod ) -or ($dscmod.version -ne $DSCResource.RequiredVersion)) {
            if (-Not $NoMessages) {
                Microsoft.PowerShell.Utility\Write-Host "install $($dscresource.name) version $($DSCResource.requiredversion)" -ForegroundColor yellow
            }
            if ($pscmdlet.ShouldProcess($DSCResource.name, "Install-Module")) {
                Install-Module -Name $DSCResource.Name -RequiredVersion $DSCResource.RequiredVersion
            }
        }
        elseif ($dscmod.version -ne ($DSCResource.RequiredVersion -as [version])) {
            if (-not $NoMessages) {
                Microsoft.PowerShell.Utility\Write-Host "Update $($dscmod.name) to version $($DSCResource.requiredversion)" -ForegroundColor cyan
            }
            if ($pscmdlet.ShouldProcess($DSCResource.name, "Update-Module")) {
                Update-Module -Name $DSCResource.Name -RequiredVersion $DSCResource.RequiredVersion
            }
        }
        else {
            If (-Not $nomessages) {
                Microsoft.PowerShell.Utility\Write-Host "$($dscmod.name) [v$($dscmod.version)] requires no updates." -ForegroundColor green
            }
        }
    }

    Write-Verbose "Run the config to generate the .mof files"
    If (-Not $NoMessages) {
        Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Cyan -Object 'Build the .Mof files from the configs'
    }
    $vmconfig = Join-Path -Path $path -ChildPath 'VMConfiguration.ps1'
    if ($PSCmdlet.ShouldProcess($vmConfig)) {
        . $VMConfig
    }
    # Build the lab without a snapshot

    if (-Not $NoMessages) {
        Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Cyan -Object "Building the lab environment for $labname"
    }

    # Creates the lab environment without making a Hyper-V Snapshot
    $Password = ConvertTo-SecureString -String "$($labdata.allnodes.labpassword)" -AsPlainText -Force
    $startParams = @{
        ConfigurationData   = $LabData
        #Import-PowerShellDataFile -path (Join-Path -path $path -childpath "VMConfigurationdata.psd1")
        Path                = $Path
        NoSnapshot          = $True
        Password            = $Password
        IgnorePendingReboot = $True
        WarningAction       = "SilentlyContinue"
        ErrorAction         = "stop"
    }

    Write-Verbose "Using these start parameters"
    Write-Verbose ($startParams | Out-String)
    if ($PSCmdlet.ShouldProcess($labname, "Start-LabConfiguration")) {
        Try {
            Write-Verbose "Invoking Start-LabConfiguration"
            Lability\Start-LabConfiguration @startParams
        }
        Catch {
            Microsoft.PowerShell.Utility\Write-Host "Failed to start lab configuration." -foreground red
            throw $_
        }
        Write-Verbose "Disable secure boot for VM's"
        $VM = Hyper-V\Get-VM ( Lability\Get-LabVM -ConfigurationData "$path\*.psd1" ).Name
        Hyper-V\Set-VMFirmware -VM $vm -EnableSecureBoot Off -SecureBootTemplate MicrosoftUEFICertificateAuthority

        If (-Not $NoMessages) {

            Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Green -Object @"

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
        }

    } #should process

    Write-Verbose "Ending $($myinvocation.mycommand)"
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
        [string]$Path = ".",
        [Parameter(HelpMessage = "Run the command but suppress all status messages.")]
        [switch]$NoMessages
    )

    $Path = Convert-Path $path

    if (-Not $NoMessages) {

        Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Green -Object @"

        This is the Run-Lab script. This script will perform the following:

        * Start the Lab environment

        Note! If this is the first time you have run this, it can take up to an hour
        for the DSC configurations to apply and converge.

"@
    }

    $labname = Split-Path (Get-Location) -leaf
    $datapath = Join-Path $(Convert-Path $path) -childpath "*.psd1"

    if (-Not $NoMessages) {
        Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Cyan -Object "Starting the lab environment from $datapath"
    }
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

        if (-Not $NoMessages) {

            Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Green -Object @"

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
        }
    } #whatif
}
#endregion Run-lab

#region Enable-Internet
Function Enable-Internet {
    [cmdletbinding(SupportsShouldProcess)]
    Param (
        [Parameter(HelpMessage = "The path to the configuration folder. Normally, you should run all commands from within the configuration folder.")]
        [ValidateNotNullorEmpty()]
        [ValidateScript( { Test-Path $_ })]
        [string]$Path = ".",
        [Parameter(HelpMessage = "Run the command but suppress all status messages.")]
        [switch]$NoMessages
    )

    $Path = Convert-Path $path

    if (-Not $NoMessages) {

        Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Green -Object @"

        This is the Enable-Internet script. This script will perform the following:

        * Enable Internet to the VM's using NAT

        * Note! - If this generates an error, you are already enabled, or one of the default settings below
        does not match your .PSD1 configuration
"@
    }

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

    if (-Not $NoMessages) {

        Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Green -Object @"

        Next Steps:

        When complete, run:
        Run-Lab

        And run:
        Validate-Lab

"@
    }
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
        [string]$Path = ".",
        [Parameter(HelpMessage = "Run the command but suppress all status messages.")]
        [switch]$NoMessages
    )

    Write-Verbose "Starting $($myinvocation.mycommand)"

    #remove pester v5
    Get-Module Pester | Remove-Module -force
    Write-Verbose "Importing Pester module version $PesterVersion"
    #use the module specific version of Pester
    Import-Module -name Pester -RequiredVersion $PesterVersion -force -Global
    $Path = Convert-Path $path
    Write-Verbose "Using path $path"

    If (-Not $NoMessages) {

    $msg = @"
    [$(Get-Date)]
    Starting the VM testing process. This could take some time to
    complete depending on the complexity of the configuration. You can press
    Ctrl+C at any time to break out of the testing loop.

    If you feel the test is taking too long, break out of the testing loop
    and manually run the test:

        Invoke-Pester .\vmvalidate.test.ps1

    Make sure you are using version $PesterVsion of the Pester module.
    Remove any other versions first and then re-import

        Get-Module Pester | Remove-Module -force
        Import-Module -name Pester -RequiredVersion $PesterVersion -force

    If only one of the VMs appears to be failing, you might try stopping
    and restarting it with the Hyper-V Manager or the cmdlets:

        Stop-VM <vmname>
        Start-VM <vmname>

    Errors are expected until all tests complete successfully.

"@
        Microsoft.PowerShell.Utility\Write-Host $msg  -ForegroundColor Cyan
    }

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
    if (-Not $NoMessages) {
        Microsoft.PowerShell.Utility\Write-Host "[$(Get-Date)] VM setup and configuration complete. It is recommended that you snapshot the VMs with Snapshot-Lab" -ForegroundColor Green
    }
    Write-Verbose "Ending $($myinvocation.mycommand)"
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
        [string]$Path = ".",
        [Parameter(HelpMessage = "Run the command but suppress all status messages.")]
        [switch]$NoMessages
    )

    $Path = Convert-Path $path

    if (-Not $NoMessages) {

        Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Green -Object @"

        This is the Shutdown-Lab command. It will perform the following:

        * Shutdown the Lab environment:

"@
    }

    $labname = Split-Path $path -leaf
    if (-Not $noMessages) {
        Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Cyan -Object 'Stopping the lab environment'
    }
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

    if (-Not $NoMessages) {

        Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Green -Object @"

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
        [string]$SnapshotName = "LabConfigured",
        [Parameter(HelpMessage = "Run the command but suppress all status messages.")]
        [switch]$NoMessages
    )

    $Path = Convert-Path $path

    if (-Not $NoMessages) {

        Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Green -Object @"

        This is the Snapshot-Lab command. It will perform the following:

        * Snapshot the lab environment for easy and fast rebuilding

        Note! This should be done after the configurations have finished.

"@
    }
    $labname = Split-Path $Path -leaf
    if (-Not $NoMessages) {
        Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Cyan -Object 'Snapshot the lab environment'
    }
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

    if (-Not $NoMessages) {

        Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Green -Object @"

        Next Steps:

        To start the lab environment, run:
        Run-Lab

        To quickly rebuild the labs from the checkpoint, run:
        Refresh-Lab

"@
    }
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
        [string]$SnapshotName = "LabConfigured",
        [Parameter(HelpMessage = "Run the command but suppress all status messages.")]
        [switch]$NoMessages
    )

    $Path = Convert-Path $path

    if (-Not $NoMessages) {

        Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Green -Object @"

        This command will perform the following:

        * Refresh the lab from a previous Snapshot

        You will be prompted to restore the snapshot
        for each VM, although the prompt won't show
        you the virtual machine name.

        Note! This can only be done if you created a
        snapshot using Snapshot-Lab

"@
    }
    $labname = Split-Path $path -leaf

    if (-Not $NoMessages) {
        Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Cyan -Object 'Restore the lab environment from a snapshot'
    }

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

    if (-Not $NoMessages) {

        Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Green -Object @"

        Next Steps:

        To start the lab environment, run:
        Run-Lab

        To stop the lab environment, run:
        Shutdown-Lab

        To destroy this lab, run:
        Wipe-Lab

"@
    }
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
        [switch]$Force,
        [Parameter(HelpMessage = "Run the command but suppress all status messages.")]
        [switch]$NoMessages
    )

    $Path = Convert-Path $path

    if (-Not $NoMessages) {

        Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Green -Object @"

        This command will perform the following:

        * Wipe the lab and VM's from your system for this configuration

        If you intend to rebuild labs or run other configurations you
        do not need to remove the LabNat PolicyStore Local.

        Press Ctrl+C to abort this command.

"@
    }

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
    $LabData = Import-PowerShellDataFile -Path $path\*.psd1
    if (-Not $NoMessages) {
        Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Cyan -Object "Removing the lab environment for $labname"
    }

    # Stop the VM's
    if ($pscmdlet.ShouldProcess("VMs", "Stop-Lab")) {

        Try {
            #Forcibly stop all VMS since they are getting deleted anyway (Issue #229)
            Write-Verbose "Stopping all virtual machines in the configuration"
            Hyper-V\Stop-VM -vmname (PSAutolab\Get-LabSummary -Path $Path).Computername -TurnOff
            Write-Verbose "Calling Stop-Lab"
            Stop-Lab -ConfigurationData $path\*.psd1 -ErrorAction Stop -WarningAction SilentlyContinue
        }
        Catch {
            Write-Warning "Failed to stop lab. Are you running this in the correct configuration directory? $($_.exception.message)"
            #bail out because no other commands are likely to work
            return
        }
    }
    # Remove .mof iles
    Write-Verbose "Removing MOF files"
    Remove-Item -Path $path\*.mof

    if ($RemoveSwitch) {
        Write-Verbose "Removing the Hyper-V switch"
        $removeParams.Add("RemoveSwitch", $True)
        # Delete NAT
        $NatName = $Labdata.AllNodes.IPNatName
        if ($pscmdlet.ShouldProcess("LabNat", "Remove NetNat")) {
            Write-Verbose "Remoting NetNat"
            Remove-NetNat -Name $NatName
        }
    }
    # Delete vM's
    if ($pscmdlet.ShouldProcess("VMConfigurationData.psd1", "Remove lab configuration")) {
        Write-Verbose "Removing Lab Configuration"
        Lability\Remove-LabConfiguration @removeParams
    }

    #only delete the VHD files associated with the configuration as you might have more than one configuration
    #running
    Write-Verbose "Removing VHD files"
    $nodes = ($labdata.allnodes.nodename).where( { $_ -ne '*' })
    Get-ChildItem (Lability\Get-LabHostDefault).differencingVHDPath | Where-Object { $nodes -contains $_.basename } | Remove-Item
    #Remove-Item -Path "$((Get-LabHostDefault).DifferencingVHdPath)\*" -Force

    if (-Not $NoMessages) {

        Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Green -Object @"

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
        [switch]$AsJob,
        [Parameter(HelpMessage = "Override any configuration specified time zone and use the local time zone on this computer.")]
        [switch]$UseLocalTimeZone,
        [Parameter(HelpMessage = "Run the command but suppress all status messages.")]
        [switch]$NoMessages
    )
    Write-Verbose "Starting $($myinvocation.mycommand)"
    $Path = Convert-Path $path
    Write-Verbose "Using Path $path"

    $sb = {
        [cmdletbinding()]
        Param([string]$Path, [bool]$UseLocalTimeZone, [bool]$NoMessages, [bool]$WhatIf, [string]$VerboseAction)

        $VerbosePreference = $VerboseAction
        if ($VerboseAction -eq "Continue") {
            [void]$psboundparameters.Add("Verbose", $True)
        }

        [void]$psboundparameters.remove("VerboseAction")

        Write-Verbose "Starting the unattended scriptblock"
        $WhatIfPreference = $WhatIf
        [void]$psboundparameters.remove("WhatIf")
        Write-Verbose "Using these scriptblock parameters:"
        Write-Verbose  ($psboundparameters | Out-String)

        if (-Not $NoMessages) {

            $msg = @"

            This runs Setup-Lab, Run-Lab, and Validate-Lab commands.
            Starting the lab environment
"@

            Microsoft.PowerShell.Utility\Write-Host $msg -ForegroundColor Green
        }

        if ($pscmdlet.ShouldProcess("Setup-Lab", "Run Unattended")) {
            Write-Verbose "Setup-Lab"
            PSAutolab\Invoke-SetupLab @psboundparameters
        }
        #this parameter isn't used in the remaining commands
        [void]($psboundparameters.remove("UseLocalTimeZone"))

        if ($pscmdlet.ShouldProcess("Enable-Internet", "Run Unattended")) {
            Write-Verbose "Enable-Internet"
            PSAutolab\Enable-Internet @psboundparameters
        }
        if ($pscmdlet.ShouldProcess("Run-Lab", "Run Unattended")) {
            Write-Verbose "Run-Lab"
            PSAutolab\Invoke-RunLab @psboundparameters
        }
        if ($pscmdlet.ShouldProcess("Validate-Lab", "Run Unattended")) {
            Write-Verbose "Validate-Lab"
            PSAutolab\Invoke-ValidateLab @psboundparameters
        }

        if (-Not $NoMessages) {
            $msg = @"

        Unattended setup is complete.

        To stop the lab VM's:
        Shutdown-lab

        When the configurations have finished, you can checkpoint the VM's with:
        Snapshot-Lab

        To quickly rebuild the labs from the checkpoint, run:
        Refresh-Lab
"@
            Microsoft.PowerShell.Utility\Write-Host $msg -ForegroundColor Green
        }
    } #close scriptblock

    $icmParams = @{
        Computername = $env:computername
        ArgumentList = @($Path, $UseLocalTimeZone, $NoMessages, $WhatIfPreference, $VerbosePreference)
        Scriptblock  = $sb
    }

    if ($asjob) {
        $icmParams.Add("AsJob", $True)
    }
    Write-Verbose "Invoking command with these parameters"
    $icmParams | Out-String | Write-Verbose
    Invoke-Command @icmParams

    Write-Verbose "Ending $($myinvocation.mycommand)"
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

        $snaps = Hyper-V\Get-VMSnapshot -vmname  $VMs
        if ($snaps) {
            $snaps
            Microsoft.PowerShell.Utility\Write-Host "All VMs in the configuration should belong to the same snapshot if you want to use Refresh-Lab." -foreground green
        }
        else {
            Microsoft.PowerShell.Utility\Write-Host "No VM snapshots found for lab machines in $path." -ForegroundColor yellow
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

        #The prefix only changes the name of the VM not the guest computername
        $prefix = $data.NonNodeData.Lability.EnvironmentPrefix

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
                $vmNode = ("{0}{1}" -f $prefix,$node.Nodename)
                #Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] ... $($node.nodename)"
                Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] ... $vmNode"

                #verify VM is running
                $vm = Hyper-V\Get-VM -name $VMNode # $node.Nodename
                if ($vm.state -ne 'running') {
                 #   Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] ... Starting VM $($node.nodename)"
                    Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] ... Starting VM $vmnnode"
                    $vm | Start-VM
                    Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] ... Waiting 30 seconds to give VM time to boot"
                    Start-Sleep -seconds 30
                }

                $upParams.VMName = $VMNode #$node.nodename
                if ($node.role -contains "DC" -or $node.role -contains "DomainJoin") {
                    $upParams.Credential = $domcred
                }
                else {
                    $upParams.Credential = $wgcred
                }
                #calling a private function
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


#region Test-LabDSCResource

Function Test-LabDSCResource {
    [cmdletbinding()]
    Param(
        [Parameter(Position = 0, HelpMessage = "Specify the folder path of an Autolab configuration or change locations to the folder and run this command.")]
        [ValidateScript({Test-Path $_})]
        [string]$Path = "."
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"
        $cPath = Convert-Path -Path $Path
        $config = Join-Path -path $cpath -ChildPath VMConfigurationData.psd1
        $configName = Split-Path $cPath -Leaf
    } #begin

    Process {
        Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Testing resources in $cpath "
        Try {
            $data = Import-PowerShellDataFile -path $config -ErrorAction Stop
        }
        Catch {
            Throw $_
        }
        if ($data.NonNodeData.Lability.DSCResource) {
            $dsc = $data.NonNodeData.Lability.DSCResource
            Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Found $($dsc.count) required DSC resources"
            $dsc.GetEnumerator() | ForEach-Object {
                $installed = Get-Module $_.name -ListAvailable
                [pscustomobject]@{
                    ModuleName = $_.Name
                    RequiredVersion = $_.RequiredVersion
                    Installed = $installed.version -contains $_.requiredVersion
                    InstalledVersions = $Installed.version
                    Configuration = $configName
                }
            }
        }
        else {
            Write-Warning "No DSC Resources found in $config."
        }
    } #process

    End {
        Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"

    } #end

} #close Test-LabDSCResource

#endregion