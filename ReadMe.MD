
# PowerShell Automated Lab Environment
This is an automated lab environment build tool to support authors, trainers, educators and students in designing and building a virtual lab environment.   

The configurations and control scripts for the Hyper-V virtual machine's are written in Microsoft PowerShell DSC and deployed using [VirtualEngine Lability](https://github.com/VirtualEngine/Lability). This tool will completely build a lab environment from scratch, however if you want to build your own environment and have the VMs configured for you, see the section on [StandAlone](./Standalone/README.md).

This tool is provided 'as is' with no warranties or guarantees.

# Versions
Current Release is v3.0.2

## Unreleased (Dev Branch)
New release under development
* Updated to Lability version 0.11.0

## Version 3.0.2
* **Download release [PS-AutoLab-Env v3.0.2](https://github.com/theJasonHelmick/PS-AutoLab-Env/releases/tag/v3.0.2)**

* Added New course config for Michael Bender

## All Releases
* Download any release [All Releases](https://github.com/theJasonHelmick/PS-AutoLab-Env/releases)

# Requirements
The host computer must have the following:
* WMF 5 (Windows Management Framework 5)
* An internet connection
* Minimum 16GB of Ram
* Minimum 100GB free disk space

## This Lab tool currently supports running on a host:
* Windows Server 2016 
* Windows 10 client with SLAT 

## Note for VMware users
If you are going to build a Host VM of Server 2016 or Windows 10, In the gerenal settings for your VM, you must change the OS 
type to Hyper-V(Unsupported) or the Host hyper-v will not work!

## The lab tool will build virtual environments with the following OS's:
* Windows Server 2012 R2
* Windows Server 2016
* Windows 8.1 clients
* Windows 10 clients

# Instructions 
**Video of instructions here: [Video Instructions](https://www.youtube.com/watch?v=fIXHvbgxEDk&feature=youtu.be)**

1. Download the ZIP of this repository to the Host computer.
2. Extract the zip of PS-AutoLab-Env to your C:\ drive (C:\PS-AutoLab-Env)
3. Open PowerShell with administrative privileges (Run As Administrator)
4. Set the execution policy to Bypass (PS> Set-ExecutionPolicy ByPass)
4. Change to the extracted folder `PS-AutoLab-Env`.
5. Run PS> .\ [Setup-Host.ps1](./Setup-Host.ps1)
* Note: The default installation folder is C:\AutoLab. You can change this if desired.
* Note: .\Unattend-LabSetup runs setup-lab, Run-Lab, and Validate-Lab all together for faster processing
6. Change to the configuration folder under the installation folder (C:\AutoLab) and choose a configuration i.e. c:\AutoLab\Configuration\<Your Config folder>
7. Check the Instructions.MD (Get-Content .\Instructions.MD)

_Note - The first time you run Setup-Lab, it will download all required files including ISOs and DSCResources.
This initial download may require several hours depending on your Internet connection but it only happens the first time.
You will be able to build and wipe the Lab quickly in future._

## Instruction Contents
## To get started:

    To run the full lab setup, which includes Setup-Lab, Run-Lab, Enable-Internet, and Validate-Lab:
    PS> Unattend-Lab
    
    To run the commands individually to setup the lab environment:

    Run the following for initial setup:
    PS> Setup-Lab

    To start the Lab, and apply configurations the first time:
    PS> Run-Lab

    To enable Internet access for the VM's, run:
    PS> Enable-Internet

    To validate when configurations have converged:
    PS> Validate-Lab
   
## To Stop and snapshot the lab

    To stop the lab VM's:
    PS> Shutdown-lab

    To checkpoint the VM's:
    PS> Snapshot-Lab

    To quickly rebuild the labs from the checkpoint, run:
    PS> Refresh-Lab

## To remove a lab
    
    To destroy the lab to build again:
    PS> Wipe-Lab

# Standalone Configurations
In the Standalone folder, a variety of DSC configurations have been included for authors and students who wish to build their environments on their own VM Infrastructure. The DSC Configurations may be applied to your own VMs. You will need to deploy the configs and DSC resources yourself.

# Known Issues
None

_NOTE - Configuration convergence takes about 30 - 60 minutes and several reboots - do not turn off machines until they finish. It is advised that you run .\Snapshot-lab when complete for easy refreshing._

# Current and Future Development
These are things currently planned for development. Please help us and contribute your own configs or pick something from the list marked (Future)

1. Additional Role configurations including:
   * Windows Server 2016 release version (completed)
   * ADCS (plus certificates and autoenrollment) (completed)
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

*