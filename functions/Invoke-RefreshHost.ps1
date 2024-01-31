Function Invoke-RefreshHost {
    [CmdletBinding(SupportsShouldProcess)]
    [alias("Refresh-Host")]
    Param(
        [Parameter(Position = 0, HelpMessage = "The path to your Autolab configuration path, ie C:\Autolab\ConfigurationPath")]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { Test-Path $_ })]
        [String]$Destination = (Get-LabHostDefault).ConfigurationPath,
        [Switch]$SkipPublisherCheck
    )

    #test if a new version of lability is required
    if ($PSCmdlet.ShouldProcess("version $LabilityVersion", "Check for Lability Requirements")) {
        _LabilityCheck -RequiredVersion $LabilityVersion -SkipPublisherCheck:$SkipPublisherCheck
    }

    #test and update Pester as needed
    if ($PSCmdlet.ShouldProcess("version $PesterVersion", "Check for required Pester version")) {
        _PesterCheck
    }

    # Setup Path Variables
    $SourcePath = $ConfigurationPath

    Microsoft.PowerShell.Utility\Write-Host "Updating configuration files from $sourcePath" -ForegroundColor Cyan
    if ($PSCmdlet.ShouldProcess($Destination, "Copy configurations")) {
        if (Test-Path $Destination) {
            Copy-Item -Path $SourcePath\* -Recurse -Destination $Destination -Force
        }
        else {
            Write-Warning "Can't find target path $Destination."
        }
    }

    Microsoft.PowerShell.Utility\Write-Host "This process will not remove any configurations that have been deleted from the module." -ForegroundColor yellow
}
