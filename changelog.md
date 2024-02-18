# Change Log for PSAutoLab

## [Unreleased]

## [5.1.0] - 2024-02-18

### Changed

- Changed unattended sleep window to 20 minutes.
- Updated documentation formatting and internal links.

## [5.0.0] - 2024-02-15

This is a **major** update to the module. It is recommended that you finish and remove all lab configurations before installing this update. Read the [update documentation](update-v5.md) for more information.

### Changed

- Module re-organization and code cleanup.
- Pester tests revised to support Pester v5.x. [Issue #240](https://github.com/jdhitsolutions/PSAutoLab/issues/240) __This is a breaking change__.
- Updated module to use version 0.25.0 of the Lability module.
- Updated DSC resources to use the latest versions of the `x` resources.
- Updated `PowerShellLab` configuration to use Windows Server 2019 for domain-joined servers and Windows Server 2022 for the workgroup server.
- Updated Windows 10 configurations to use `WIN10_x64_Enterprise_22H2_EN_Eval`.
- Revised `Invoke-ValidateLab` to reflect changes in Pester 5.x. __This is a breaking change__.
- Updated the private Pester check helper function to install or update Pester as needed.
- Inserted a five minute delay in the `Invoke-ValidateLab` function to allow time for the lab to fully boot. This should cut down on Pester test failures
- Documentation updates.

### Added

- Added configuration for Windows Server 2022 (`SingleServer-2022`) running Windows Server Core edition.
- Added configuration for standalone Windows 11 (`Windows11`) running Windows 11 64-bit Enterprise 23H2 English Evaluation.
- Added firewall tests to the validation test for each configuration.
- Added a Pester version check in `PSAutoLab.psm1` to ensure that the module is running with Pester 5.x.
- Added function `Invoke-PesterTest` with alias `Run-Pester` to manually invoke the Pester tests for a lab configuration.
- Added a warning message when importing the module if not using Windows PowerShell 5.1.
- Added parameter alias `Quiet` for `NoMessages`.

### Removed

- Removed Pester 4.10 requirement. The module now supports Pester v5. __This is a breaking change__.
- Archived lab configurations for Windows Server 2012R2. __This is a breaking change__.

## [4.22.1] - 2022-05-19

### Changed

- Updated `Windows10` and `PowerShellLab` configurations to use Windows 10 64bit Enterprise 2109/21H2 English Evaluation. They were missed in the previous update.
- Fixed memory settings in `PowerShellLab` configuration for Win10 virtual machine.
- Revised code formatting in the help PDF.

## [4.22.0] - 2022-05-17

### Changed

- Updated Lability to version `0.21.1`.
- Updated Windows 10 images to use the latest ISO.
- Updated `Updating.md`.
- Marked the `Jason-DSC-Eval` lab configuration as archived.
- Updated `README.md`

### Added

- Added a Windows 11 lab.

## [4.21.0] - 2021-09-21

This release contains changes to lab configuration files. If you are updating the module from a previous version, you should run `Refresh-Host` after updating in a new PowerShell session.

### Added

- Added format file `psautolabresource.format.ps1xml`.

### Changed

- Updated `Multirole-Server-2016` configuration to require all necessary DSC resources.
- Updated`Get-PSAutoLabSetting` to write warnings on potential issues.
- Updated `psautolabsetting.format.ps1xml` to display `Uknown' NetConnectionProfile setting in red.
- Updated `Detailed-Setup-Instructions.md`
- Modified `Test-LabDSCResource` to write a `PSAutolabResource` object.
- Updated `PowerShellLab` configuration to use 3.2.0 of the `xWebAdministration` module.
- Updated `PowerShellLab` configuration to use the `ComputerManagementDSC` module in place of `xComputerManagement`. This also deprecates the use of `xPendingReboot`. The `xPendingReboot` resource has been removed from all configurations that are no longer use it.
- Updated `PowerShellLab` configuration test file to remove `Test-DSCconfiguration` test.
- Modified `PowerShellLab` configuration to give `WIN10` 4GB of memory.
- Revised validation test for `PowerShellLab` configuration to better test for RSAT and display what features are still failing.
- Modified all configurations that were installing RSAT on Windows 10 clients to __only install a subset of features__.  *__This may be considered a breaking change__* but since only a few features are probably ever used, this shouldn't affect too many people. See the RSAT section [README.md](README.md) for more information.
- Updated `Write-Progress` message in `Invoke-ValidateLab` to suggest checking if all VMs are running and to provide testing details.
- `Invoke-ValidateLab` will automatically check for stopped VMs after 3 passes and automatically start them.
- `Invoke-ValidateLab` will restart VMs still failing after 5 passes and abort after 65 minutes with a warning message.
- Added `MultiRole-GUI` lab configuration.
- Help updates.
- Updated `README.md`

### Removed

- Removed `xWindowsUpdate` resource from `PowerShellLab` configuration.
- Removed `Nano` VM validation tests lab configurations.

## [4.20.0] - 2021-04-27

### Changed

- Updated Lability requirement to 0.20.0 which includes updated media.
- Updated Windows 10 configurations to use Windows 10 20H2 build.
- Updated `Get-LabSummary` to use media information from `Lability\Get-Media`.
- Updated configurations to use version 3.0.0 of the xDHCPServer module for DSC configurations. This deprecated the `xDCHPServerOption` resource.
- Updated `README.md`.

[Unreleased]: https://github.com/pluralsight//PS-AutoLab-Env/compare/v5.1.0..HEAD
[5.1.0]: https://github.com/pluralsight//PS-AutoLab-Env/compare/v5.0.0..v5.1.0
[5.0.0]: https://github.com/pluralsight/PS-AutoLab-Env/compare/v4.22.1..v5.0.0
[4.22.1]: https://github.com/pluralsight/PS-AutoLab-Env/compare/v4.22.0..v4.22.1
[4.22.0]: https://github.com/pluralsight/PS-AutoLab-Env/compare/v4.21.0..v4.22.0
[4.21.0]: https://github.com/pluralsight/PS-AutoLab-Env/compare/v4.20.0..v4.21.0
[4.20.0]: https://github.com/pluralsight/PS-AutoLab-Env/compare/v4.19.0..v4.20.0