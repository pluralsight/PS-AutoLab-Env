#Requires -version 5.0
#Requires -runasadministrator

<#
Disclaimer

This code is provided without copyright and “AS IS”.  It is free for you to use and modify under the MIT license.
Note: All scripts require WMF 5 or above, and to run from PowerShell using "Run as Administrator"

#>


# Setup Path Variables
$SourcePath = $PSScriptRoot
$DestinationPath = "C:\AutoLab" #Default
Clear-Host
Write-Host -ForegroundColor Cyan -Object "The default installation path is $DestinationPath"
$result = Read-Host "Would you like to change the default path? (y/n)"
If ($Result -eq 'y'){
    $DestinationPath = Read-Host "Enter complete path including drive letter"
    Write-Output "New path is $DestinationPath"
}


Write-Host -ForegroundColor Green -Object @"

    This is the Setup-Host script. This script will perform the following:
    * For PowerShell Remoting, Set the host 'TrustedHosts' value to *
    * Install the Lability module from PSGallery
    * Install Hyper-V
    * Create the $DestinationPath folder (DO NOT DELETE)
    * Copy configurations and resources to $DestinationPath
    * You will then need to reboot the host before continuing

    Note! - You may delete the folder $SourcePath when this setup finished and the system
            has been rebooted.

"@

Pause


# For remoting commands to VM's - have the host set trustedhosts
Enable-PSremoting -force -SkipNetworkProfileCheck

Write-Host -ForegroundColor Cyan -Object "Setting TrustedHosts so that remoting commands to VMs work properly"
$trust = Get-Item -Path WSMan:\localhost\Client\TrustedHosts
if ($Trust.Value -eq "*") {
    Write-Host -ForegroundColor Green -Object "TrustHosts is already set to *. No changes needed"
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

$requiredVersion ='0.11.0'
$LabilityMod = Get-Module -Name Lability -ListAvailable | Sort-Object -Property Version -Descending
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
Write-Host -ForegroundColor Cyan "Installing PSAutoLab Module for the lab build"
Copy-Item -Path "$SourcePath\Tools\PSAutoLab" -Destination 'C:\Program Files\WindowsPowerShell\Modules' -Recurse -Force

# Set Lability folder structure
$DirDef = @{
    ConfigurationPath = "$DestinationPath\Configurations"
    DifferencingVhdPath = "$DestinationPath\VMVirtualHardDisks"
    HotfixPath = "$DestinationPath\Hotfixes"
    IsoPath = "$DestinationPath\ISOs"
    ModuleCachePath = "C:\ProgramData\Lability\Modules"
    ParentVhdPath = "$DestinationPath\MasterVirtualHardDisks"
    ResourcePath = "$DestinationPath\Resources"

}

Set-LabHostDefault @DirDef


# Setup host Environment.
# Dev Note -- Should use If state with Test-LabHostConfiguration -- it returns true or false

$HostStatus=Test-LabHostConfiguration
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
    
    PS $DestinationPath\Configuration\<yourconfigfolder>.\Setup-Lab.ps1
    or
    PS $DestinationPath\Configuration\<yourconfigfolder>.\Unattend-Lab.ps1

"@

Write-Host -ForegroundColor Yellow -Object "Note! - You may delete the folder $SourcePath when this setup finished and the system has been rebooted."

Write-Warning "System needs to reboot"
$reboot = Read-Host "Do you wish to reboot now? (y/n)"
If ($reboot -eq 'y') {
    Write-Output "Rebooting now"
    Restart-Computer
}



