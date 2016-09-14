## Trying a new direction

Write-Warning @"
    You must restart this computer
    when the initial setup is complete.
    From Powershell: Restart-Computer
"@
Start-Sleep 5


# For remoting commands to VM's - have the host set trustedhosts to *
Write-Output "Setting TrustedHosts to * so that remoting commands to VM's work properly"
$trust = Get-Item -Path WSMan:\localhost\Client\TrustedHosts 
If ($trust.value -eq "" -or $trust.value -eq "*"){
#Why not concatenate?
    Set-Item -Path WSMan:\localhost\Client\TrustedHosts -Value * -Force
} Else {
    Write-Output "Your trustedhosts has a value $($trust.Value)"

}

# Lability install
Get-PackageSource -Name PSGallery | Set-PackageSource -Trusted -Force -ForceBootstrap
Install-Module -Name Lability

# SEtup host Env.
Start-LabHostConfiguration # -verbose

