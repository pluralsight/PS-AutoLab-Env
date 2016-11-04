
# PowerShell Automated Lab Environment
This is an automated lab environment build tool to support authors, trainers, educators and students in designing and building a virtual lab environment.   

The configurations and control scripts for the Hyper-V virtual machine's are written in Microsoft PowerShell DSC and deployed using [VirtualEngine Lability](https://github.com/VirtualEngine/Lability). This tool will completely build a lab environment from scratch, however if you want to build your own environment and have the VMs configured for you, see the section on [StandAlone](./Standalone/README.md).

This tool is provided 'as is' with no warrenties or guarantees.

# Versions
Current Release is v2.1.0

## Unreleased (master)
Master IS NOT currently in sync with latest release.
* Added Lability 0.10.1 support
* Removed 2016 Server manual media fix
* Added Win10 RSAT config
* Added Pester test (Validate-Lab.ps1) to notify when configurations are converged.
* Added Nano configuration
* deprecated older POC configs
* Adding one master Muli-Role POC Example that will be supported
* Added new course config
* Host DSCResources no longer are specified in Setup-Host.ps1. They are now automatically read from the configuration data and installed as needed.


## v2.1.0
* Download release [PS-AutoLab-Env v2.1.0](https://github.com/theJasonHelmick/PS-AutoLab-Env/releases/tag/v2.1.0)
* Added Shutdown-Lab script to shutdown VM's
* Disabled secure boot on VM's for bug in Win 10 Anniversary edition as Host
* Added Pluralsight Author folder and config example (Course name by URL)
* Modified User list for AD
* Forcibly enable PowerShell Remoting for Win 10 Hosts

## All Releases
* Download any release [All Releases](https://github.com/theJasonHelmick/PS-AutoLab-Env/releases)

# Requirements
The host computer must have the following:
* WMF 5 (Windows Management Framework 5)
* An internet connection

## This Lab tool currently supports running on a host:
* Windows Server 2012 R2 (Not tested)
* Windows Server 2016 (Tested)
* Windows 10 client with SLAT (Tested)

## Note for VMware users
If you are going to build a Host VM of Server 2016 or Windows 10, In the gerenal settings for your VM, you must change the OS 
type to Hyper-V(Unsupported) or the Host hyper-v will not work!

## The lab tool will build virtual environments with the following OS's:
* Windows Server 2012 R2
* Windows Server 2016
* Windows 8.1 clients
* Windows 10 clients

# Instructions 
1. Download the ZIP of this repository to the Host computer.
2. Extract the folder PS-AutoLab-Env from the zip file.
3. Open PowerShell with administrative privileges.
4. Change to the extracted folder `PS-AutoLab-Env`.
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
* .\Validate-Lab _(Runs pester tests to notify you when Lab is converged)
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
These are things currently planned for development. Please help us and contribute your own configs or pick something from the list marked (Future)

1. Additional Role configurations including:
   * Windows Server 2016 release version (completed)
   * ADCS (plus certificates and autoenrollment) (current)
   * Web servers and web sites (future)
   * Exchange (future)
   * SQL (future)
   * Installing RSAT tool into Windows 10 (Completed) 
   * Installing PowerShell 6 (current)
   * Do you have suggestions? Add to Issues list
2. Nano support (Completed)
3. Linux (Ubuntu and CentOS) (Future)
4. Structural config changes
    * Moving to a single composite config for easier development and management (Future)
    * Adding Pester tests to all configurations (Completed)
5. Add custom media and Registration Keys (future) - (your own ISO with Key)
6. Add support for custom DSCResource Modules (future)

_Please make recommendations or fork this repo and share your own!!!_
