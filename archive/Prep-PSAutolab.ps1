$msg ="This script isn't used at this time."
Write-Host $msg -ForegroundColor Red
return

<#
These are commands to be run before the module is imported.
I'm using this to make sure the right module dependcies are loaded
#>


# Write-Host "Starting prep script" -foreground cyan

#kick off a background job to find the current version of this module in the PSGallery
$job = Start-Job {Find-Module -name PSAutolab -Repository PSGallery }

#this code should be redundant and unnecessary since the manifest specifies required Modules
#but we'll keep it as a fail safe.

#declare the currently supported version of Lability
$LabilityVersion = "0.19.1"

#declare the currently supported version of Pester
#Pester v5 is incompatible with the current validation tests
$PesterVersion = "4.10.1"

<#
$currentLability = Get-Module -Name Lability -ListAvailable
if ($currentLability.version -notcontains $LabilityVersion) {
    Write-Host "Installing required module Lability ver. $labilityVersion" -ForegroundColor yellow
    Install-Module -Name Lability -Repository PSGallery -RequiredVersion $LabilityVersion -force -SkipPublisherCheck
}

$currentPester = Get-Module -Name Pester -ListAvailable
if ($currentPester.version -notcontains $PesterVersion) {
    Write-Host "Installing required module Pester ver. $PesterVersion." -ForegroundColor yellow
    Install-Module -Name Pester -Repository PSGallery -RequiredVersion $PesterVersion -force -SkipPublisherCheck
}
#>

#remove any existing versions of the module from the current PowerShell session
$p = Get-Module Pester | Where-object { $_.version -ne $PesterVersion}
$l = Get-Module Lability | Where-object { $_.version -ne $LabilityVersion}

if ($p) {
    $p | Remove-Module
    Write-Host "Removed Pester ver. $($p.version) from the current PowerShell session. You can re-import later when you are done with the PSAutolab module." -ForegroundColor yellow
    Import-Module -Name Pester -RequiredVersion $pesterVersion -global -Force
}

if ($l) {
    $l | Remove-Module
    Write-Host "Removed Lability ver. $($l.version) from the current PowerShell session. You can re-import later when you are done with the PSAutolab module." -ForegroundColor yellow
    Import-Module -Name Lability -RequiredVersion $LabilityVersion -global -Force
}

#endregion

[version]$thisVersion = (Test-ModuleManifest -path $PSScriptRoot\psautolab.psd1).version
[void]($job | Wait-Job)
[version]$onlineVersion = ($job | Receive-Job).version

#Write-Host "Comparing $thisversion to $onlineVersion" -fore magenta
if ($onlineVersion -gt $thisVersion) {
    Write-Host "A newer version of PSAutolab [v$OnlineVersion] is available in the PowerShell Gallery. Run `Update-Module PSAutolab` and then `Refresh-Host`." -foreground yellow
}

Remove-Job $job

# Write-Host "Ending prep script" -foreground cyan