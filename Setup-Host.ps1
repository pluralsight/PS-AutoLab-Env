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
Set-Item -Path WSMan:\localhost\Client\TrustedHosts -Value * -Force

# Lability install
Write-Output "Installong LAbility for the lab build"
Get-PackageSource -Name PSGallery | Set-PackageSource -Trusted -Force -ForceBootstrap
Install-Module -Name Lability

# SEtup host Env.
Write-Output "Initializing host"
Start-LabHostConfiguration # -verbose

