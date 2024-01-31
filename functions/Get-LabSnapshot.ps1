Function Get-LabSnapshot {
    [CmdletBinding()]
    Param (
        [Parameter(HelpMessage = "The path to the configuration folder. Normally, you should run all commands from within the configuration folder.")]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { Test-Path $_ })]
        [String]$Path = "."
    )

    Write-Verbose "Starting $($MyInvocation.MyCommand)"

    $Path = Convert-Path $path
    Write-Verbose "Getting MOFs from $(Convert-Path $Path)"

    $VMs = (Get-ChildItem -Path $path -Filter *.mof -Exclude *meta* -Recurse).Basename
    if ($VMs) {

        Write-Verbose "Getting VMSnapshots for $($VMs -join ',')"

        $snaps = Hyper-V\Get-VMSnapshot -VMName  $VMs
        if ($snaps) {
            $snaps
            Microsoft.PowerShell.Utility\Write-Host "All VMs in the configuration should belong to the same snapshot if you want to use Refresh-Lab." -foreground green
        }
        else {
            Microsoft.PowerShell.Utility\Write-Host "No VM snapshots found for lab machines in $path." -ForegroundColor yellow
        }
    }
    else {
        Write-Warning "No configuration MOF files found in $Path."
    }

    Write-Verbose "Ending $($MyInvocation.MyCommand)"
}
