# Pluralsight PowerShell Automated Lab Environment
This is an automated lab environment build tool to support Authors and students in designing and building a virtual lab environment to support courses.  
The configurations for the VM are written in Microsoft DSC and deployed using [VirtualEngine Lability](https://github.com/VirtualEngine/Lability)
This tool will completely build a lab environment from scratch, however if you want to build your own
environment and have the VMs configured for you, see the section on StandAlone.


## This Lab tool currently supports running on a host:
* Windows Server 2012 R2
* Windows Server 2016
* Windows 10 client

## The lab tool will build virtual environments using:
* Windows Server 2012 R2
* Windows Server 2016
* Windows 8.1 clients
* Windows 10 clients

## Primary (1st defined) Virtual environments will include:
* DC - Domain Controller with ADCS and DHCP, firewall and GPO settings, certificates, and other domain essentials.
    * Domain name - **Company.Pri**
    * Network - **192.168.3.0/24**
    * Administrator password - **P@ssw0rd**
* Client - Windows 10 client VM
* 2 Additional domain-joined servers


# Current Instructions (Need revision and sample commands)
1. Extract the zip of PS-Auto-Lab to your c: drive
2. Open Powershell with administrative privileges
3. Change to folder c:\PS-Auto-Lab-Env
4. Run PS> .\Setup-Host.ps1
5. Change to the configuration folder and choose a configuration i.e. c:\Lability\Jason-TestConfig
6. In Powershell, run the script PS> .\Setup-Lab.ps1
        * Note - the first time you run this, it will download all required files including ISO and DSCResources.
        * Note - this may require several hours depending on your Internet connection
        * Note - This only happens the first time -- you will be able to build and wipe the 
                Lab within a minute or so in the future.
7. Optional - if you want the vms to have internet access, run PS> .\Setup-Internet.ps1
8. Optional - To wipe the lab env. PS> .\Wipe-Lab.ps1, then rebuild with Setup-Lab.ps1

# StandAlone
In the Standalone folder, a variety of DSC configurations have been included for authors and students
that wish to build their environments on VM Infrastructure, (Like on VMWare) but still wish the VMs configured for
a course. The DSC Configuration may be applied to your own VMs.

# Special notes and issues
When the lab build is complete, I do not start the VMs automatically. I can, or create an option to do so.
One reason to consider starting them is that the DSC configs (to configure the servers) don't execute
until the first time they are started - causing a delay for the installations to finish. This is an open discussion topic.
  
#issues
* Do we really need folder under Configuration.....?? So.. if we use the cmdlets instead of stupid custom scripts... we dont need this.
* We would need a naming convention -- COURSE URL should be Psd1 name.
* We would need a Prefix convention

* the lab cmdlets are so easy -- let use those -- please....
    * Start-LabConfiguration
    * Start-Lab -ConfigurationName X
    * Stop-Lab -Configuration X
    * Remove-LAbConfiguration -Configuration X
    etc -- only a few more -- can provide instructions.

* It is possible to Preload a download of requirements before the lab build....we can teach this if we stop with the shitty scripts.

* What should the folder structure naming be?

* The Naming of configs should be very clear - with out the need of a read.me

* Can offer a prebuild of downloads for a lab before config if we teach the cmdlets.

* Can offer Bootstrap option that load things like PowerShell V6 , RSAT tools for Win10 and other things.

* Can offer Linux versions as well -- although not currently supported -- have a way around them

* 