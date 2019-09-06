#there are private, non-exported functions

Function _LabilityCheck {
    [cmdletbinding(SupportsShouldProcess)]
    Param(
        [Parameter(Position = 0, Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$RequiredVersion
    )


    $LabilityMod = Get-Module -Name Lability -ListAvailable | Sort-Object Version -Descending
    if (-Not $LabilityMod) {
        Write-Host -ForegroundColor Cyan "Installing Lability module version $requiredVersion"
        Install-Module -Name Lability -RequiredVersion $requiredVersion -Force
    }
    elseif ($LabilityMod[0].Version.ToString() -eq $requiredVersion) {
        Write-Host "Version $requiredVersion of Lability is already installed" -ForegroundColor Cyan
    }
    elseif ($LabilityMod[0].Version.ToString() -ne $requiredVersion) {
        Write-Host -ForegroundColor Cyan "Updating Lability Module to version $RequiredVersion"
        #remove the currently loaded version
        Remove-Module Lability -ErrorAction SilentlyContinue
        try {
            Update-Module -Name Lability -force -erroraction stop -RequiredVersion $requiredVersion
        }
        Catch {
            Write-Warning "Failed to update to the current version of Lability. $($_.exception.message)"
            #bail out
            return
        }
    }
} #end function