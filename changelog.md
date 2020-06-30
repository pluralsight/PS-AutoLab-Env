# Change Log for PSAutoLab

## 4.15.0

### Add

+ Added troubleshooting content to `README` about potential TLS issues updating nuget or module. (Issue #224)

### Change

+ Modified `Wipe-Lab` to simply turn off virtual machines (Issue #229)
+ Modified all commands to use fully qualified command names
+ Modified `Invoke-SetupHost` with additional verbose messaging

### Delete

+ Deleted duplicate function `Invoke-WUUpdate` from `public.ps1`. This was a leftover before it was moved to a private function. (Issue #230)

## 4.14.0

### Add

+ Restored variable definition for `$LabilityVersion` in the psm1 file.

### Change

+ Modified Lability commands in `Invoke-SetupHost` to use fully qualified command name.
+ Updated -WhatIf messages in `Invoke-Setup-Host`

### Delete

+ none

## 4.13.0

## Add

+ none

## Change

+ Added more Verbose messaging to `Invoke-SetupLab`.
+ Modified `Invoke-ValidateLab` to import and use the approved version of the Pester module.
+ Updated validation test for `PowerShellLab` configuration to fix error validating domain admin membership. (Issue # 226)
+ Modified `Invoke-ValidateLab` to remove all versions of Pester and then load the version compatible with this module.
+ Updated `Invoke-SetupLab` to use `(Get-TimeZone).id` when using local time zone. (Issue #227)

## Delete

+ None

## 4.12.0

## Add

+ Added a new function, `Test-LabDSCResource` which can be used to see if the required DSC resources are already installed and to display what versions are installed.

## Change

+ Updated `README` with clearer setup instructions
+ Updated `Detailed-Setup-Instructions.md`
+ Modified manifest to install and use required module versions.

## Delete

+ Commented out NanoServer installations in configurations that used them since the original use case has been deprecated by Microsoft.

## 4.11.0

### Add

+ Added code to test for and install Pester v4.10.1. Pester v5 breaks the current validation tests. (Issue #223)
+ Added PSDesiredState module version information to `Get-PSAutoLabSetting`

### Change

+ Updated documentation to reflect Pester requirements.
+ Updated `Invoke-ValidateLab` to explicitly import the supported version of Pester.
+ Updated module manifest to specify required module versions for Lability and Pester
+ Modified `Get-PSAutoLabSetting` to return all installed versions of Pester
+ Help updates

### Delete

+ Removed Archived configurations from the Configurations path. This will not remove them for people who upgrade. The files are still part of this module for reference purposes.

## 4.10.0

### Add

+ none

### Change

+ Updated `README.md` with additional requirements and information.
+ Updated `Detailed-Setup-Instructions.md` with information about using an environment prefix.
+ Updated test files to show `New-PSSession` error message in output.
+ Updated commands and files to support using `EnvironmentPrefix` values. (Issue #217)
+ Updated lab configurations to use newer TLS settings via a registry change (Issue #216)

### Delete

+ none

## 4.9.0

### Add

+ Added lab configurations `SingleServer2012R2` and `SingleServer2012R2-GUI` (Issue #215)
+ Updated `Authoring-FAQ.md` and restored it to this project.

### Change

+ Modified validation test for `PowerShellLab` lab to that was testing for specific Windows 10 version number. (Issue #214)
+ Updated validation test for `PowerShellLab` lab to better display errors creating remoting sessions.
+ Modified validation test for `Windows10` lab to test for operating system.
+ Updated `Detailed-Setup-Instructions.md`.
+ Updated `README.md`
+ Minor revisions to `Updating.md`.
+ Minor revisions to `Updating.md`.

### Delete

+ none

## v4.8.0

### Add

+ Added "Detailed-Setup-Instructions.md`.
+ Added code to module file to check for new version in the PowerShell Gallery.
+ Added `SingleServer-GUI-2019` configuration.
+ Added `Get-LabSummary` function.
+ Added a `-NoMessages` parameter to most commands in the module to offer an option to suppress the status and information messages displayed with `Write-Host`.

### Change

+ Modified `Get-PSAutoLabSetting` to include additional information.
+ Updated `Instructions.md` to provide more detail about each lab.
+ Updated `README.md` with information on customizing a configuration.
+ Updated validation test for `SingleServer-GUI-2016` to test RDP.
+ Increased the memory for `SingleServer` to 2GB.
+ Updated validation tests for all configurations for better performance and to suppress error messages while configurations are converging.
+ Updated DSC configurations for `SingleServer-GUI-2019`,`SingleServer`,`SingleServer-GUI-2016` to uninstall PowerShell-V2.
+ Fixed bug in `Wipe-Lab` that failed to properly import lab data.
+ Suppressing `Write-Warning` messages in `Wipe-Host` when VM is already shut down.
+ Modified `MultiRole` configuration to use Windows Server 2019.
+ Restored deleted Nano-related NonNode data in configurations that include a Nano server.
+ Help updates

### Delete

+ Removed Active Directory json files from `SingleServer` configurations since they are not used.
+ Removed Active Directory, DHCP Server and ADCS DSC resources from `SingleServer*` configuration files since they are not used.

## v4.7.0

### Add

+ none

### Change

+ Corrected minor typos in `VMValidate.test.ps1` in the `PowerShellLab` configuration.
+ Updated Lability module version to `0.19.1`.
+ Updated `xPSDesiredStateConfiguration` to version `9.1.0`.
+ Expanded command aliases in `VMValidate.Test.ps1` in the `Microsoft-PowerShell-Implementing-JEA` configuration.
+ Updated `README.md` with improved setup instructions and background information.

### Delete

+ none

## v4.6.0

### Add

+ Configuration `SingleServer-GUI-2016` (Issue 208)
+ Configuration `MultiRole-Server-2016` (Issue 209)

### Change

+ Updated manifest tags
+ Changed `Write-Host` commands to use fully qualified name `Microsoft.PowerShell.Utility\Write-Host`
+ Modified `Invoke-UnattendLab` to pass `-Verbose` to the scriptblock for better troubleshooting
+ Modified `Invoke-SetupLab` and `Invoke-ValidateLab` to provide more verbose detail
+ Fixed minor spelling error in `VMConfiguration.ps1` scripts
+ Updated `README.md`

### Delete

+ none

## v4.5.0

### Add

+ Added the parameter `-UseLocalTimeZone` to `Invoke-SetupLab` and `Unattend-Lab` to overwrite configuration specified timezone information with the time zone of the local host. (Issue #185)

### Change

+ Updated Lability requirement to version 0.19.0
+ Updated  `xPSDesiredStateConfiguration` DSC resource requirement to version 9.0.0
+ Updated `xDnsServer` DSC resource requirement requirement to 1.16.0.0
+ Updated `xWebAdministration` DSC resource requirement requirement to 3.1.1
+ Updated `PSAutoLab.psm1` to display a message if Lability version is outdated.
+ Updated `Invoke-RefreshHost` to include a `-SkipPublisherCheck` parameter
+ Updated private function `_labilityCheck` to include a `-SkipPublisherCheck` parameter
+ Updated `LICENSE`
+ Updated `Usage-FAQ.md`
+ Updated `Instruction.md` for each configuration to include information about installing Windows Updates
+ Help updates
+ Updated `README.md`

### Delete

+ Removed Windows update tools from PostSetup in the PowerShellLab configuration. Use `Update-Lab` instead.

### Notes

Beginning with this version, the change log is now in markdown and will provide more details about what has changed in the module.

## v4.4.0

+ Modified Pester tests with a little more error handling.
+ Moved default user location to the Employees OU instead of the domain root for the PowerShellLab configuration
+ Added Test-isAdministrator private function
+ Updated `Get-PSAutoLabSetting` to reflect memory in GB, report on percent free memory, and Hyper-V version
+ Updated `Get-PSAutoLabSetting` to show all installed versions of Lability and PSAutoLab modules
+ Updated `Get-PSAutoLabSetting` to show if running with elevated privileges
+ Updated xPSDesiredStateConfiguration resource to 8.10.0.0
+ Updated xDNSServer to 1.15.0.0
+ Added `Invoke-WUUpdate` as a private function with a public wrapper function of `Update-Lab` to install Windows Updates on the virtual machines.
+ Help and documentation updates

## v4.3.0

+ Added code when setting up host to update Pester (Issue #195)
+ Updated configurations to use xComputerManagement (Issue #196)
+ Updated configuration scripts to better import DSC resource modules
+ Modified `Wipe-Lab` to allow removing lab elements without prompting and removing Lab switch is now optional. (Issue #191)
+ Modified `Unattend-Lab` to run in a background job (Issue #190)
+ Updated `Get-PSAutoLabSetting` to get Pester version (Issue #197)
+ Updated `Get-LabSnapshot` (Issue #192)
+ Help updates

## v4.2.0

+ Updates to `Setup-Lab` to better handle DSCResource installation (Issue #194)
+ Updated DSC Resource module versions in configuration files

## v4.1.1

+ Updated configurations to run better outside the configuration folder so commands can be run with Start-Job
+ Updated configuration tests to better handle paths outside the configuration folder
+ Modified functions to better resolve the . path
+ Updates to Usage-FAQ.md
+ Updates to README.md
+ Minor updates to Updating.md
+ Archived Authoring-FAQ.md. Most material was integrated into Usage-FAQ.md

## v4.1.0

+ Added SingleServer configuration (Issue #186)
+ Modified `Snapshot-Lab` and `Refresh-Lab` to allow user to specify a snapshot name (Issue #184)
+ Added `Get-LabSnapshot` to list available snapshots
+ Modified all commands with a -Path to use the parameter. Removed hard-coded reference to ".\".
+ Added MultiRole configuration
+ Updated `Wipe-Lab` to only remove VHD files associated with the virtual machines in the configuration
+ Added WhatIf support to Wipe-Lab
+ Help and documentation updates

## v4.0.0

+ Complete rewrite and update of all core module commands including better error handling
+ Added `Refresh-Host` which can be used copy new configurations when updating this module
+ Added `Get-PSAutoLabSettings` to get related version and setting information to aid in troubleshooting
+ Added a Changelog
+ Published AutoLab module to the PowerShell Gallery
+ Configuration updates and testing
+ Archived obsolete configurations
+ Added external help
+ Documentation updates
+ Updated README.md
+ Updated LICENSE

## v3.1.1

+ Included Windows 10 configuration from Jeff Hicks

## v3.1.0

+ Updated PSAutolab module with `-IgnorePendingReboot` parameter for `Unattend-Lab` and `Setup-Lab`.
+ See GitHub releases for any previous changes
