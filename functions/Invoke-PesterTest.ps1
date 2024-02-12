Function Invoke-PesterTest {
    [CmdletBinding(SupportsShouldProcess)]
    [alias("Run-Pester")]
    Param (
        [Parameter(HelpMessage = "The path to the configuration folder. Normally, you should run all commands from within the configuration folder.")]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { Test-Path $_ })]
        [String]$Path = "."
    )

    $Path = Convert-Path $path

    $Test = Join-Path -Path $Path -ChildPath VMValidate.test.ps1

    Invoke-Pester -Path $Test -Show All -WarningAction SilentlyContinue
}