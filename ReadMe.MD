# PS-AutoLab-Env

This project serves as a set of "wrapper" commands that utilize the [Lability])https://github.com/VirtualEngine/Lability) module which is a terrific tool for creating a lab environment. The downside is that it is a difficult module for less experience PowerShell users. If you feel sufficiently skilled, you can skip using this project and use the Lability module on your own.

_*This project is under new ownership and updates are in progress. Please bear with us.*_

# Final Version (maybe)

This repo and version of AutoLab is final. The current version (3.1.0) works as described under the original releases of Win10 and Server 2016.  Due to the major update versions from Microsoft and changes to Hyper-V over the past year, you may have issues getting this to work as described. Check the “Issues” list for possible solutions.

This is under MIT License - meaning you can copy and use as your own, modify, borrow, steal - whatever you want. The code is yours.

# PowerShell Automated Lab Environment

This is an automated lab environment build tool to support authors, trainers, educators and students in designing and building a virtual lab environment.

The configurations and control scripts for the Hyper-V virtual machine's are written in Microsoft PowerShell DSC and deployed using [VirtualEngine Lability](https://github.com/VirtualEngine/Lability). This tool will completely build a lab environment from scratch, however if you want to build your own environment and have the VMs configured for you, see the section on [StandAlone](./Standalone/README.md).

This tool is provided 'as is' with no warranties or guarantees.

# Versions

Final Release is v3.0.4

## Version 3.1.0

* **Download release [PS-AutoLab-Env v3.1.0](https://github.com/theJasonHelmick/PS-AutoLab-Env/releases/tag/v3.1.0)**

* Version 1.1.0 of the PSAutolab module with -IgnorePendingReboot parameter for Unattend-lab and Setup-Lab.
* **Deprecation announcement - see top readme.md**

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

If you are going to build a Host VM of Server 2016 or Windows 10, In the general settings for your VM, you must change the OS
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
5. Change to the extracted folder `PS-AutoLab-Env`.
6. Run `.\ [Setup-Host.ps1](./Setup-Host.ps1)`

* Note: The default installation folder is C:\AutoLab. You can change this if desired.
* Note: .\Unattend-LabSetup runs setup-lab, Run-Lab, and Validate-Lab all together for faster processing

7. Change to the configuration folder under the installation folder (C:\AutoLab) and choose a configuration i.e. c:\AutoLab\Configuration\<Your Config folder>
8. Check the Instructions.MD (Get-Content .\Instructions.MD)

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

For support, see issues list on this repo.

# Current and Future Development

None. Check back for the link to the new repo and project.
