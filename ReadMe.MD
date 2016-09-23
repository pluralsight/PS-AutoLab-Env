# Pluralsight PowerShell Automated Lab Environment
This is an automated lab environment build tool to support Authors and students in designing and building a virtual lab environment to support courses.  
The configurations for the VM are written in Microsoft DSC and deployed using [VirtualEngine Lability](https://github.com/VirtualEngine/Lability)
This tool will completely build a lab environment from scratch, however if you want to build your own
environment and have the VMs configured for you, see the section on StandAlone.

## requirements
The host computer must have the following:
* WMF 5 (Windows Management Framework 5)
* An internet connection

## This Lab tool currently supports running on a host:
* Windows Server 2012 R2
* Windows Server 2016
* Windows 10 client

## The lab tool will build virtual environments with the following OS's:
* Windows Server 2012 R2
* Windows Server 2016
* Windows 8.1 clients
* Windows 10 clients

# Current Instructions 
1. Download the ZIP of this repository to the Host computer.
2. Extract the zip of PS-AutoLab-Env to your c:\ drive (C:\PS-AutoLab-Env)
3. Open Powershell with administrative privileges
4. Change to folder c:\PS-Auto-Lab-Env
5. Run PS> .\Setup-Host.ps1
6. Change to the configuration folder and choose a configuration i.e. c:\Lability\Configuration\<Your Config folder>
7. Check the Readme.md to find a decscription of what this config will do.
8. In Powershell, run the script PS> .\Setup-Lab.ps1
        * Note - the first time you run this, it will download all required files including ISO and DSCResources.
        * Note - this may require several hours depending on your Internet connection
        * Note - This only happens the first time -- you will be able to build and wipe the 
                Lab quickly in future.

# Other scripts you will need:
You will receive reminders and instructions when to run these when you start the .\Setup-Lab script.
1. .\Run-Lab.ps1 * Starts the Lab environment
2. .\Snapshot-Lab * Snapshot the lab environment for easy and fast rebuilding
3. .\Refresh-lab.ps1 * Refresh the lab from a previose Snapshot
4. .\Wipe-Lab.ps1 * Wipe the lab and VM's from you system
5. .\Enable-Internet * Enable Internet to the VM's 

# StandAlone
In the Standalone folder, a variety of DSC configurations have been included for authors and students
that wish to build their environments on their own VM Infrastructure.
The DSC Configurations may be applied to your own VMs.
You will need to deploy the configs and DSC resources yourself.

# Known Issues
Excepted convergence of all the configurations for the first time run is 60 minutes.
The DC may require an addiitonal reboot to complete its configuration. Tracking this issue now.
If after 30 minutes, you still do not see users (ADUC), then reboot the system or run the following:
Start-DscConfiguration -UseExisting

# Current and Future Development
These are things currently being worked on and/or in testing.

1. Additional Role configurations including:
        * DHCP (current)
        * ADCS (plus certificattes and autoenroll) (current)
        * Web servers and Websites (current)
        * Exchange (future)
        * SQL (future)
2. Bootstrapping and automatically installing RSAT tool into Windows 10 (current)
3. Bootstrapping and automatically installing PowerShell 6 (future)
