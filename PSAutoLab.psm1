#kick off a background job to find the current version of this module in the PSGallery

$job = Start-Job {Find-Module -name PSAutolab -Repository PSGallery }

#dot source functions
. $PSScriptRoot\functions\public.ps1
. $PSScriptRoot\functions\private.ps1

#region module check
#this code should be redundant and unnecessary since the manifest specifies required Modules
#but we'll keep it as a fail safe.

#declare the currently supported version of Lability
$LabilityVersion = "0.19.1"
$ConfigurationPath = Join-Path -path $PSScriptRoot -ChildPath Configurations

#declare the currently supported version of Pester
#Pester v5 is incompatible with the current validation tests
$PesterVersion = "4.10.1"

$currentLability = Get-Module -Name Lability -ListAvailable | Sort-Object -property version | Select-Object -last 1
if ($currentLability.version -lt $LabilityVersion) {
    Write-Host "You appear to be running an older version of the Lability module. Run Refresh-Host to update to version $LabilityVersion" -ForegroundColor yellow
}

$currentPester = Get-Module -fullyqualifiedname @{ModuleName = "Pester"; ModuleVersion = "$PesterVersion"} -ListAvailable
if (-not $CurrentPester) {
    Write-Host "You do not have the required version of the Pester module. If you have already run
    Setup-Host, please run Refresh-Host to install Pester version $PesterVersion. Newer versions may
    not be supported in this module." -ForegroundColor yellow
}
else {
    #remove any existing  versions of the module.
    Get-Module Pester | Remove-Module
    #write-host "Importing Pester v$PesterVersion" -ForegroundColor green
    Import-Module -Name Pester -RequiredVersion $pesterVersion -global -Force
}
#endregion

[version]$thisVersion = (Test-ModuleManifest -path $psscriptroot\psautolab.psd1).version
$job | Wait-Job
[version]$onlineVersion = ($job | Receive-Job).version

#Write-Host "Comparing $thisversion to $onlineVersion" -fore magenta
if ($onlineVersion -gt $thisVersion) {
    Write-Host "A newer version of PSAutolab [v$OnlineVersion] is available in the PowerShell Gallery. Run `Update-Module PSAutolab` and then `Refresh-Host`." -foreground yellow
}

Remove-Job $job