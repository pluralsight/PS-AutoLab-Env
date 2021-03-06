
# Module manifest for module 'PSAutoLab'
#

@{
    # Script module or binary module file associated with this manifest.
    RootModule           = 'PSAutoLab.psm1'

    # Version number of this module.
    ModuleVersion        = '4.20.0'

    # Supported PSEditions
    CompatiblePSEditions = @('Desktop')

    # ID used to uniquely identify this module
    GUID                 = 'b68f9460-9e54-4207-b385-8654ce78ca95'

    # Author of this module
    Author               = 'Pluralsight'

    # Company or vendor of this module
    CompanyName          = 'Pluralsight LLC'

    # Copyright statement for this module
    Copyright            = '(c) 2016-2021 Pluralsight LLC. All rights reserved.'

    # Description of the functionality provided by this module
    Description          = 'This module contains the control scripts to build, snapshot and remove lab environements using DSC configurations and the Lability PowerShell module.'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion    = '5.1'

    # Modules that must be imported into the global environment prior to importing this module
    RequiredModules = @(@{ModuleName="Lability";RequiredVersion="0.20.0"},@{ModuleName="Pester";RequiredVersion="4.10.1"})

    # Type files (.ps1xml) to be loaded when importing this module
    # TypesToProcess = @()

    # Format files (.ps1xml) to be loaded when importing this module
    FormatsToProcess = @('formats\psautolabvm.format.ps1xml','formats\isotest.format.ps1xml','formats\psautolabsetting.format.ps1xml')

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport    = @(
        'Enable-Internet', 'Invoke-RefreshLab', 'Invoke-RunLab',
        'Invoke-SetupLab', 'Invoke-ShutdownLab', 'Invoke-SnapshotLab',
        'Invoke-UnattendLab', 'Invoke-ValidateLab', 'Invoke-WipeLab',
        'Invoke-SetupHost', 'Invoke-RefreshHost', 'Get-PSAutoLabSetting',
        'Get-LabSnapshot','Update-Lab','Get-LabSummary','Test-LabDSCResource',
        'Open-PSAutoLabHelp','Test-ISOImage'
    )

    # Variables to export from this module
    VariablesToExport    = @()

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport      = @('Refresh-Lab', 'Run-Lab', 'Setup-Lab', 'Shutdown-Lab', 'Snapshot-Lab', 'Unattend-Lab', 'Validate-Lab', 'Wipe-Lab', 'Setup-Host', 'Refresh-Host')

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData          = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags       = @('lability', 'lab', 'dsc', 'training','pluralsight')

            # A URL to the license for this module.
            LicenseUri = 'https://github.com/pluralsight/PS-AutoLab-Env/blob/master/LICENSE'

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/pluralsight/PS-AutoLab-Env'

            # A URL to an icon representing this module.
            # IconUri = ''

            # ReleaseNotes of this module
            ReleaseNotes = 'https://github.com/pluralsight/PS-AutoLab-Env/blob/master/changelog.md'

        } # End of PSData hashtable

    } # End of PrivateData hashtable

    # HelpInfo URI of this module
    # HelpInfoURI = ''

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''

}

