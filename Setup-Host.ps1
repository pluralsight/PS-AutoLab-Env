<#
Disclaimer

This code is provided without copyright and “AS IS”.  It is free for you to use and modify under the MIT license.
Note: All scripts require WMF 5 or above, and to run from PowerShell using "Run as Administrator"

#>
#Requires -version 5.0
#Requires -runasadministrator

Write-Host -ForegroundColor Green -Object @"

    This is the Setup-Host script. This script will perform the following:
    * For PowerShell Remoting, Set the host 'TrustedHosts' value to *
    * Install the Lability module from PSGallery
    * Install Hyper-V
    * Create the C:\Lability folder (DO NOT DELETE)
    * Copy configurations and resources to C:\Lability
    * You will then need to reboot the host before continuing
"@

Pause


# For remoting commands to VM's - have the host set trustedhosts to *

Write-Output "Setting TrustedHosts to * so that remoting commands to VM's work properly"
$trust = Get-Item -Path WSMan:\localhost\Client\TrustedHosts 
If ($trust.value -eq "" -or $trust.value -eq "*"){
    Set-Item -Path WSMan:\localhost\Client\TrustedHosts -Value * -Force
} Else {
    Write-Warning "Your system is not a default installation -- "
    Write-Warning "Your trustedhosts has a value $($trust.Value)"
    break
}

# Lability install
Write-Output "Installong LAbility for the lab build"
Get-PackageSource -Name PSGallery | Set-PackageSource -Trusted -Force -ForceBootstrap
Install-Module -Name Lability -RequiredVersion 0.10.0

# SEtup host Env.
# Dev Note -- Should use If state with Test-LabHostConfiguration -- it returns true or false
$HostStatus=Test-LabHostConfiguration
If ($HostStatus -eq $False) {
    Write-Host "Initializing host"
    Start-LabHostConfiguration
}


############################################### IN PROGRESS ########################
###### COPY Configs to host machine 
## IMPORTANT __ REMOVE GITHUB FROM PATH!!!
Copy-item -Path C:\GitHub\PS-AutoLab-Env\Configurations\* -recurse -Destination C:\Lability\Configurations -force


Write-Host -ForegroundColor Yellow -Object @"

    The Host must be reboot before continuing.
    After the reboot, open Powershell, navigate to a configuration directory
    c:\Lability\Configuration\<yourconfigfolder>
    And run either:
    
    PS> .\Setup-Lab
"@

Pause
Restart-Computer


