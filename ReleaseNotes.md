# Release Notes

## PSAutoLab 5.0.0

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

[5.0.0]: https://github.com/pluralsight/PS-AutoLab-Env/compare/v4.22.1..v5.0.0
