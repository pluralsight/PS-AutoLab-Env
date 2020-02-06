
#declare the currently supported version of Lability
$LabilityVersion = "0.19.0"
$ConfigurationPath = Join-Path -path $PSScriptRoot -ChildPath Configurations

#dot source functions
. $PSScriptRoot\functions\public.ps1
. $PSScriptRoot\functions\private.ps1

$currentLability = Get-Module -Name Lability -ListAvailable | Sort-Object -property version | Select-Object -last 1
if ($currentLability.version -lt $LabilityVersion) {
    Write-Host "You appear to be running an older version of the Lability module. Run Refresh-Host to update to version $LabilityVersion" -ForegroundColor yellow
}