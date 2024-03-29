# Change Log for PSAutoLab

This is an archive older change log entries. For the current change log, see the [changelog.md](changelog.md) file.

## [4.19.0] - 2020-12-02

### Added

- Added `Test-ISO` function to validate ISO images along with a custom formatting file, `isotest.format.ps1xml`.
- Added a custom format file for `Get-PSAutoLabsetting`.

### Changed
- Update documentation with a requirement to manually update Pester `install-module pester -RequiredVersion 4.10.1 -Force -SkipPublisherCheck` if the *only* installed version of Pester is `3.4.0`.
- Fixed bug in `Get-LabSummary` if `Lability_Media` setting is missing. (Issue #245)
- Modified `Get-PSAutolabSetting` to include information on the network connection profile for the `LabNet` network.
- Help updates.

## [4.18.0] - 2020-10-06

### Added
- Added a custom format file, `psautolabvm-format.ps1xml`, to better format results from the `Get-LabSummary` command.

### Changed

- Minor documentation clean up.

## [4.17.0] - 2020-08-05

### Added

- Added a PDF user manual and a command, `Open-PSAutoLabHelp`, to launch it.
- Added TLS protocol update to the module file. (Issue #235)
-
### Changed

- Updated markdown documentation.
- Modified `Get-LabSummary` to better reflect the computer and virtual machine names, especially when using the environment prefix. `Wipe-Lab` has also been modified to use this new information. Thank you @andreasjordan. (Issue #231)
- Archived `Authoring-FAQ.md1`. Incorporated most of the content into `Usage-FAQ.md`.

## [4.16.0] - 2020-08-04

### Changed

- Modified `Get-LabSummary` to include the environment prefix as part of the computer name if specified. (Issue #231)
- Minor help and documentation updates. Added online links to command help.

## [4.15.0] - 2020-06-30

### Added

- Added troubleshooting content to `README` about potential TLS issues updating the nuget provider or module. (Issue #224)

### Changed

- Modified `Wipe-Lab` to simply turn off virtual machines (Issue #229)
- Modified all commands to use fully qualified command names
- Modified `Invoke-SetupHost` with additional verbose messaging

### Removed

- Deleted duplicate function `Invoke-WUUpdate` from `public.ps1`. This was a leftover before it was moved to a private function. (Issue #230)

## [4.14.0] - 2020-06-29

### Added

- Restored variable definition for `$LabilityVersion` in the psm1 file.

### Changed

- Modified Lability commands in `Invoke-SetupHost` to use a fully qualified command name.
- Updated -WhatIf messages in `Invoke-Setup-Host`

## [4.13.0] - 2020-06-16

### Added

- Added more Verbose messaging to `Invoke-SetupLab`.
-
### Changed

- Modified `Invoke-ValidateLab` to import and use the approved version of the Pester module.
- Updated validation test for `PowerShellLab` configuration to fix error validating domain admin membership. (Issue # 226)
- Modified `Invoke-ValidateLab` to remove all versions of Pester and then load the version compatible with this module.
- Updated `Invoke-SetupLab` to use `(Get-TimeZone).id` when using local time zone. (Issue #227)


## [4.12.0] - 2020-06-11

### Added

- Added a new function, `Test-LabDSCResource` which can be used to see if the required DSC resources are already installed and to display what versions are installed.

### Changed

- Updated `README` with clearer setup instructions
- Updated `Detailed-Setup-Instructions.md`
- Modified manifest to install and use required module versions.

### Removed

- Commented out NanoServer installations in configurations that used them since the original use case has been deprecated by Microsoft.

## [4.11.0] - 2020-06-08

### Added

- Added code to test for and install Pester v4.10.1. Pester v5 breaks the current validation tests. (Issue #223)
- Added PSDesiredState module version information to `Get-PSAutoLabSetting`

### Changed

- Updated documentation to reflect Pester requirements.
- Updated `Invoke-ValidateLab` to explicitly import the supported version of Pester.
- Updated module manifest to specify required module versions for Lability and Pester
- Modified `Get-PSAutoLabSetting` to return all installed versions of Pester
- Help updates

### Removed

- Removed archived configurations from the `Configurations` path. This will not remove them for people who upgrade. The files are still part of this module for reference purposes.

## [4.10.0] - 2020-05-04

### Changed

- Updated `README.md` with additional requirements and information.
- Updated `Detailed-Setup-Instructions.md` with information about using an environment prefix.
- Updated test files to show `New-PSSession` error message in output.
- Updated commands and files to support using `EnvironmentPrefix` values. (Issue #217)
- Updated lab configurations to use newer TLS settings via a registry change (Issue #216)


## [4.9.0] - 2020-04-23

### Added

- Added lab configurations `SingleServer2012R2` and `SingleServer2012R2-GUI` (Issue #215)

### Changed

- Updated `Authoring-FAQ.md` and restored it to this project.
- Modified validation test for `PowerShellLab` lab to that was testing for specific Windows 10 version number. (Issue #214)
- Updated the `PowerShellLab` lab validation test  to better display errors creating remoting sessions.
- Modified the `Windows10` lab validation test to verify the correct operating system.
- Updated `Detailed-Setup-Instructions.md`.
- Updated `README.md`
- Minor revisions to `Updating.md`.
- Minor revisions to `Updating.md`.

## [v4.8.0] - 2020-04-14

### Added

- Added "Detailed-Setup-Instructions.md`.
- Added code to module file to check for a new version in the PowerShell Gallery.
- Added `SingleServer-GUI-2019` configuration.
- Added `Get-LabSummary` function.
- Added a `-NoMessages` parameter to most commands in the module to offer an option to suppress the status and information messages displayed with `Write-Host`.

### Changed

- Modified `Get-PSAutoLabSetting` to include additional information.
- Updated `Instructions.md` to provide more detail about each lab.
- Updated `README.md` with information on customizing a configuration.
- Updated validation test for `SingleServer-GUI-2016` to test RDP.
- Increased the memory for `SingleServer` to 2GB.
- Updated validation tests for all configurations for better performance and to suppress error messages while configurations are converging.
- Updated DSC configurations for `SingleServer-GUI-2019`,`SingleServer`,`SingleServer-GUI-2016` to uninstall PowerShell-V2.
- Modified `MultiRole` configuration to use Windows Server 2019.
- Restored deleted Nano-related NonNode data in configurations that include a Nano server.
- Help updates

### Fixed
- Fixed bug in `Wipe-Lab` that failed to properly import lab data.
- Suppressing `Write-Warning` messages in `Wipe-Host` when VM is already shut down.

### Removed

- Removed Active Directory JSON files from `SingleServer` configurations since they are not used.
- Removed Active Directory, DHCP Server and ADCS DSC resources from `SingleServer*` configuration files since they are not used.

## [v4.7.0] - 2020-04-04

### Changed

- Corrected minor typos in `VMValidate.test.ps1` in the `PowerShellLab` configuration.
- Updated the Lability module version to `0.19.1`.
- Updated `xPSDesiredStateConfiguration` to version `9.1.0`.
- Expanded command aliases in `VMValidate.Test.ps1` in the `Microsoft-PowerShell-Implementing-JEA` configuration.
- Updated `README.md` with improved setup instructions and background information.


## [v4.6.0] - 2020-04-01

### Added

- Configuration `SingleServer-GUI-2016` (Issue 208)
- Configuration `MultiRole-Server-2016` (Issue 209)

### Changed

- Updated manifest tags
- Changed `Write-Host` commands to use a fully qualified name `Microsoft.PowerShell.Utility\Write-Host`
- Modified `Invoke-UnattendLab` to pass `-Verbose` to the scriptblock for better troubleshooting
- Modified `Invoke-SetupLab` and `Invoke-ValidateLab` to provide more verbose detail
- Updated `README.md`

### Fixed

- Fixed minor spelling error in `VMConfiguration.ps1` scripts

## [v4.5.0] - 2020-02-06

## v4.4.0

- Modified Pester tests with a little more error handling.
- Moved default user location to the Employees OU instead of the domain root for the PowerShellLab configuration
- Added Test-isAdministrator private function
- Updated `Get-PSAutoLabSetting` to reflect memory in GB, report on percent free memory, and Hyper-V version
- Updated `Get-PSAutoLabSetting` to show all installed versions of Lability and PSAutoLab modules
- Updated `Get-PSAutoLabSetting` to show if running with elevated privileges
- Updated xPSDesiredStateConfiguration resource to 8.10.0.0
- Updated xDNSServer to 1.15.0.0
- Added `Invoke-WUUpdate` as a private function with a public wrapper function of `Update-Lab` to install Windows Updates on the virtual machines.
- Help and documentation updates

## v4.3.0

- Added code when setting up the host to update Pester (Issue #195)
- Updated configurations to use xComputerManagement (Issue #196)
- Updated configuration scripts to better import DSC resource modules
- Modified `Wipe-Lab` to allow removing lab elements without prompting and removing Lab switch is now optional. (Issue #191)
- Modified `Unattend-Lab` to run in a background job (Issue #190)
- Updated `Get-PSAutoLabSetting` to get Pester version (Issue #197)
- Updated `Get-LabSnapshot` (Issue #192)
- Help updates

## v4.2.0

- Updates to `Setup-Lab` to better handle DSCResource installation (Issue #194)
- Updated DSC Resource module versions in configuration files

## v4.1.1

- Updated configurations to run better outside the configuration folder so commands can be run with Start-Job
- Updated configuration tests to better handle paths outside the configuration folder
- Modified functions to better resolve the . path
- Updates to Usage-FAQ.md
- Updates to README.md
- Minor updates to Updating.md
- Archived `Authoring-FAQ.md`. Most of this material was integrated into `Usage-FAQ.md`.

## v4.1.0

- Added SingleServer configuration (Issue #186)
- Modified `Snapshot-Lab` and `Refresh-Lab` to allow the user to specify a snapshot name (Issue #184)
- Added `Get-LabSnapshot` to list available snapshots
- Modified all commands with a -Path to use the parameter. Removed hard-coded reference to ".\".
- Added MultiRole configuration
- Updated `Wipe-Lab` to only remove VHD files associated with the virtual machines in the configuration
- Added WhatIf support to Wipe-Lab
- Help and documentation updates

## v4.0.0

- Complete rewrite and update of all core module commands including better error handling
- Added `Refresh-Host` which can be used copy new configurations when updating this module
- Added `Get-PSAutoLabSettings` to get related version and setting information to aid in troubleshooting
- Added a Changelog
- Published AutoLab module to the PowerShell Gallery
- Configuration updates and testing
- Archived obsolete configurations
- Added external help
- Documentation updates
- Updated README.md
- Updated LICENSE

## v3.1.1

- Included Windows 10 configuration from Jeff Hicks

## v3.1.0

- Updated PSAutolab module with `-IgnorePendingReboot` parameter for `Unattend-Lab` and `Setup-Lab`.
- See GitHub releases for any previous changes

[4.19.0]: https://github.com/pluralsight/PS-AutoLab-Env/compare/v4.18.0..v4.19.0
[4.18.0]: https://github.com/pluralsight/PS-AutoLab-Env/compare/v4.17.0..v4.18.0
[4.17.0]: https://github.com/pluralsight/PS-AutoLab-Env/compare/v4.16.0..v4.17.0
[4.16.0]: https://github.com/pluralsight/PS-AutoLab-Env/compare/v4.15.0..v4.16.0
[4.15.0]: https://github.com/pluralsight/PS-AutoLab-Env/compare/v4.14.0..v4.15.0
[4.14.0]: https://github.com/pluralsight/PS-AutoLab-Env/compare/v4.13.0..v4.14.0
[4.13.0]: https://github.com/pluralsight/PS-AutoLab-Env/compare/v4.12.0..v4.13.0
[4.12.0]: https://github.com/pluralsight/PS-AutoLab-Env/compare/v4.11.0..v4.12.0
[4.11.0]: https://github.com/pluralsight/PS-AutoLab-Env/compare/v4.10.0..v4.11.0
[4.10.0]: https://github.com/pluralsight/PS-AutoLab-Env/compare/v4.9.0..v4.10.0
[4.9.0]: https://github.com/pluralsight/PS-AutoLab-Env/compare/v4.8.0..v4.9.0
[v4.8.0]: https://github.com/pluralsight/PS-AutoLab-Env/compare/v4.7.0..v4.8.0
[v4.7.0]: https://github.com/pluralsight/PS-AutoLab-Env/compare/v4.6.0..v4.7.0
[v4.6.0]: https://github.com/pluralsight/PS-AutoLab-Env/compare/v4.5.0..v4.6.0
[v4.5.0]: https://github.com/pluralsight/PS-AutoLab-Env/compare/v4.4.0..v4.5.0