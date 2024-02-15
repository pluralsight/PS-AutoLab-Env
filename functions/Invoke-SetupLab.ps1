Function Invoke-SetupLab {
    [CmdletBinding(SupportsShouldProcess)]
    [Alias("Setup-Lab")]
    Param (
        [Parameter(HelpMessage = "The path to the configuration folder. Normally, you should run all commands from within the configuration folder.")]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { Test-Path $_ })]
        [String]$Path = ".",
        [Switch]$IgnorePendingReboot,
        [Parameter(HelpMessage = "Override any configuration specified time zone and use the local time zone on this computer.")]
        [Switch]$UseLocalTimeZone,
        [Parameter(HelpMessage = "Run the command but suppress all status messages.")]
        [Alias("Quiet")]
        [Switch]$NoMessages
    )

    Write-Verbose "Starting $($MyInvocation.MyCommand)"

    $Path = Convert-Path $path
    $LabName = Split-Path $Path -Leaf
    $LabData = Import-PowerShellDataFile -Path $(Join-Path $Path -ChildPath *.psd1)
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
        Note! - If there is an error creating the .mof files, the setup will fail.

        * Run the lab setup
        Note! If this is the first time you have run this, it can take several
        hours to download the ISO files and resources depending on the configuration.
        You may also see new drives being added and removed as the ISO is mounted
        and converted. You can ignore these activities.

        This step should only happen the first time you run this command.

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
        # $LocalTz = [System.TimeZone]::CurrentTimeZone.StandardName
        $LocalTz = (Get-TimeZone).ID
        Write-Verbose "Using local time zone $LocalTz"
        if ($LabData.AllNodes.count -gt 1) {
            if (-Not $NoMessages) {
                Microsoft.PowerShell.Utility\Write-Host "Overriding configured time zones to use $LocalTz" -ForegroundColor yellow
            }
            $nodes = $LabData.AllNodes.where( { $_.NodeName -ne "*" })
            foreach ($node in $nodes) {
                # $tz = $node.Lability_timezone
                $node.Lability_timeZone = $LocalTz
            }
        }
        else {
            if (-Not $NoMessages) {
                Microsoft.PowerShell.Utility\Write-Host "Updating AllNodes to $LocalTz" -ForegroundColor Yellow
            }
            $LabData.AllNodes.Lability_TimeZone = $LocalTz
        }
    } #use local timezone

    $LabData.AllNodes | Out-String | Write-Verbose

    Write-Verbose "Install DSC Resource modules specified in the .PSD1"

    If (-Not $NoMessages) {
        Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Cyan -Object 'Installing required DSCResource modules from PSGallery'
        Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Yellow -Object 'You may need to say "yes" to a Nuget Provider prompt.'
    }
    #force updating/installing nuget to bypass the prompt
    [void](Install-PackageProvider -Name nuget -Force -ForceBootstrap)

    Foreach ($DSCResource in $DSCResources) {
        #test if current version is installed otherwise update or install it
        $DSCMod = Get-Module -FullyQualifiedName @{ModuleName = $DSCResource.name; ModuleVersion = $DSCResource.RequiredVersion } -ListAvailable

        if ((-not $DSCMod ) -or ($DSCMod.version -ne $DSCResource.RequiredVersion)) {
            if (-Not $NoMessages) {
                Microsoft.PowerShell.Utility\Write-Host "install $($DSCResource.name) version $($DSCResource.RequiredVersion)" -ForegroundColor yellow
            }
            if ($PSCmdlet.ShouldProcess($DSCResource.name, "Install-Module")) {
                Install-Module -Name $DSCResource.Name -RequiredVersion $DSCResource.RequiredVersion
            }
        }
        elseif ($DSCMod.version -ne ($DSCResource.RequiredVersion -as [version])) {
            if (-not $NoMessages) {
                Microsoft.PowerShell.Utility\Write-Host "Update $($DSCMod.name) to version $($DSCResource.RequiredVersion)" -ForegroundColor cyan
            }
            if ($PSCmdlet.ShouldProcess($DSCResource.name, "Update-Module")) {
                Update-Module -Name $DSCResource.Name -RequiredVersion $DSCResource.RequiredVersion
            }
        }
        else {
            If (-Not $NoMessages) {
                Microsoft.PowerShell.Utility\Write-Host "$($DSCMod.name) [v$($DSCMod.version)] requires no updates." -ForegroundColor green
            }
        }
    }

    Write-Verbose "Run the config to generate the .mof files"
    If (-Not $NoMessages) {
        Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Cyan -Object 'Build the .Mof files from the configs'
    }
    $VMConfig = Join-Path -Path $path -ChildPath 'VMConfiguration.ps1'
    if ($PSCmdlet.ShouldProcess($VMConfig)) {
        . $VMConfig
    }
    # Build the lab without a snapshot

    if (-Not $NoMessages) {
        Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Cyan -Object "Building the lab environment for $LabName"
    }

    # Creates the lab environment without making a Hyper-V Snapshot
    $Password = ConvertTo-SecureString -String "$($LabData.AllNodes.LabPassword)" -AsPlainText -Force
    $startParams = @{
        ConfigurationData   = $LabData
        #Import-PowerShellDataFile -path (Join-Path -path $path -childpath "VMConfigurationData.psd1")
        Path                = $Path
        NoSnapshot          = $True
        Password            = $Password
        IgnorePendingReboot = $True
        WarningAction       = "SilentlyContinue"
        ErrorAction         = "stop"
    }

    Write-Verbose "Using these start parameters"
    Write-Verbose ($startParams | Out-String)
    if ($PSCmdlet.ShouldProcess($LabName, "Start-LabConfiguration")) {
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

    Write-Verbose "Ending $($MyInvocation.MyCommand)"
}
