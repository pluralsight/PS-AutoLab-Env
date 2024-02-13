Function Invoke-PesterTest {
    [CmdletBinding(SupportsShouldProcess)]
    [alias('Run-Pester')]
    Param (
        [Parameter(HelpMessage = 'The path to the configuration folder. Normally, you should run all commands from within the configuration folder.')]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { Test-Path $_ })]
        [String]$Path = '.'
    )

    $Path = Convert-Path $path

    #build a hashtable of computer names and VMNames
    $sum = Get-LabSummary -path $path
    $cnHash = @{}
    foreach ($item in $sum) {
        $cnHash.Add($item.Computername, $item.VMName)
    }

    Hyper-V\Get-VM -VMName ($cnHash.keys -as [array]) | Where-Object { $_.state -eq 'Off' } |
    ForEach-Object {
        Write-Host "Starting virtual machine $($_.name)" -ForegroundColor Yellow
        $_ | Start-VM
        #give the VM a chance to change state
        Start-Sleep -Seconds 5
    }

    $Test = Join-Path -Path $Path -ChildPath VMValidate.test.ps1

    Invoke-Pester -Path $Test -Show All -WarningAction SilentlyContinue
}