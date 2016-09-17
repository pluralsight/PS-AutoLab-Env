## Trying a new direction


Write-Warning @"
    This script will create a folder structure off the C: drive
    with a folder named Lability. Do not delete this folder.

    It will then install Hyper-V on Win10 or Server 2012 R2 or Server 2016

    You must restart this computer
    when the initial setup is complete.
    From Powershell: Restart-Computer   
"@
Start-Sleep 5


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
Install-Module -Name Lability

# SEtup host Env.
# Dev Note -- Should use If state with Test-LabHostConfiguration -- it returns true or false
$HostStatus=Test-LabHostConfiguration
If ($HostStatus -eq $False) {
    Write-Output "Initializing host"
    Start-LabHostConfiguration
}


############################################### IN PROGRESS ########################
###### COPY Configs to host machine 
## IMPORTANT __ REMOVE GITHUB FROM PATH!!!
Copy-item -Path C:\GitHub\PS-Auto-Lab-Env\Configurations\* -recurse -Destination C:\Lability\Configurations -force

break

######  Download of ISO and DSC Resources -- this takes time
### Actually - don;t do this here --- let the first run of the config grab all resources
### So... Remove this and jsut have the kickoff script for the lab.
Invoke-LabResourceDownload -ConfigurationData .\TestLabGuide.psd1 -all

### ADD REBOOT MESSAGE
Write-Output "NEw Reboot message"

