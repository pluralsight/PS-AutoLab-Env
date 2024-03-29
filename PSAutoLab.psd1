# Module manifest for module 'PSAutoLab'
#

@{
    RootModule           = 'PSAutoLab.psm1'
    ModuleVersion        = '5.1.0'
    CompatiblePSEditions = @('Desktop')
    GUID                 = 'b68f9460-9e54-4207-b385-8654ce78ca95'
    Author               = 'Pluralsight'
    CompanyName          = 'Pluralsight LLC'
    Copyright            = '(c) 2016-2024 Pluralsight LLC. All rights reserved.'
    Description          = 'This module contains the control scripts to build, snapshot and remove lab environments using DSC configurations and the Lability PowerShell module.'
    PowerShellVersion    = '5.1'
    RequiredModules      = @('Lability','Pester')

    # Type files (.ps1xml) to be loaded when importing this module
    # TypesToProcess = @()

    FormatsToProcess     = @(
        'formats\psautolabvm.format.ps1xml',
        'formats\isotest.format.ps1xml',
        'formats\psautolabsetting.format.ps1xml',
        'formats\psautolabresource.format.ps1xml'
    )

    FunctionsToExport    = @(
        'Enable-Internet', 'Invoke-RefreshLab', 'Invoke-RunLab',
        'Invoke-SetupLab', 'Invoke-ShutdownLab', 'Invoke-SnapshotLab',
        'Invoke-UnAttendLab', 'Invoke-ValidateLab', 'Invoke-WipeLab',
        'Invoke-SetupHost', 'Invoke-RefreshHost', 'Get-PSAutoLabSetting',
        'Get-LabSnapshot', 'Update-Lab', 'Get-LabSummary', 'Test-LabDSCResource',
        'Open-PSAutoLabHelp', 'Test-ISOImage','Invoke-PesterTest'
    )

    VariablesToExport    = @()
    AliasesToExport      = @(
        'Refresh-Lab', 'Run-Lab', 'Setup-Lab',
        'Shutdown-Lab', 'Snapshot-Lab', 'Unattend-Lab',
        'Validate-Lab', 'Wipe-Lab', 'Setup-Host', 'Refresh-Host','Run-Pester'
        )
    PrivateData          = @{
        PSData = @{
            Tags         = @('lability', 'lab', 'dsc', 'training', 'pluralsight')
            LicenseUri   = 'https://github.com/pluralsight/PS-AutoLab-Env/blob/master/LICENSE'
            ProjectUri   = 'https://github.com/pluralsight/PS-AutoLab-Env'
            ReleaseNotes = 'https://github.com/pluralsight/PS-AutoLab-Env/blob/master/changelog.md'
            #Prerelease   = ""
        } # End of PSData hashtable

    } # End of PrivateData hashtable
}
