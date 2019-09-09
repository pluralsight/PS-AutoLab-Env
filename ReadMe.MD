# PSAutoLab

This project serves as a set of "wrapper" commands that utilize the [Lability])https://github.com/VirtualEngine/Lability) module which is a terrific tool for creating a lab environment of Windows based systems.
The downside is that it is a difficult module for less experienced PowerShell users.
The configurations and control commands for the Hyper-V virtual machines are written in PowerShell using Desired State Configuration (DSC) and deployed via Lability.
If you feel sufficiently skilled, you can skip using this project and use the Lability module on your own.
This project and all files are released under an MIT License - meaning you can copy and use as your own, modify, borrow, steal - whatever you want.

**While this project is under the Pluralsight banner, it is offered AS-IS as a free tool with no official support from Pluralsight.
Pluralsight makes no guarantees or warranties.
This project is intended to be used for educational purposes only.**

## Aliases and Language

While this module follows proper naming conventions, the commands you will typically use employ aliases that use non-standard verbs such as `Run-Lab`.
This is to avoid conflicts with commands in the Lability module and to maintain backwards compatibility.
You can use the aliases or the full function name.
All references in this document use the aliases.

## Previous Versions

If you installed previous versions of this module, and struggled, hopefully this version will be an improvement.
To avoid any other complications, it is STRONGLY recommended that you manually remove the old version which is most likely under `C:\Program Files\WindowsPowerShell\Modules\PSAutoLab`.
The previous version was not installed using PowerShell' module cmdlets so it can't be updated or removed except manually.

## Installation

This project has been published to the PowerShell Gallery.
It is recommended that you have at least version 2.2 of the `PowerShellGet` module which handled module installations.
Open an elevated PowerShell prompt and run:

```powershell
Install-Module PSAutoLab
```

If prompted, answer yes to update the nuget version and to install from an untrusted repository, unless you've already marked the PSGallery as trusted.
If you have an old copy from before Pluralsight took ownership you will get an error.
Manually remove the old module files and try again.

**DO NOT run this module on any mission-critical production system.**

### Requirements

This tool currently supports running on either Windows Server 2016 (not fully tested) or a Windows 10 client that supports virtualization.
It is assumed you will be installing this on a Windows 10 desktop using Windows PowerShell 5.1.

The host computer must have the following:

* Windows PowerShell 5.1
* An internet connection
* Minimum 16GB of Ram
* Minimum 100GB free disk space

*This module and configurations have NOT been tested running from PowerShell Core or PowerShell 7.*

### Note for VMware Users

This project is designed to work with Hyper-V.
If you are going to build a Host VM of Server 2016 or Windows 10, In the general settings for your VM, you must change the OS type to Hyper-V(Unsupported) or the Host Hyper-V will not work!

## Setup

The first time you use this module, you will need to configure the local machine or host.

Open an elevated PowerShell session and run:

```powershell
Setup-Host
```

This will install and configure the Lability module and install the Hyper-V feature if it is missing.
By default, all AutoLab files will be stored under C:\AutoLab, which the setup process will create.
If you prefer to use a different drive, you can specify it during setup.

```powershell
Setup-Host -DestinationPath D:\AutoLab
```

You will be prompted to reboot, which you should do especially if setup had to add Hyper-V.

## Creating a Lab

Lab information is stored under the AutoLab Configurations folder, which is C:\AutoLab\Configurations by default.
Open an elevated PowerShell prompt and change location to the desired configuration folder.
View the `Instructions.md` and/or readme files in the folder to learn more about the configuration.

The first time you setup a lab, Lability will download evaluation versions of required operating systems in ISO format.
This may take some time depending on your Internet bandwidth.
The downloads only happen when the required ISO is not found.
When you wipe and rebuild a lab it won't download files a second time.

Once the lab is created you can use the module commands for managing it.
Or you can manage individual virtual machines using the Hyper-V manager or cmdlets.

*It is assumed that you will only have one lab configuration created at a time.*

### Manual Setup

Most, if not all, configurations should follow the same manual process.
Run each command after the previous one has completed.

* `Setup-Lab`
* `Run-Lab`
* `Enable-Internet`

To verify that all virtual machines are properly configured you can run `Validate-Lab`.
This will invoke a set of tests and loop until everything passes.
Due to the nature of DSC and complexity of some configurations this could take 60-90 minutes.
You can use `Ctrl+C` to break out of the testing loop at any time.
You can manually run the test one time to see the current state of the configuration.

```powershell
Invoke-Pester VMValidate.test.ps1
```

