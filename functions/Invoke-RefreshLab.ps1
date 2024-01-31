Function Invoke-RefreshLab {
    [CmdletBinding(SupportsShouldProcess)]
    [alias("Refresh-Lab")]
    Param (
        [Parameter(HelpMessage = "The path to the configuration folder. Normally, you should run all commands from within the configuration folder.")]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { Test-Path $_ })]
        [String]$Path = ".",
        [Parameter(HelpMessage = "Specify a name for the virtual machine checkpoint")]
        [ValidateNotNullOrEmpty()]
        [String]$SnapshotName = "LabConfigured",
        [Parameter(HelpMessage = "Run the command but suppress all status messages.")]
        [Switch]$NoMessages
    )

    $Path = Convert-Path $path

    if (-Not $NoMessages) {

        Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Green -Object @"

        This command will perform the following:

        * Refresh the lab from a previous Snapshot

        You will be prompted to restore the snapshot
        for each VM, although the prompt won't show
        you the virtual machine name.

        Note! This can only be done if you created a
        snapshot using Snapshot-Lab

"@
    }
    $LabName = Split-Path $path -Leaf

    if (-Not $NoMessages) {
        Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Cyan -Object 'Restore the lab environment from a snapshot'
    }

    Try {
        if ($PSCmdlet.ShouldProcess($LabName, "Stop-Lab")) {
            Stop-Lab -ConfigurationData $path\*.psd1 -ErrorAction Stop
        }
    }
    Catch {
        Write-Warning "Failed to stop lab. Are you running this in the correct configuration directory? $($_.exception.message)"
        #bail out because no other commands are likely to work
        return
    }

    if ($PSCmdlet.ShouldProcess($SnapshotName, "Restore-Lab")) {
        Restore-Lab -ConfigurationData $path\*.psd1 -SnapshotName $SnapshotName -Force
    }

    if (-Not $NoMessages) {

        Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Green -Object @"

        Next Steps:

        To start the lab environment, run:
        Run-Lab

        To stop the lab environment, run:
        Shutdown-Lab

        To destroy this lab, run:
        Wipe-Lab

"@
    }
}
