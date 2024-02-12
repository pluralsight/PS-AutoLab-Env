Function Invoke-ValidateLab {
    [CmdletBinding()]
    [alias("Validate-Lab")]
    Param (
        [Parameter(HelpMessage = "The path to the configuration folder. Normally, you should run all commands from within the configuration folder.")]
        [ValidateNotNullOrEmpty()]
        [ValidateScript(
            {Test-Path $_ })]
        [String]$Path = ".",
        [Parameter(HelpMessage = "Run the command but suppress all status messages.")]
        [Switch]$NoMessages
    )

    Write-Verbose "Starting $($MyInvocation.MyCommand)"

    $modVersion = (Get-Module PSAutolab).Version
    #build a hashtable of computer names and VMNames
    $sum = Get-LabSummary -path $path
    $cnHash = @{}
    foreach ($item in $sum) {
        $cnHash.Add($item.Computername,$item.VMName)
    }
<#
#remove pester v5
    Get-Module Pester | Remove-Module -Force
    Write-Verbose "Importing Pester module version $PesterVersion"
    #use the module specific version of Pester
    Import-Module -Name Pester -RequiredVersion $PesterVersion -Force -Global
#>
    $Path = Convert-Path $path
    Write-Verbose "Using path $path"

    If (-Not $NoMessages) {

        $msg = @"
    [$(Get-Date)]
    Starting the VM testing process. The lab virtual machine(s) must be running.
    This process could take some time to complete depending on the complexity of
    the configuration. You can press Ctrl+C at any time to break out of the
    testing loop.

    If you feel the test is taking too long, break out of the testing loop
    and manually run the test:

        Run-Pester

    Make sure you are using version 5.x of the Pester module.

    You might also use Get-VM to verify all the VMs are running. Use Start-VM
    to start a stopped virtual machine.

    If only one of the VMs appears to be failing, you might try stopping
    and restarting it with the Hyper-V Manager or the cmdlets:

        Stop-VM <vmname>
        Start-VM <vmname>

    Errors are expected until all tests complete successfully.

"@
        Microsoft.PowerShell.Utility\Write-Host $msg  -ForegroundColor Cyan
    }

    #make sure all VMs are running
    Hyper-V\Get-VM -VMName ($cnHash.keys -as [array]) | Where-Object {$_.state -eq 'Off'} |
    ForEach-Object {
        Write-Warning "Starting virtual machine $($_.name)"
        $_ | Start-VM
        #give the VM a chance to change state
        Start-Sleep -Seconds 5
    }

    $Complete = $False

    #define a resolved path to the test file
    $TestPath = Join-Path -Path $path -ChildPath VMValidate.test.ps1
    $FirstTest = Get-Date

    #keep track of the number of passes
    $i=0
    Write-Verbose "Running initial validation test"
    do {
        $i++
        Write-Verbose "Validation pass $i"
        # 10 Feb 2024 Modified to reflect Pester v5 parameters
        $test = Invoke-Pester -Script $TestPath -Show None -PassThru -WarningAction SilentlyContinue

        if ($test.FailedCount -eq 0) {
            $Complete = $True
        }
        else {
            #test every 5 minutes
            if ($i -ge 2) {

                #get names of VMs with failing tests
                #10 Feb 2024 Modified to reflect Pester v5 output
                # $failedVMs = $test.TestResult.where({-Not $_.passed}).Describe | Get-Unique | ForEach-Object {$cnHash[$_]}
                $failedVMs = $test.Failed.Block.Name | Select-Object -Unique | Where-Object {$cnHash.ContainsKey($_)} | ForEach-Object {$cnHash[$_]}

                if ( ($i -eq 4 -OR $i -eq 7)-AND $failedVMs) {
                    #restart VMs that are still failing
                    Get-VM $failedVMs | Where-Object {$_.state -eq 'running'} |
                    ForEach-Object {
                        Write-Warning "Restarting virtual machine $($_.name)"
                        $_ | Restart-VM -force
                        #give the VM a chance to change state
                        Start-Sleep -seconds 10
                    }
                } #restart

                #restart any stopped VMs that are failing tests
                # Modified 10 Feb 2024 to check all VMs to verify they are running
                <#          if ($failedVMs) {
                    Get-VM $failedVMs | Where-Object {$_.state -eq 'Off'} |
                    ForEach-Object {
                        Write-Warning "Starting virtual machine $($_.name)"
                        $_ | Start-VM
                    }
                } #>

                Hyper-V\Get-VM -VMName ($cnHash.keys -as [array]) | Where-Object {$_.state -eq 'Off'} |
                ForEach-Object {
                    Write-Warning "Starting virtual machine $($_.name)"
                    $_ | Start-VM
                    #give the VM a chance to change state
                    Start-Sleep -Seconds 5
                }

                $prog = @{
                    Activity = "VM Validation [$($test.PassedCount)/$($test.TotalCount) tests passed in $i loop(s)] v$modVersion"
                    Status = "In a separate PowerShell window, use Get-VM to verify the status of $($FailedVMs -join ',')."
                    CurrentOperation = "Waiting until next test run"
                }
            }
            else {
                $prog = @{
                    Activity = "VM Validation [$($test.PassedCount)/$($test.TotalCount) tests passed in $i loop(s)] v$modVersion"
                    Status = "Waiting 5 minutes for configurations to converge"
                    CurrentOperation = "Waiting until next test run"
                }
            }
            300..1 | ForEach-Object {
                Write-Progress @prog -SecondsRemaining $_
                Start-Sleep -Seconds 1
            }
        }
        #bail out of testing after 65 minutes
        if ( ((Get-Date) - $FirstTest).TotalMinutes -ge 65) {
            $Aborted = $True
        }
    } until ($Complete -OR $Aborted)

    if ($complete) {
        $LastTest = Get-Date
        Write-Verbose "Validation completed in $($LastTest - $FirstTest)"

        #re-run test one more time to show everything that was tested.
        Write-Verbose "Re-run test to show results"
        Invoke-Pester -Script $path\VMValidate.Test.ps1 -Show All -WarningAction SilentlyContinue

        Write-Progress -Activity "VM Completion Test v.$modVersion" -Completed
        if (-Not $NoMessages) {
            Microsoft.PowerShell.Utility\Write-Host "[$(Get-Date)] VM setup and configuration complete. It is recommended that you snapshot the VMs with Snapshot-Lab" -ForegroundColor Green
        }
    }
    else {
        #aborted
        $msg = @"

Validation testing aborted. One or more virtual machines are not working properly.
It is recommended that you run this command:

Invoke-Pester .\vmvalidate.test.ps1 -show all -WarningAction SilentlyContinue

To see what tests are failing. Depending on the error, you may be able to manually
resolve it in the virtual machine, or feel you can ignore it. Otherwise, use Get-VM
to ensure virtual machines are running. You can also try rebooting your computer,
returning to this folder and re-running Unattend-Lab.

Or run Wipe-Lab -force and try the setup process again.

"@

    Write-Warning $msg

    }
    Write-Verbose "Ending $($MyInvocation.MyCommand)"
}
