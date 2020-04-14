#kick off a background job to find

$job = Start-Job {Find-Module -name PSAutolab -Repository PSGallery }

#declare the currently supported version of Lability
$LabilityVersion = "0.19.1"
$ConfigurationPath = Join-Path -path $PSScriptRoot -ChildPath Configurations

#dot source functions
. $PSScriptRoot\functions\public.ps1
. $PSScriptRoot\functions\private.ps1

$currentLability = Get-Module -Name Lability -ListAvailable | Sort-Object -property version | Select-Object -last 1
if ($currentLability.version -lt $LabilityVersion) {
    Write-Host "You appear to be running an older version of the Lability module. Run Refresh-Host to update to version $LabilityVersion" -ForegroundColor yellow
}

[version]$thisVersion = (Test-ModuleManifest -path $psscriptroot\psautolab.psd1).version
$job | Wait-Job
[version]$onlineVersion = ($job | Receive-Job).version

#Write-Host "Comparing $thisversion to $onlineVersion" -fore magenta
if ($onlineVersion -gt $thisVersion) {
    Write-Host "A newer version of PSAutolab [v$OnlineVersion] is available in the PowerShell Gallery. Run `Update-Module PSAutolab` and then `Refresh-Host`." -foreground yellow
}

Remove-Job $job