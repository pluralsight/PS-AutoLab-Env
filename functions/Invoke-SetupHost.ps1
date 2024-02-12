Function Invoke-SetupHost {
    [CmdletBinding(SupportsShouldProcess)]
    [alias("Setup-Host")]
    Param(
        [Parameter(HelpMessage = "Specify the parent path. The default is C:\Autolab. The command will create the folder.")]
        [String]$DestinationPath = "C:\Autolab"
    )

    Clear-Host

    # Setup Path Variables
    #use module defined variable
    $SourcePath = $ConfigurationPath

    Write-Verbose "Starting $($MyInvocation.MyCommand)"
    Write-Verbose "SourcePath = $SourcePath"

    Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Green -Object @"

    This is the Setup-Host script. This script will perform the following:

    * For PowerShell Remoting, configure the host 'TrustedHosts' value to *
    * Install the Lability module from PSGallery (if necessary)
    * Update the Pester module (if necessary)
    * Install Hyper-V (if necessary)
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

    # For remoting commands to VM's - have the host set trusted hosts
    Write-Verbose "Enable PSRemoting"
    Enable-PSRemoting -Force -SkipNetworkProfileCheck

    Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Cyan -Object "Setting TrustedHosts so that remoting commands to VMs work properly"
    $trust = Get-Item -Path WSMan:\localhost\Client\TrustedHosts
    if (($Trust.Value -eq "*") -or ($trust.Value -match "<local>")) {
        Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Green -Object "TrustedHosts is already set to *. No changes needed"
    }
    else {
        $add = '<local>' # Jeff's idea - 'DC,S*,Client*,192.168.3.' - need to automate this, not hard code
        Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Cyan -Object "Adding $add to TrustedHosts"
        Set-Item -Path WSMan:\localhost\Client\TrustedHosts -Value $add -Concatenate -Force
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
    if ($PSCmdlet.ShouldProcess("Lability $labilityVersion", "Install or Update Lability")) {
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
        if ($PSCmdlet.ShouldProcess($DirDef.ConfigurationPath, "Lability\Start-LabHostConfiguration")) {
            Lability\Start-LabHostConfiguration -ErrorAction SilentlyContinue
        }
    }

    ###### COPY Configs to host machine
    Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Cyan -Object "Copying configs to $($DirDef.ConfigurationPath)"
    if ($PSCmdlet.ShouldProcess($DirDef.ConfigurationPath, "Copy configurations")) {
        Copy-Item -Path $SourcePath\* -Recurse -Destination $DirDef.ConfigurationPath -Force
    }

    if ($PSCmdlet.ShouldProcess($env:computername, "Prompt for restart")) {

        Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Green -Object @"

        The localhost is about to reboot.
        After the reboot, open a Windows PowerShell prompt, navigate to a configuration directory
        $($DirDef.ConfigurationPath)\<YourConfigFolder>
        And run:

        PS $($DirDef.ConfigurationPath)\<YourConfigFolder>Setup-Lab -IgnorePendingReboot
        or
        PS $($DirDef.ConfigurationPath)\<YourConfigFolder>Unattend-Lab -IgnorePendingReboot

"@

        Write-Warning "System needs to reboot, especially if you just installed Hyper-V."
        $reboot = Read-Host "Do you wish to reboot now? (y/n)"
        If ($reboot -eq 'y') {
            Write-Output "Rebooting now"
            Restart-Computer
        }
    } #WhatIf
    Write-Verbose "Ending $($invocation.MyCommand)"
}
