# PSAutoLab

[![PSGallery Version](https://img.shields.io/powershellgallery/v/PSAutoLab.png?style=for-the-badge&logo=powershell&label=PowerShell%20Gallery)](https://www.powershellgallery.com/packages/PSAutoLab/) [![PSGallery Downloads](https://img.shields.io/powershellgallery/dt/PSAutoLab.png?style=for-the-badge&label=Downloads)](https://www.powershellgallery.com/packages/PSAutoLab/)

## Version 5.0.0

This is a **major** update to the module with many breaking changes. It is recommended that you finish and remove all lab configurations before installing this update. Read the [documentation on upgrading to version 5](update-v5.md) for more information.

## Overview

This project serves as a set of "wrapper" commands that utilize the [Lability](https://github.com/VirtualEngine/Lability) module which is a terrific tool for creating a lab environment of Windows-based systems. The downside is that it is a difficult module for less experienced PowerShell users. The configurations and control commands for the Hyper-V virtual machines in this module are written in PowerShell using `Desired State Configuration (DSC)` and deployed via Lability commands. If you feel sufficiently skilled, you can skip using this project and use the Lability module on your own. Note that the Lability module is not owned or managed by Pluralsight. This project and all files are released under an MIT License - meaning you can copy and use as your own, modify, borrow, steal - whatever you want.

**While this project is under the Pluralsight banner, it is offered AS-IS as a free tool with no official support from Pluralsight. Pluralsight makes no guarantees or warranties. This project is intended to be used for educational purposes only.**

Beginning with module version 4.17.0, you can run [Open-PSAutoLabHelp](docs/Open-PSAutoLabHelp.md) to view a local PDF version of the module's documentation.

```shell
PS C:\> Open-PSAutoLabHelp
```

## Requirements

This module is designed and intended to be run on a **Windows 10/11** client that supports virtualization. Windows 10 Pro or Enterprise and later should be sufficient. It is assumed you will be installing this on a Windows 10/11 desktop running Windows PowerShell 5.1. This module will **not** work and is unsupported on any Home or Student edition, although there are reports of the module working on Windows 10 Education. The module _might_ run on Windows Server (2016 or 2019) platforms, but this capability has not been fully tested nor is it supported.

Using this in a nested virtual environment _may_ work, but don't be surprised if there are problems, especially related to networking and NAT.

The host computer, where you are installing, must meet the following requirements:

* Windows PowerShell 5.1.
* A high-speed internet connection.
* Minimum 16GB of RAM (32GB is recommended).
* Minimum 100GB free disk space preferably on a fast SSD device or equivalent.
* An Intel i5 processor or equivalent. An i7 is recommended for the best performance.
* Windows PowerShell Remoting enabled.
* You should be logged in with a local or domain user account. The setup process may not work properly if using an O365 or Microsoft account to log on to Windows.

You must have administrator access and be able to update the `TrustedHosts` setting for PowerShell remoting. If you are in a corporate environment, these settings may be locked down or restricted. If this applies to you, this module may not work properly, if at all.

**This module and configurations have NOT been tested running under PowerShell 7. You must run this under Windows PowerShell 5.1.**

### Pester Requirement

The module uses a standard PowerShell tool called Pester to validate lab configurations. It is a module dependency and the latest version should be installed with the PSAutolab module. Previous versions of this module required Pester version 4.10. Beginning with version 5.0 of this module, all Pester tests have been revised to support Pester version 5.

## Installation

This module has been published in the PowerShell Gallery. It is recommended that you have at least version 2.2 of the `PowerShellGet` module which handles module installations.

Open an elevated PowerShell prompt and run:

```shell
Install-Module PSAutoLab -Force -SkipPublisherCheck
```

If you are using the `Microsoft.PowerShell.PSResourceGet`module run:

```shell
Install-PSResource PSAutoLab -Force
```

The installation should install the required dependencies of the Lability and Pester modules.** You must include the `-SkipPublisherCheck` to ensure the Pester module is installed**.

If prompted, answer yes to update the Nuget version and to install from an untrusted repository, unless you've already marked the PSGallery as trusted. If you have an old copy of this module from before Pluralsight took ownership, you will get an error. Manually remove the old module files and try again. See [this document](Updating.md) for more information.

**Do not download or use any of the release packages from this GitHub repository. You must install this module from the PowerShell Gallery.**

See the [Changelog](https://github.com/pluralsight/PS-AutoLab-Env/blob/master/changelog.md) for update and version details.

**DO NOT run this module on any mission-critical or production system.**

If you encounter issues with a basic installation and setup, you should read and use the [detailed setup instructions](Detailed-Setup-Instructions.md).

You can verify the module with these commands:

```shell
PS C:\> Import-Module PSAutoLab -force
PS C:\> Get-Module PSAutoLab

ModuleType Version    Name           ExportedCommands
---------- -------    ----           ----------------
Script     5.0.0      PSAutoLab     {Enable-Internet, Get-LabSnapshot,...}
```

Your version number may differ.

### Hyper-V

This module and its configurations should not conflict with any existing Hyper-V virtual machines or networking. But you should be aware that the module will create a new., internal Hyper-V switch called `LabNet`. This switch will use a NAT configuration called `LabNat`.

```shell
PS C:\> Get-NetNat LabNat


Name                             : LabNat
ExternalIPInterfaceAddressPrefix :
InternalIPInterfaceAddressPrefix : 192.168.3.0/24
IcmpQueryTimeout                 : 30
TcpEstablishedConnectionTimeout  : 1800
TcpTransientConnectionTimeout    : 120
TcpFilteringBehavior             : AddressDependentFiltering
UdpFilteringBehavior             : AddressDependentFiltering
UdpIdleSessionTimeout            : 120
UdpInboundRefresh                : False
Store                            : Local
Active                           : True
```

The `Instructions` file in each configuration folder documents VMs will be created. You can also check the `VMConfigurationData.psd1` file.

```shell
PS C:\Autolab\Configurations\MultiRole\> (Import-PowerShellDataFile .\VMConfigurationData.psd1).AllNodes.NodeName
*
DC1
S1
Cli1
```

Current configurations will use these names for the virtual machine and computer name:

* DC1
* S1
* S2
* Cli1
* Cli2
* DOM1
* SRV1
* SRV2
* SRV3
* WIN10
* WIN11
* Win10Ent

_Nano Server images have been removed from configurations. These configurations were using the now deprecated version of Nano. Microsoft has changed direction with regards to Nano Server and none of the existing configurations use this new version._

### Upgrading Previous Versions

#### Upgrading from v3.x

If you installed previous versions of this module (v3.x) and struggled, hopefully, this version will be an improvement. To avoid any other complications, it is STRONGLY recommended that you manually remove the old version which is most likely under `C:\Program Files\WindowsPowerShell\Modules\PSAutoLab`. You can run a command like:

```shell
Get-Module PSAutoLab -ListAvailable | Select-Object Path
```

To identify the module location. Use this information to delete the PSAutoLab folder.

**The previous version was not installed using PowerShell's module cmdlets so it can't be updated or removed except manually.**

### Upgrading from v4.x

Please read [this document](update-v5.md) for more information on the steps to follow to update this module from version `4.x` to `5.x`

### Note for VMware Users

This project is designed to work with Hyper-V. If you are going to build a Host VM of Server 2016 or Windows 10, In the general settings for your VM, you must change the OS type to `Hyper-V(Unsupported)` or the Host Hyper-V will not work! This module and its configurations have **not** been tested for compatibility with VMware.

## Aliases and Language

While this module follows proper naming conventions, the commands you will typically use employ aliases that use non-standard verbs such as `Run-Lab`. This is to avoid conflicts with commands in the Lability module and to maintain backward compatibility. You can use the aliases or the full function name. All references in this document use the aliases. You do not need to run any commands from the Lability module.

## Setup Host

The first time you use this module, you will need to configure the local machine or host. Open an elevated PowerShell session and run:

```shell
Setup-Host
```

This will install and configure the Lability module and install the Hyper-V feature if it is missing. By default, all AutoLab files will be stored under `C:\AutoLab`, which the setup process will create. If you prefer to use a different drive, you can specify it during setup.

```shell
Setup-Host -DestinationPath D:\AutoLab
```

You will be prompted to reboot, which you should do especially if the setup had to add the Hyper-V feature. To verify your configuration open an elevated PowerShell session and run this command:

```shell
PS C:\> Get-PSAutoLabSetting


AutoLab                     : C:\Autolab
PSVersion                   : 5.1.19041.1
PSEdition                   : Desktop
OS                          : Microsoft Windows 10 Pro
FreeSpaceGB                 : 172.49
MemoryGB                    : 32
PctFreeMemory               : 44.66
Processor                   : Intel(R) Core(TM) i7-7700T CPU @ 2.90GHz
IsElevated                  : True
RemotingEnabled             : True
NetConnectionProfile        : Private
HyperV                      : 10.0.19041.1
PSAutoLab                   : {4.18.0, 4.17.0}
Lability                    : {0.19.1, 0.19.0, 0.18.0}
Pester                      : {4.10.1, 4.10.0, 4.9.0, 4.4.4...}
PowerShellGet               : 2.2.3
PSDesiredStateConfiguration : 1.1
```

Some of your values may be different. Please include this information when reporting any problems or issues.

### Lab Summary

Once the host setup is complete, you can use the module's [Get-LabSummary](docs/Get-LabSummary.md) command to better understand what the lab configuration will set up. Run the command in the configuration folder.

```shell
PS C:\Autolab\Configurations\SingleServer-GUI-2016\> Get-LabSummary


   Computername: S1 VMName: S1

Lab                       IPAddress       MemGB Procs Role    Description
---                       ---------       ----- ----- ----    -----------
SingleServer-GUI-2016     192.168.3.75        4     1 RDP     Windows Server
                                                              2016 Standard
                                                              64bit English
                                                              Evaluation
```

The module includes a custom format file. You might also run the command like this:

```shell
PS C:\Autolab\Configurations\SingleServer-GUI-2016> Get-LabSummary |
Select-Object *


Computername : S1
VMName       : S1
InstallMedia : 2016_x64_Standard_EN_Eval
Description  : Windows Server 2016 Standard 64bit English Evaluation
Role         : RDP
IPAddress    : 192.168.3.75
MemoryGB     : 4
Processors   : 1
Lab          : SingleServer-GUI-2016
```

The `Computername` and `VMName` properties might differ if you are using an environmental prefix. The `Computername` is how the virtual machines refer to themselves and each other. The `VMName` is how you reference them in Hyper-V.

## Creating a Lab

Lab information is stored under the AutoLab Configurations folder, which is `C:\AutoLab\Configurations` by default. Open an elevated PowerShell prompt and change your location to the desired configuration folder. View the `Instructions` and/or `README` markdown files in the folder to learn more about the configuration.

You can also run `Get-LabSummary` in the lab configuration folder to see what the configuration will create.

Where possible, information about what course goes with a particular Pluralsight course will be indicated.

### A Note on Pluralsight Labs

_This module started several years _ago and _several Pluralsight courses rely_ on configurations_ that may no longer exist. Configurations that were named with `Test` or `POC` were not assumed to be used in any courses. But that is turning out to not be the case. If you are trying to set up a lab for a specific course, and can't find the configuration the instructor calls for, please post an issue indicating the configuration you are looking for and the title of the Pluralsight course. Hopefully, there is an existing configuration you can use. Or the module can be updated with an appropriate lab configuration. In some cases, the course may assume a different password. All configurations use `P@ssw0rd` for all passwords._

The first time you set up a lab, Lability will download evaluation versions of required operating systems in ISO format. This may take some time depending on your Internet connection. These downloads only happen when the required ISO is not found locally. When you wipe and rebuild a lab it won't download files a second time.

Once the lab is created, you can use the PSAutoLab commands to manage it. If you have additional PowerShell experience, you can manage individual virtual machines using the Hyper-V manager or cmdlets.

_It is assumed that you will only have one lab configuration created at a time._

Please be aware that all configurations were created for an `EN-US` culture and keyboard.

### Manual Setup

Most, if not all, configurations should follow the same manual process. Run each command after the previous one has finished.

* [Setup-Lab](docs/Invoke-SetupLab.md)
* [Run-Lab](docs/Invoke-RunLab.md)
* [Enable-Internet](docs/Enable-Internet.md)

To verify that all virtual machines are properly configured you can run [Validate-Lab](docs/Invoke-ValidateLab.md). This will invoke a set of tests and keep looping until everything passes. Due to the nature of DSC and the complexity of some configurations, this could take up to 60 minutes. You can use `Ctrl+C` to break out of the testing loop at any time. You can manually run the test one time to see the current state of the configuration.

```shell
PS C:\Autolab\Configurations\SingleServer\> Invoke-Pester VMValidate.test.ps1
```

This can be useful for troubleshooting.

### Unattended Setup

As an alternative, you can set up a lab environment with minimal prompting.

```shell
PS C:\Autolab\Configurations\SingleServer\> Unattend-Lab
```

Assuming you don't need to install a newer version of `Nuget`, you can leave the setup alone. It will run all of the manual steps for you. Beginning in version `4.3.0` you also have the option to run the unattended setup in a PowerShell background job.

```shell
PS C:\Autolab\Configurations\SingleServer\> Unattend-Lab -AsJob
```

Use the PowerShell job cmdlets to manage.

### Stopping a Lab

To stop the lab VMs, change to the configuration folder in an elevated Windows PowerShell session and run:

```shell
PS C:\Autolab\Configurations\SingleServer\> Shutdown-Lab
```

You can also use the Hyper-V manager or cmdlets to manually shut down virtual machines. If your lab contains a domain controller such as `DOM1` or `DC1`, that should be the last virtual machine to shut down.

### Starting a Lab

The setup process will leave the virtual machines running. If you have stopped the lab and need to start it, change to the configuration folder in an elevated Windows PowerShell session and run:

```shell
PS C:\Autolab\Configurations\SingleServer\> Run-Lab
```

You can also use the Hyper-V manager or cmdlets to manually start virtual machines. If your lab contains a domain controller such as `DOM1` or `DC1`, that should be the first virtual machine to start up.

### Lab Checkpoints

You can snapshot the entire lab very easily. Change to the configuration folder in an elevated Windows PowerShell session and run:

```shell
PS C:\Autolab\Configurations\SingleServer\> Snapshot-Lab
```

To quickly rebuild the labs from the checkpoint, run:

```shell
PS C:\Autolab\Configurations\SingleServer\> Refresh-Lab
```

Or you can use the Hyper-V cmdlets to create and manage VM snapshots.

### To Remove a Lab

To destroy the lab completely, change to the configuration folder in an elevated Windows PowerShell session and run:

```shell
PS C:\Autolab\Configurations\SingleServer\> Wipe-Lab
```

This will remove the virtual machines and DSC configuration files. If you intend to rebuild the lab or another configuration, you can keep the `LabNat` virtual switch. This is the default behavior. If you want to remove everything you would need to run a command like this:

```shell
PS C:\Autolab\Configurations\SingleServer\> Wipe-Lab -force -RemoveSwitch
```

### Customizing a Lab

It is possible to customize a lab configuration by editing the `VMConfigurationData.psd1` file that is in each configuration folder. You must modify the file before creating the lab. For example, the configuration might use Server Core and you want the Desktop Experience on the server. Open the file in your scripting editor and scroll down to find the Node definitions.

```shell
@{
    NodeName                = 'DOM1'
    IPAddress               = '192.168.3.10'
    Role                    = @('DC', 'DHCP', 'ADCS')
    Lability_BootOrder      = 10
    Lability_BootDelay      = 60
    Lability_timeZone       = 'US Mountain Standard Time'
    Lability_Media          = '2016_x64_Standard_Core_EN_Eval'
    Lability_MinimumMemory  = 2GB
    Lability_ProcessorCount = 2
    CustomBootStrap         = @'
            # This must be set to handle larger .mof files
            Set-Item -path wsman:\localhost\maxenvelopesize -value 1000
'@
},

@{
    NodeName           = 'SRV1'
    IPAddress          = '192.168.3.50'
    Role               = @('DomainJoin')
    Lability_BootOrder = 20
    Lability_timeZone  = 'US Mountain Standard Time'
    Lability_Media     = '2016_x64_Standard_Core_EN_Eval'
},
```

You can edit the `Lability_Media` setting. Change the setting using one of these ID values from running `Get-LabMedia`.

```shell
PS C:\> Get-LabMedia

Id                                      Arch Media Description
--                                      ---- ----- -----------
2022_x64_Standard_EN_Eval                x64   ISO Windows Server 2022 Standard 64bit English Evaluation with Deskto...
2022_x64_Standard_EN_Core_Eval           x64   ISO Windows Server 2022 Standard 64bit English Evaluation
2022_x64_Datacenter_EN_Eval              x64   ISO Windows Server 2022 Datacenter 64bit English Evaluation with Desk...
2022_x64_Datacenter_EN_Core_Eval         x64   ISO Windows Server 2022 Datacenter Evaluation in Core mode
2019_x64_Standard_EN_Eval                x64   ISO Windows Server 2019 Standard 64bit English Evaluation with Deskto...
2019_x64_Standard_EN_Core_Eval           x64   ISO Windows Server 2019 Standard 64bit English Evaluation
2019_x64_Datacenter_EN_Eval              x64   ISO Windows Server 2019 Datacenter 64bit English Evaluation with Desk...
...
```

You can also make changes to values such as minimum memory and processor count. When you run `Unattend-Lab` or `Setup-Lab` you can use the `-UseLocalTimeZone` to set all virtual machines to use your time zone. You could make _minor_ changes to the IP address such as changing the address from `192.168.3.50` to `192.168.3.60`. Changing the entire subnet will require modifying the virtual switch and should not be attempted unless you are very proficient with PowerShell and Hyper-V.

**Note that if you make changes, the validation test may fail unless you modify it. But you can always try to run the lab without validating it.**

If you make a mistake or want to restore the original configurations, run the `Refresh-Host` command.

## Windows 10 Remote Server Administration Tools (RSAT)

Several lab configurations that include a Windows 10 client will also install RSAT. In the past, this has meant trying to install _all_ RSAT features. This takes a long time and has caused validation issues. Beginning with v4.21.0 of the PSAutolab module, the RSAT configuration and testing will only use a subset of features.

* ActiveDirectory
* BitLocker
+*CertificateServices
* DHCP
* DNS
* FailoverCluster
* FileServices
* GroupPolicy
* IPAM.Client
* ServerManager

If you require any other tool, you will need to use `Add-WindowsCapability` in the Windows 10/11 client to add it.

This change has improved setup performance and module stability.

## Windows Updates

When you build a lab, you are creating Windows virtual machines based on evaluation software. You might still want to make sure the virtual machines are up to date with security patches and updates. You can use [Update-Lab](docs/Update-Lab.md) to start the Windows update process on all lab members. This can be a time-consuming process. You have an option to run the updates as a background job. Do not close your PowerShell session before the jobs are complete or the build process will be interrupted.

```shell
PS C:\Autolab\Configurations\PowerShellLab\> update-lab -AsJob

Id   Name        PSJobTypeName   State      HasMoreData   Location    Command
--   ----        -------------   -----      -----------   --------    -------
18   WUUpdate    RemoteJob       Running    True          DOM1        WUUpdate
21   WUUpdate    RemoteJob       Running    True          SRV1        WUUpdate
24   WUUpdate    RemoteJob       Running    True          SRV2        WUUpdate
27   WUUpdate    RemoteJob       Running    True          SRV3        WUUpdate
30   WUUpdate    RemoteJob       Running    True          WIN10       WUUpdate

PS C:\Autolab\Configurations\PowerShellLab> receive-job -id 27 -Keep
[11/22/2019 12:05:43] Found 5 updates to install on SRV3
[11/22/2019 12:25:13] Update process complete on SRV3
WARNING: SRV3 requires a reboot
```

Run the update process as a background job. Use the PowerShell job cmdlets to manage.

## Updating PSAutoLab

As this module is updated over time, new configurations may be added, or bugs fixed in existing configurations. There may also be new Lability updates. Use PowerShell to check for new versions:

```shell
Find-Module PSAutoLab
```

And update:

```shell
Update-Module PSAutoLab -Force
```

If you update, it is recommended that you update the AutoLab configuration.

```shell
Refresh-Host
```

This will update the Lability and Pester modules if required and copy all new configuration files to your AutoLab\Configurations folder. It will NOT delete any files or folders.

## Removing PSAutoLab

If you want to completely remove the PSAutoLab module, first use `Wipe-Lab` to remove any existing lab configurations including the Hyper-V switch. Run this command to uninstall the module and its dependencies

```shell
Uninstall-Module PSAutoLab,Lability
```

You may need to manually delete the `C:\Autolab` folder. If you want to remove the NAT configuration"

```shell
Remove-NetNat LabNat
```

If you want to remove Hyper-V you can use the Control Panel to manually remove the optional feature. Or you can try using PowerShell.

```shell
Get-WindowsOptionalFeature -FeatureName *Hyper* -online |
Disable-WindowsOptionalFeature -Online
```

You will almost certainly need to reboot to complete the removal process.

## Troubleshooting

### Package Provider or Module Installation

If you try to install a module or update the NuGet provider, you might see warnings like these:

```shell
WARNING: Unable to download from URI 'https://go.microsoft.com/fwlink/?LinkID=627338&clcid=0x409' to ''.
WARNING: Unable to download the list of available providers. Check your internet connection.
PackageManagement\Install-PackageProvider : No match was found for the specified search criteria for the provider 'NuGet'. The package provider requires 'PackageManagement' and
'Provider' tags.
```

The first thing to check is to make sure you are using valid TLS settings. You can try running this command in PowerShell:

```shell
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
```

Beginning with v4.17.0 of this module, this change is made when the module is imported. It will only last for as long as your PowerShell session is running.

You could also modify the registry in an elevated PowerShell session for a more permanent solution.

```shell
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\.NetFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value 1
```

Modifying the registry will require a reboot for the changes to take effect.

If the problem is the Nuget provider, after making the TLS changes try:

```shell
Install-PackageProvider Nuget -force -ForceBootStrap
```

You might also need to update the `PackageManagement` and/or `PowerShellGet` modules.

```shell
Update-Module PowershellGet,PackageManagement -force
```

### Autolab Configurations

The commands and configurations in this module are not foolproof. During testing a lab configuration will run quickly and without error on one Windows 10 desktop but fail or take much longer on a different Windows 10 desktop. Most setups should be completed in under an hour. If validation is failing, manually run the validation test in the configuration folder.

```shell
PS C:\Autolab\Configurations\SingleServer\> Invoke-Pester VMValidate.test.ps1 -Show All -WarningAction SilentlyContinue
```

Take note of which virtual machines are generating errors. Verify the virtual machine is running in Hyper-V. On occasion, for reasons still undetermined, sometimes a virtual machine will shut down and not reboot. This often happens with the client nodes of the lab configuration. Verify that all virtual machines are running and manually start those that have stopped using the Hyper-V manager or cmdlets.

```shell
Start-VM Win10
```

Sometimes even if the virtual machine is running, manually shutting it down and restarting it can resolve the problem. Remember to wait at least 5 minutes before manually running the validation test again when restarting any virtual machine.

As a last resort, manually break out of any testing loop, wipe the lab, and restart the test.

If you _still_ are having problems, wipe the lab and try a different configuration. This will help determine if the problem is with the configuration or a larger compatibility problem.

At this point, you can open an issue in this repository. Open an elevated PowerShell prompt and run [Get-PSAutoLabSetting](docs/Get-PSAutoLabSetting.md) which will provide useful information. Copy and paste the results into a new issue along with any error messages you are seeing.

## Known Issues

### _I get an error when importing the module_

Starting with version 4.12.0 of this module, you might see this error when you import the module.

```shell
Import-Module : Assertion operator name 'Be' has been added multiple times.
```

This is most likely due to a conflict in Pester module versions. The solution is to remove the Pester module from your current session.

```shell
Get-Module Pester | Remove-Module
```

Then import this module again.

### _I get an error when attempting to update the Lability module_

If you try to run `Refresh-Host` you might see an error about a certificate mismatch. Between v0.18.0 and v0.19.0 the Lability module changed code signing certificates. If you encounter this problem, run

```shell
Refresh-Host -SkipPublisherCheck
```

### Multiple DSC Resources

Due to what is probably a bug in the current implementation of Desired State Configuration in Windows, if you have multiple versions of the same resource, a previous version might be used instead of the required one. You might especially see this with the `xNetworking` module and the `xIPAddress` resource. If you have any version older than 5.7.0.0 you might encounter problems. Run this command to see what you have installed:

```shell
Get-DSCResource xIPAddress
```

If you have older versions of the module, uninstall them if you can.

```shell
Uninstall-Module xNetworking -RequiredVersion 3.0.0.0
```

Beginning with version 4.20.0, you might see the same type of errors with the xDHCP resource. If you encounter errors like `Invalid MOF definition for node 'DC1': Exception calling "ValidateInstanceText" with "1" argument(s): "Undefined
property IsSingleInstance` you might have an older version of a DSCResource module installed.

Run `Get-Module xdhcpserver -list` and remove anything older than version 3.0.0.

```shell
Uninstall-Module xdhcpserver -RequiredVersion 2.0.0.0
```

It is recommended that you restart your PowerShell session and try the lab setup again.

## Acknowledgments

This module is a continuation of the work done by Jason Helmick and Melissa (Missy) Januszko, whose efforts are greatly appreciated. Beginning with v4.0.0, this module is unrelated to any projects Jason or Missy may be developing under similar names.

We also appreciate all of the work that has gone into the Lability module. The Lability and PSAutoLab modules are completely separate and independently maintained.

## Road Map

These are some of the items that are being considered for future updates:

* While Lability currently is for Windows only, it would be nice to deploy a Linux VM.
* Offer an easy way to customize a lab configuration such as node names and operating systems.

A complete list of enhancements (and bugs) can be found in the [Issues](https://github.com/pluralsight/PS-AutoLab-Env/issues) section of this module's GitHub repository. Feel free to make a suggestion.
