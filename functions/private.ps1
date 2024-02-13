[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
param()

#there are private, non-exported functions

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
Function _PesterCheck {
    [CmdletBinding(SupportsShouldProcess)]
    Param()

    #1/31/2024 Revised to check for the latest version of Pester
    $currentPester = (Get-Module Pester -ListAvailable)[0]
    #Get-Module -FullyQualifiedName @{ModuleName = "Pester"; ModuleVersion = "$pesterVersion"} -ListAvailable
    if ($currentPester.Version -eq '3.4.0') {
        Write-Warning 'Pester v3.4.0 is installed and has never been updated. Installing the latest version of Pester'
        Install-Module -Name Pester -Force -SkipPublisherCheck
    }
    elseif ($currentPester.Version -lt $PesterVersion) {
        Write-Warning 'Pester v5.0.0 or later is required. Updating to  the latest version of Pester'
        Update-Module -Name Pester
    }
    else {
        Write-Host 'Pester verified' -ForegroundColor green
    }

    #Import-Module -name Pester -RequiredVersion $PesterVersion -Force -Global
    Import-Module -Name Pester -Force -Global
}

Function _LabilityCheck {
    [CmdletBinding(SupportsShouldProcess)]
    Param(
        [Parameter(Position = 0, Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$RequiredVersion,
        [Switch]$SkipPublisherCheck
    )

    $LabilityMod = Get-Module -Name Lability -ListAvailable | Sort-Object Version -Descending

    $PSBoundParameters.Add('Name', 'Lability')
    $PSBoundParameters.Add('Force', $True)
    $PSBoundParameters.Add('ErrorAction', 'Stop')

    $PSBoundParameters | Out-String | Write-Verbose
    if (-Not $LabilityMod) {
        Write-Host -ForegroundColor Cyan "Installing Lability module version $requiredVersion"
        Install-Module @PSBoundParameters #-Name Lability -RequiredVersion $requiredVersion -Force
    }
    elseif ($LabilityMod[0].Version.ToString() -eq $requiredVersion) {
        Write-Host "Version $requiredVersion of Lability is already installed" -ForegroundColor Cyan
    }
    elseif ($LabilityMod[0].Version.ToString() -ne $requiredVersion) {
        Write-Host -ForegroundColor Cyan "Updating Lability Module to version $RequiredVersion"
        #remove the currently loaded version
        Remove-Module -Name Lability -ErrorAction SilentlyContinue
        try {
            if ($SkipPublisherCheck) {
                Write-Verbose 'Skipping publisher check and calling Install-Package'
                Install-Package @PSBoundParameters
            }
            else {
                Write-Verbose 'Calling Update-Module'
                [void]($PSBoundParameters.remove('SkipPublisherCheck'))
                Update-Module @PSBoundParameters
            }
        }
        Catch {
            Write-Warning "Failed to update to the current version of Lability. If the error message is about a certificate mismatch, re-run this command and use the -SkipPublisherCHeck parameter. `n$($_.exception.message)"
        }
    }
} #end function

Function Invoke-WUUpdate {
    [CmdletBinding(DefaultParameterSetName = 'computer')]

    Param(
        [Parameter(Position = 0, Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'computer')]
        [ValidateNotNullOrEmpty()]
        [string[]]$Computername,
        [Parameter(Position = 0, ParameterSetName = 'VM')]
        [string[]]$VMName,
        [ValidateNotNullOrEmpty()]
        [PSCredential]$Credential,
        [Switch]$AsJob
    )

    Begin {
        Write-Verbose "[BEGIN  ] Starting: $($MyInvocation.MyCommand)"

        $all = @()

        #this is a nested function to deploy remotely
        Function WUUpdate {
            [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Computer')]
            Param(
                [Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Computer')]
                [ValidateNotNullOrEmpty()]
                [string[]]$Computername = $env:COMPUTERNAME

            )
            Begin {
                Write-Verbose "[BEGIN  ] Starting: $($MyInvocation.MyCommand)"
                $ns = 'ROOT/Microsoft/Windows/WindowsUpdate'
            } #begin

            Process {

                #test if using the new Class
                Try {
                    [void](Get-CimClass -Namespace $ns -ClassName 'MSFT_WUOperations' -ErrorAction Stop)
                    $class = 'MSFT_WUOperations'
                    $scanArgs = @{SearchCriteria = 'IsInstalled=0' }

                    #always scan even if the function is run with -WhatIf
                    Write-Host "[$(Get-Date)] Scanning for updates to install on $($env:computername)" -ForegroundColor Cyan
                    $scan = Invoke-CimMethod -Namespace $ns -ClassName $class -MethodName 'ScanForUpdates' -Arguments $scanArgs -WhatIf:$false -ErrorAction Stop

                    Write-Host "[$(Get-Date)] Found $($scan.updates.count) updates to install on $($env:computername)" -ForegroundColor Cyan
                    if ($scan.Updates.count -gt 0) {
                        if ($PSCmdlet.ShouldProcess("$($scan.updates.count) updates", 'Install Updates' )) {
                            [void](Invoke-CimMethod -Namespace $ns -ClassName MSFT_WUOperations -MethodName InstallUpdates -Arguments @{Updates = $scan.updates })
                        }
                    }
                } #try
                Catch {
                    #uncomment for debugging and troubleshooting
                    #Write-Host "Failed to find MSFT_WUOperations on $env:computername" -ForegroundColor yellow
                    $class = 'MSFT_WUOperationsSession'
                    $scanArgs = @{OnlineScan = $True; SearchCriteria = 'IsInstalled=0' }
                    $ci = New-CimInstance -Namespace $ns -ClassName $class -WhatIf:$False

                    Write-Host "[$(Get-Date)] Scanning for updates to install on $($env:computername)" -ForegroundColor Cyan
                    $scan = $ci | Invoke-CimMethod -MethodName 'ScanForUpdates' -Arguments $scanArgs -WhatIf:$False

                    Write-Host "[$(Get-Date)] Found $($scan.updates.count) updates to install on $($env:computername)" -ForegroundColor Cyan
                    if ($scan.Updates.count -gt 0) {
                        if ($PSCmdlet.ShouldProcess("$($scan.updates.count) updates", 'Apply Updates' )) {
                            [void]($ci | Invoke-CimMethod -MethodName applyApplicableUpdates )
                        }
                    }
                } #catch

                if ($scan.updates.count -gt 0) {
                    Write-Host "[$(Get-Date)] Update process complete on $env:computername" -ForegroundColor Cyan
                }

                #check for reboot

                $r = Invoke-CimMethod -Namespace $ns -ClassName 'MSFT_WUSettings' -MethodName 'IsPendingReboot'
                if ($r.PendingReboot) {
                    Write-Warning "$($env:computername) requires a reboot"
                }

                if ($ci) {
                    Remove-Variable ci
                }

            } #process

            End {
                Write-Verbose "[END    ] Ending: $($MyInvocation.MyCommand)"
            } #end
        } #end nested function

        #get the contents of the nested function
        $fun = ${function:WUUpdate}

        $icmParams = @{
            HideComputername = $True
            Session          = $null
            Scriptblock      = { WUUpdate }
        }

        if ($AsJob) {
            $icmparams.AsJob = $True
            $icmParams.JobName = 'WUUpdate'
        }

    } #begin

    Process {

        if ($PSBoundParameters.ContainsKey('AsJob')) {
            [void]$PSBoundParameters.remove('AsJob')
        }

        #Write-Verbose ($PSBoundParameters | Out-String)

        Try {
            Write-Verbose '[PROCESS] Creating PSSessions'
            $sess = New-PSSession @PSBoundParameters -ErrorAction stop
            Write-Verbose '[PROCESS] Copy the function to the remote computer'
            [void](Invoke-Command -ScriptBlock { New-Item -Path Function:WUUpdate -Value $using:fun -Force } -Session $sess)

            $icmParams.Session = $sess
        }
        Catch {
            Write-Warning "Failed to create session to $Computer. $($_.exception.message)"
        }
        Write-Verbose '[PROCESS] Run the remote function'
        $r = Invoke-Command @icmParams
        if ($AsJob) {
            $r
        }
        else {
            $r | Select-Object -Property * -ExcludeProperty RunspaceID
            Write-Verbose '[PROCESS] Cleaning up sessions'
            $sess | Remove-PSSession
        }

    } #process
    End {
        Write-Verbose "[END    ] Ending: $($MyInvocation.MyCommand)"
    } #end

}

Function Test-IsAdministrator {
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

