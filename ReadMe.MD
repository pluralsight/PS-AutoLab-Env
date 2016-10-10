
# Pluralsight PowerShell Automated Lab Environment
This is an automated lab environment build tool to support Authors and students in designing and building a virtual lab environment to support courses.  

The configurations for the VM are written in Microsoft PowerShell DSC and deployed using [VirtualEngine Lability](https://github.com/VirtualEngine/Lability). This tool will completely build a lab environment from scratch, however if you want to build your own environment and have the VMs configured for you, see the section on [StandAlone](./Standalone/README.md).

# Versions
Current Release is v2.0.0

## Unreleased
* Added Shutdown-Lab script to shutdown VM's
* Disabled secure boot on VM's for bug in Win 10 Anniversary edition as Host

## v2.0.0
* Download release [PS-AutoLab-Env v2.0.0](https://github.com/theJasonHelmick/PS-AutoLab-Env/releases/tag/v2.0.0)
* Added support for Server 2016 RTM 
* Removed support of Server 2016 TP5 (Breaking change)
* Modified configuration data (.psd1) for new media types

## v1.0.0
* Download release [PS-AutoLab-Env v1.0.0](https://github.com/theJasonHelmick/PS-AutoLab-Env/releases/tag/v1.0.0)
* This is the initial release with several POC configurations for 2016TP5 and Windows 10

# Requirements
The host computer must have the following:
* WMF 5 (Windows Management Framework 5)
* An internet connection

## This Lab tool currently supports running on a host:
* Windows Server 2012 R2 (Not tested)
* Windows Server 2016 (Tested)
* Windows 10 client with SLAT (Tested)

## The lab tool will build virtual environments with the following OS's:
* Windows Server 2012 R2
* Windows Server 2016
* Windows 8.1 clients
* Windows 10 clients

# Instructions 
1. Download the ZIP of this repository to the Host computer.
2. Extract the zip of PS-AutoLab-Env to your C:\ drive (C:\PS-AutoLab-Env)
3. Open PowerShell with administrative privileges
4. Change to folder C:\PS-Auto-Lab-Env
5. Run PS> .\ [Setup-Host.ps1](./Setup-Host.ps1)
6. Change to the configuration folder and choose a configuration i.e. c:\Lability\Configuration\<Your Config folder>
7. Check the Readme.md to find a description of what this config will do.
8. In PowerShell, run the script PS> .\Setup-Lab.ps1

_Note - The first time you run Setup-Lab.ps1, it will download all required files including ISOs and DSCResources.
This initial download may require several hours depending on your Internet connection but it only happens the first time.
You will be able to build and wipe the Lab quickly in future._

## Other scripts you will need:
You will receive reminders and instructions when to run these when you start the .\Setup-Lab script.

* .\Run-Lab.ps1 _(Starts the Lab environment)_
* .\Shutdown-Lab.ps1 _(Stops the lab VM's)_
* .\Snapshot-Lab _(Snapshot the lab environment for easy and fast rebuilding)_
* .\Refresh-Lab.ps1 _(Refresh the lab from a previous Snapshot)_
* .\Wipe-Lab.ps1 _(Wipe the lab and VM's from your system)_
* .\Enable-Internet _(Enable Internet to the VM's)_ 

# Standalone Configurations
In the Standalone folder, a variety of DSC configurations have been included for authors and students who wish to build their environments on their own VM Infrastructure. The DSC Configurations may be applied to your own VMs. You will need to deploy the configs and DSC resources yourself.

# Known Issues
Possible problem with the Setup-Lab script pausing after downloading .iso files. This is beinging investigated. 
If the script does not continue automatically after completing the downloads, press the return key once and it
will continue.

_NOTE - Configuration convergence takes about 30 minutes and several reboots - do not turn off machines until they finish. It is advised that you run .\Snapshot-lab when complete for easy refreshing._

# Current and Future Development
These are things currently being worked on and/or in testing.

1. Additional Role configurations including:
   * Windows Server 2016 release version (completed)
   * ADCS (plus certificates and autoenrollment) (current)
   * Web servers and web sites (future)
   * Exchange (future)
   * SQL (future)
   * Do you have suggestions? Add to Issues list
2. Bootstrapping and automatically installing RSAT tool into Windows 10 (current)
3. Bootstrapping and automatically installing PowerShell 6 (current)
4. Nano support (current)
5. Linux (Ubuntu and CentOS) (Future)

_Please make recommendations or fork this repo and share your own!!!_
