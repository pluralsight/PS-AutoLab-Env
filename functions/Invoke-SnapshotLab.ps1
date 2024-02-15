Function Invoke-SnapshotLab {
    [CmdletBinding(SupportsShouldProcess)]
    [alias("Snapshot-Lab")]
    Param (
        [Parameter(HelpMessage = "The path to the configuration folder. Normally, you should run all commands from within the configuration folder.")]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { Test-Path $_ })]
        [String]$Path = ".",
        [Parameter(HelpMessage = "Specify a name for the virtual machine checkpoint")]
        [ValidateNotNullOrEmpty()]
        [String]$SnapshotName = "LabConfigured",
        [Parameter(HelpMessage = "Run the command but suppress all status messages.")]
        [Alias("Quiet")]
        [Switch]$NoMessages
    )

    $Path = Convert-Path $path

    if (-Not $NoMessages) {

        Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Green -Object @"

        This is the Snapshot-Lab command. It will perform the following:

        * Snapshot the lab environment for easy and fast rebuilding

        Note! This should be done after the configurations have finished.

"@
    }
    $LabName = Split-Path $Path -Leaf
    if (-Not $NoMessages) {
        Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Cyan -Object 'Snapshot the lab environment'
    }
    # Creates the lab environment without making a Hyper-V Snapshot
    if ($PSCmdlet.ShouldProcess($LabName, "Stop-Lab")) {

        Try {
            Stop-Lab -ConfigurationData $path\*.psd1 -ErrorAction Stop
        }
        Catch {
            Write-Warning "Failed to stop lab. Are you running this in the correct configuration directory? $($_.exception.message)"
            #bail out because no other commands are likely to work
            return
        }
    }
    if ($PSCmdlet.ShouldProcess($LabName, "Checkpoint-Lab")) {
        Checkpoint-Lab -ConfigurationData $path\*.psd1 -SnapshotName $SnapshotName
    }

    if (-Not $NoMessages) {

        Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Green -Object @"

        Next Steps:

        To start the lab environment, run:
        Run-Lab

        To quickly rebuild the labs from the checkpoint, run:
        Refresh-Lab

"@
    }
}
