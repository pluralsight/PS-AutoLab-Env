Function Invoke-WipeLab {
    [CmdletBinding(SupportsShouldProcess)]
    [alias("Wipe-Lab")]
    Param (
        [Parameter(HelpMessage = "The path to the configuration folder. Normally, you should run all commands from within the configuration folder.")]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { Test-Path $_ })]
        [String]$Path = ".",
        [Parameter(HelpMessage = "Remove the VM Switch. It is retained by default")]
        [Switch]$RemoveSwitch,
        [Parameter(HelpMessage = "Remove lab elements with no prompting.")]
        [Switch]$Force,
        [Parameter(HelpMessage = "Run the command but suppress all status messages.")]
        [Alias("Quiet")]
        [Switch]$NoMessages
    )

    $Path = Convert-Path $path

    if (-Not $NoMessages) {

        Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Green -Object @"

        This command will perform the following:

        * Wipe the lab and VM's from your system for this configuration

        If you intend to rebuild labs or run other configurations you
        do not need to remove the LabNat PolicyStore Local.

        Press Ctrl+C to abort this command.

"@
    }

    if (-Not $Force) {
        Pause
    }

    $removeParams = @{
        ConfigurationData = "$path\*.psd1"
    }

    if ($force) {
        $removeParams.Add("confirm", $False)
    }
    $LabName = Split-Path $path -Leaf
    $LabData = Import-PowerShellDataFile -Path $path\*.psd1
    if (-Not $NoMessages) {
        Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Cyan -Object "Removing the lab environment for $LabName"
    }

    # Stop the VM's
    if ($PSCmdlet.ShouldProcess("VMs", "Stop-Lab")) {

        Try {
            #Forcibly stop all VMS since they are getting deleted anyway (Issue #229)
            Write-Verbose "Stopping all virtual machines in the configuration"
            #use the VMName which might be using a prefix (Issue 231)
            Hyper-V\Stop-VM -VMName (PSAutolab\Get-LabSummary -Path $Path).VMName -TurnOff
            Write-Verbose "Calling Stop-Lab"
            Stop-Lab -ConfigurationData $path\*.psd1 -ErrorAction Stop -WarningAction SilentlyContinue
        }
        Catch {
            Write-Warning "Failed to stop lab. Are you running this in the correct configuration directory? $($_.exception.message)"
            #bail out because no other commands are likely to work
            return
        }
    }
    # Remove .mof files
    Write-Verbose "Removing MOF files"
    Remove-Item -Path $path\*.mof

    if ($RemoveSwitch) {
        Write-Verbose "Removing the Hyper-V switch"
        $removeParams.Add("RemoveSwitch", $True)
        # Delete NAT
        $NatName = $LabData.AllNodes.IPNatName
        if ($PSCmdlet.ShouldProcess("LabNat", "Remove NetNat")) {
            Write-Verbose "Remoting NetNat"
            Remove-NetNat -Name $NatName
        }
    }
    # Delete vM's
    if ($PSCmdlet.ShouldProcess("VMConfigurationData.psd1", "Remove lab configuration")) {
        Write-Verbose "Removing Lab Configuration"
        Lability\Remove-LabConfiguration @removeParams
    }

    #only delete the VHD files associated with the configuration as you might have more than one configuration
    #running
    Write-Verbose "Removing VHD files"
    $nodes = ($LabData.AllNodes.NodeName).where( { $_ -ne '*' })
    Get-ChildItem (Lability\Get-LabHostDefault).differencingVHDPath | Where-Object { $nodes -contains $_.basename } | Remove-Item
    #Remove-Item -Path "$((Get-LabHostDefault).DifferencingVHdPath)\*" -Force

    if (-Not $NoMessages) {

        Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Green -Object @"

        Next Steps:

        Run the following and follow the onscreen instructions:
        Setup-Lab

        When complete, run:
        Run-Lab

        Run the following to validate when configurations have converged:
        Validate-Lab

        To enable Internet access for the VM's, run:
        Enable-Internet

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
}
