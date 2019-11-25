#there are private, non-exported functions

Function _PesterCheck {
    [CmdletBinding(SupportsShouldProcess)]
    Param()

    $PesterMod = Get-Module -name Pester -ListAvailable | Sort-Object -Property Version -descending | Select-Object -First 1

    If ($pestermod.version -eq '3.4.0') {
        Write-Host "Installing a newer version of Pester" -ForegroundColor Cyan
        if ($pscmdlet.ShouldProcess("Pester", "Install-Module")) {
            Install-Module -name Pester -Force -SkipPublisherCheck
        }
    }
    elseif ($pestermod.version -lt '4.8.0') {
        Write-Host "Updating a newer version of Pester" -ForegroundColor Cyan
        if ($pscmdlet.ShouldProcess("Pester", "Update-Module")) {
            Update-Module -name Pester -Force
        }
    }
    else {
        Write-Host "Running Pester version $($pestermod.version)" -ForegroundColor green
    }
}

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

#region Invoke-WUUpdate
Function Invoke-WUUpdate {
    [cmdletbinding(DefaultParameterSetName = "computer")]

    Param(
        [Parameter(Position = 0, Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = "computer")]
        [ValidateNotNullOrEmpty()]
        [string[]]$Computername,
        [Parameter(Position = 0, ParameterSetName = "VM")]
        [string[]]$VMName,
        [ValidateNotNullorEmpty()]
        [pscredential]$Credential,
        [switch]$AsJob
    )

    Begin {
        Write-Verbose "[BEGIN  ] Starting: $($MyInvocation.Mycommand)"

        $all = @()

        #this is a nested function to deploy remotely
        Function WUUpdate {
            [cmdletbinding(SupportsShouldProcess, DefaultParameterSetName = "Computer")]
            Param(
                [Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = "Computer")]
                [ValidateNotNullOrEmpty()]
                [string[]]$Computername = $env:COMPUTERNAME

            )
            Begin {
                Write-Verbose "[BEGIN  ] Starting: $($MyInvocation.Mycommand)"
                $ns = "ROOT/Microsoft/Windows/WindowsUpdate"
            } #begin

            Process {

                #test if using the new Class
                Try {
                    [void](Get-CimClass -Namespace $ns -ClassName 'MSFT_WUOperations' -ErrorAction Stop)
                    $class = 'MSFT_WUOperations'
                    $scanArgs = @{SearchCriteria = "IsInstalled=0" }

                    #always scan even if the function is run with -whatif
                    Write-Host "[$(Get-Date)] Scanning for updates to install on $($env:computername)" -ForegroundColor Cyan
                    $scan = Invoke-CimMethod -Namespace $ns -ClassName $class -MethodName 'ScanForUpdates' -Arguments $scanArgs -WhatIf:$false -ErrorAction Stop

                    Write-Host "[$(Get-Date)] Found $($scan.updates.count) updates to install on $($env:computername)" -ForegroundColor Cyan
                    if ($scan.Updates.count -gt 0) {
                        if ($pscmdlet.ShouldProcess("$($scan.updates.count) updates", "Install Updates" )) {
                            [void](Invoke-CimMethod -Namespace $ns -ClassName MSFT_WUOperations -MethodName InstallUpdates -Arguments @{Updates = $scan.updates })
                        }
                    }
                } #try
                Catch {
                    #uncomment for debugging and troubleshooting
                    #Write-Host "Failed to find MSFT_WUOperations on $env:computername" -ForegroundColor yellow
                    $class = 'MSFT_WUOperationsSession'
                    $scanArgs = @{OnlineScan = $True; SearchCriteria = "IsInstalled=0" }
                    $ci = New-CimInstance -Namespace $ns -ClassName $class -Whatif:$False

                    Write-Host "[$(Get-Date)] Scanning for updates to install on $($env:computername)" -ForegroundColor Cyan
                    $scan = $ci | Invoke-CimMethod -MethodName 'ScanForUpdates' -Arguments $scanArgs -whatif:$False

                    Write-Host "[$(Get-Date)] Found $($scan.updates.count) updates to install on $($env:computername)" -ForegroundColor Cyan
                    if ($scan.Updates.count -gt 0) {
                        if ($pscmdlet.ShouldProcess("$($scan.updates.count) updates", "Apply Updates" )) {
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
                Write-Verbose "[END    ] Ending: $($MyInvocation.Mycommand)"
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
            $icmParams.JobName = "WUUpdate"
        }

    } #begin

    Process {

        if ($PSBoundParameters.ContainsKey("AsJob")) {
            [void]$PSBoundParameters.remove("AsJob")
        }

        #write-Verbose ($PSBoundParameters | Out-String)

        Try {
            Write-Verbose "[PROCESS] Creating PSSessions"
            $sess = New-PSSession @psboundParameters -ErrorAction stop
            Write-Verbose "[PROCESS] Copy the function to the remote computer"
            [void](Invoke-Command -ScriptBlock { New-Item -Path Function:WUUpdate -Value $using:fun -force } -Session $sess)

            $icmParams.Session = $sess
        }
        Catch {
            Write-Warning "Failed to create session to $Computer. $($_.exception.message)"
        }
        Write-Verbose "[PROCESS] Run the remote function"
        $r = Invoke-Command @icmParams
        if ($AsJob) {
            $r
        }
        else {
            $r | Select-Object -Property * -ExcludeProperty RunspaceID
            Write-Verbose "[PROCESS] Cleaning up sessions"
            $sess | Remove-PSSession
        }

    } #process
    End {
        Write-Verbose "[END    ] Ending: $($MyInvocation.Mycommand)"
    } #end

}

#endregion

#region Test-ISAdministrator

function Test-IsAdministrator {
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

#endregion