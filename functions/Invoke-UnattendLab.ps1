Function Invoke-UnattendLab {
    [CmdletBinding(SupportsShouldProcess)]
    [alias("Unattend-Lab")]
    Param (
        [Parameter(HelpMessage = "The path to the configuration folder. Normally, you should run all commands from within the configuration folder.")]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { Test-Path $_ })]
        [String]$Path = ".",
        [Switch]$AsJob,
        [Parameter(HelpMessage = "Override any configuration specified time zone and use the local time zone on this computer.")]
        [Switch]$UseLocalTimeZone,
        [Parameter(HelpMessage = "Run the command but suppress all status messages.")]
        [Alias("Quiet")]
        [Switch]$NoMessages
    )
    Write-Verbose "Starting $($MyInvocation.MyCommand)"
    $Path = Convert-Path $path
    Write-Verbose "Using Path $path"

    $sb = {
        [CmdletBinding()]
        Param([String]$Path, [bool]$UseLocalTimeZone, [bool]$NoMessages, [bool]$WhatIf, [String]$VerboseAction)

        #Not sure why this private function isn't being detected in the script block
        #so I'll make a copy here
        Function _SleepProgress {
            [cmdletBinding()]
            Param(
                [int]$Minutes = 1
            )

            $Status = 'The lab will continue to run if you cancel. You can validate the lab later by running Run-Pester'
            $Seconds = $Minutes * 60
            $i = 0
            $TS = New-TimeSpan -Minutes $minutes
            do {
                [string]$Activity = "Waiting $minutes minute for lab configuration to merge or press Ctrl+C to cancel waiting."
                $i++
                $TS = $TS.subtract('0:0:1')

                Write-Progress -Activity $Activity -Status $status -CurrentOperation $TS
                Start-Sleep -Seconds 1
            } until ($i -ge $Seconds)

            Write-Progress -Activity $Activity -Completed
        }

        #uncomment for testing and development
        #Import-Module C:\scripts\PSAutoLab\PSAutoLab.psd1 -force
        Import-Module PSAutoLab

        $VerbosePreference = $VerboseAction
        if ($VerboseAction -eq "Continue") {
            [void]$PSBoundParameters.Add("Verbose", $True)
        }

        [void]$PSBoundParameters.remove("VerboseAction")

        Write-Verbose "Starting the unattended scriptblock"
        $WhatIfPreference = $WhatIf
        [void]$PSBoundParameters.remove("WhatIf")
        Write-Verbose "Using these scriptblock parameters:"
        Write-Verbose  ($PSBoundParameters | Out-String)

        if (-Not $NoMessages) {

            $msg = @"

        This runs Setup-Lab, Run-Lab, and Validate-Lab commands.
        Starting the lab environment
"@

            Microsoft.PowerShell.Utility\Write-Host $msg -ForegroundColor Green
        }

        if ($PSCmdlet.ShouldProcess("Setup-Lab", "Run Unattended")) {
            Write-Verbose "Setup-Lab"
            PSAutolab\Invoke-SetupLab @PSBoundParameters
        }
        #this parameter isn't used in the remaining commands
        [void]($PSBoundParameters.remove("UseLocalTimeZone"))

        if ($PSCmdlet.ShouldProcess("Enable-Internet", "Run Unattended")) {
            Write-Verbose "Enable-Internet"
            PSAutolab\Enable-Internet @PSBoundParameters
        }
        if ($PSCmdlet.ShouldProcess("Run-Lab", "Run Unattended")) {
            Write-Verbose "Run-Lab"
            PSAutolab\Invoke-RunLab @PSBoundParameters
        }
        if ($PSCmdlet.ShouldProcess("Validate-Lab", "Run Unattended")) {
            #12 Feb 2024 Adding a sleep interval to allow the lab to finish merging
            $msg = @"

            Sleeping for 20 minutes to allow time for the lab configurations to merge.
            You can abort waiting with Ctrl+C. The lab will continue to run. Later,
            you can use Run-Pester to validate the lab.
"@
            Microsoft.PowerShell.Utility\Write-Host $msg -ForegroundColor Yellow
            #calling a private function to display a progress bar
            _SleepProgress -Minutes 20
            Write-Verbose "Invoking Validate-Lab"
            PSAutolab\Invoke-ValidateLab @PSBoundParameters
        }

        if (-Not $NoMessages) {
            $msg = @"

        Unattended setup is complete.

        To stop the lab VM's:
        Shutdown-lab

        When the configurations have finished, you can checkpoint the VM's with:
        Snapshot-Lab

        To quickly rebuild the labs from the checkpoint, run:
        Refresh-Lab
"@
            Microsoft.PowerShell.Utility\Write-Host $msg -ForegroundColor Green
        }
    } #close scriptblock

    $icmParams = @{
        Computername = $env:computername
        ArgumentList = @($Path, $UseLocalTimeZone, $NoMessages, $WhatIfPreference, $VerbosePreference)
        Scriptblock  = $sb
    }

    if ($AsJob) {
        $icmParams.Add("AsJob", $True)
    }
    Write-Verbose "Invoking command with these parameters"
    $icmParams | Out-String | Write-Verbose
    Invoke-Command @icmParams

    Write-Verbose "Ending $($MyInvocation.MyCommand)"
}
