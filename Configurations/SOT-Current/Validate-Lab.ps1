#requires -version 5.0
#requires -module Pester


Write-Host "[$(Get-Date)] Starting the VM testing process. This could take some time complete. Errors are expected until all tests complete successfully." -ForegroundColor Cyan

$Complete = $False

do {

$test= Invoke-Pester -Script $PSScriptRoot\ValidateVM.Test.ps1 -quiet -PassThru

if ($test.Failedcount -eq 0) {
    $Complete = $True
}
else {
    60..1 | foreach {
    Write-progress -Activity "VM Completion Test" -Status "Tests failed" -CurrentOperation "Waiting until next test run" -SecondsRemaining $_
    Start-sleep -Seconds 1
    }

    Write-Progress -Activity "VM Completion Test" -Completed
}
} until ($Complete)

#re-run test one more time to show everything that was tested.
Invoke-Pester -Script $PSScriptRoot\ValidateVM.Test.ps1

Write-Host "[$(Get-Date)] VM setup and configuration complete. It is recommended that you snapshot the VMs with Snapshot-Lab.ps1." -ForegroundColor Green