This can be useful for troubleshooting.

### Unattended Setup

As an alternative, you can setup a lab environment with minimal prompting.

```powershell
Unattend-Lab
```

Assuming you don't need to install a newer version of nuget, you can leave the setup alone.
It will run all of the manual steps for you.

### Stopping a Lab

To stop the lab VM's, change to the configuration folder in an elevated Windows PowerShell session and run:

```powershell
Shutdown-Lab
```

You can also use the Hyper-V manager or cmdlets to shut down virtual machines.
If your lab contains a domain controller such as DOM1 or DC1, that should be the last virtual machine to shut down.

### Starting a Lab

The setup process will leave the virtual machines running.
If you have stopped the lab and need to start it, change to the configuration folder in an elevated Windows PowerShell session and run:

```powershell
Run-Lab
```

You can also use the Hyper-V manager or cmdlets to start virtual machines.
If your lab contains a domain controller such as DOM1 or DC1, that should be the first virtual machine to start up.

### Lab Checkpoints

You can snapshot the entire lab very easily.
Change to the configuration folder in an elevated Windows PowerShell session and run:

```powershell
Snapshot-Lab
```

To quickly rebuild the labs from the checkpoint, run:

```powershell
Refresh-Lab
```

### To Remove a Lab

To destroy the lab completely, change to the configuration folder in an elevated Windows PowerShell session and run:

```powershell
Wipe-Lab
```

This will remove the virtual machines and DSC configuration files.
If you intend to rebuild the lab or another configuration, you can keep the LabNat virtual switch.

## Updating

As this module is updated over time, new configurations may be added, or bugs fixed in existing configurations.
There may also be new Lability updates.
Use PowerShell to check for new versions:

```powershell
Find-Module PSAutoLab
```

And update:

```powershell
Update-Module PSAutoLab
```

If you update, it is recommended that you update the computer running AutoLab.

```powershell
Refresh-Host
```

This will update Lability if required and copy all new configuration files to your AutoLab\Configurations folder.
It will NOT delete any files.

## Troubleshooting

The commands and configurations in this module are not foolproof.
During testing a lab configuration will run quickly and without error on one Windows 10 desktop but fail or take much longer on a different Windows 10 desktop.
Most setups should be complete in under an hour.
If validation is failing, manually run the validation test in the configuration folder.

```powershell
Invoke-Pester VMValidate.test.ps1
```

Take note of which virtual machines are generating errors.
Verify the virtual machine is running in Hyper-V.
On occasion for reasons still undetermined, sometimes a virtual machine will shutdown and not reboot.
This often happens with the client nodes of the lab configuration.
Verify that all virtual machines are running and manually start those that have stopped using the Hyper-V manager or cmdlets.

Sometimes even if the virtual machine is running, manually shutting it down and restarting it can resolve the problem.
Remember to wait at least 5 minutes before manually running the validation test again when restarting any virtual machine.

As a last resort, manually break out of any testing loop, wipe the lab and start all-over.

If you *still* are having problems, wipe the lab and try a different configuration.
This will help determine if the problem is with the configuration or a larger compatibility problem.

At this point, you can open an issue in this repository.
Open an elevated PowerShell prompt and run Get-PSAutoLabSetting which will provide useful information.
Copy and paste the results into a new issue along with any error messages you are seeing.

## Known Issues

Due to what is probably a bug in the current implementation of Desired State Configuration in Windows, if you have multiple versions of the same resource, a previous version might be used instead of the required on.
You might especially see this with the xNetworking module and the xIPAddress resource.
If you have any version older than 5.7.0.0 you might encounter problems.
Run this command to see what you have installed:

```powershell
PS C:\> Get-DSCResource xIPAddress
```

If you have older versions of the module, uninstall them if you can.

```powershell
PS C:\> Uninstall-Module xNetworking -RequiredVersion 3.0.0.0
```

It is recommended that you restart your PowerShell session and try the lab setup again.

## Acknowledgments

This module is a continuation of the work done by Jason Helmick and Melissa (Missy) Januszko, whose efforts are greatly appreciated.
Beginning with v4.0.0, this module is unrelated to any projects Jason may be developing under similar names.

## Road Map

These are some of the items that need to be addressed in future updates:

* This project will need better help and documentation
* Single Windows Server 2019 configuration
* While Lability currently is for Windows only, it would be nice to deploy a Linux VM
* Integrate the [PostSetup](.\Configurations\PowerShellLab\PostSetup\README.md) tools from the PowerShellLab configuration

Last Updated 2019-09-09 20:12:48Z UTC
