Function Invoke-RunLab {
    [CmdletBinding(SupportsShouldProcess)]
    [alias("Run-Lab")]
    Param (
        [Parameter(HelpMessage = "The path to the configuration folder. Normally, you should run all commands from within the configuration folder.")]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { Test-Path $_ })]
        [String]$Path = ".",
        [Parameter(HelpMessage = "Run the command but suppress all status messages.")]
        [Switch]$NoMessages
    )

    $Path = Convert-Path $path

    if (-Not $NoMessages) {

        Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Green -Object @"

        This is the Run-Lab script. This script will perform the following:

        * Start the Lab environment

        Note! If this is the first time you have run this, it can take up to an hour
        for the DSC configurations to apply and converge.

"@
    }

    $LabName = Split-Path (Get-Location) -Leaf
    $DataPath = Join-Path $(Convert-Path $path) -ChildPath "*.psd1"

    if (-Not $NoMessages) {
        Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Cyan -Object "Starting the lab environment from $DataPath"
    }
    $data = Import-PowerShellDataFile -Path $DataPath
    # Creates the lab environment without making a Hyper-V Snapshot
    if ($PSCmdlet.ShouldProcess($LabName, "Start Lab")) {

        try {
            Start-Lab -ConfigurationData $data -ErrorAction Stop
        }
        Catch {
            Write-Warning "Failed to start lab. Are you running this in the correct configuration directory? $($_.exception.message)"
            #bail out because no other commands are likely to work
            return
        }

        if (-Not $NoMessages) {

            Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Green -Object @"

            Next Steps:

            To enable Internet access for the VM's, run:
            Enable-Internet

            Run the following to validate when configurations have converged:
            Validate-Lab

            To stop the lab VM's:
            Shutdown-lab

            When the configurations have finished, you can checkpoint the VM's with:
            Snapshot-Lab

            To quickly rebuild the labs from the checkpoint, run:
            Refresh-Lab

            To destroy the lab to build again:
            Wipe-Lab
"@
        }
    } #WhatIf
}
