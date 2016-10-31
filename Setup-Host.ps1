<#
Disclaimer

This code is provided without copyright and “AS IS”.  It is free for you to use and modify under the MIT license.
Note: All scripts require WMF 5 or above, and to run from PowerShell using "Run as Administrator"

#>
#Requires -version 5.0
#Requires -runasadministrator

# Setup Path Variables
$SourcePath = $PSScriptRoot
$DestinationPath = "C:\Lability"

Clear-Host
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
Enable-PSremoting -force

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
Write-Host -ForegroundColor Cyan "Installing Lability for the lab build"
Get-PackageSource -Name PSGallery | Set-PackageSource -Trusted -Force -ForceBootstrap
Install-Module -Name Lability -RequiredVersion 0.10.0 -Force

# Installing modules to host(Author) machine need to run configs - this will be replaced
# In the next build - will auto-read from Cofniguration File
Install-Module -Name xActiveDirectory -RequiredVersion 2.13.0.0
Install-Module -Name xComputerManagement -RequiredVersion 1.8.0.0
Install-Module -Name xNetworking -RequiredVersion 2.12.0.0
Install-Module -Name xDhcpServer -RequiredVersion 1.5.0.0
Install-Module -Name xADCSDeployment -RequiredVersion 1.0.0.0

# SEtup host Env.
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
    
    PS $DestinationPath\Configuration\<yourconfigfolder>.\Setup-Lab

"@

Write-Host -ForegroundColor Yellow -Object "Note! - You may delete the folder $SourcePath when this setup finished and the system
            has been rebooted."

Pause
Restart-Computer


