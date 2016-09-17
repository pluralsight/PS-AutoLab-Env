# Pluralsight PowerShell Automated Lab Environment
This is an automated lab envroment build tool to support Authors and students in desinging and building a virutal lab environement to support courses.  
The configurations for the VM are writting in Microsoft DSC and deployed using [VirtualEngine Lability](https://github.com/VirtualEngine/Lability)


## This Lab tool currently supports running on a host:
* Windows Server 2012 R2
* Windows Server 2016
* Windows 10 client

## The lab tool will build virtual environements using:
* Windows Server 2012 R2
* Windows Server 2016
* Windows 8.1 clients
* Windows 10 clients

## Primary (1st defined) Virtual enviroments will include:
* DC - Domain Control with ADCS and DHCP, firewall and GPO settings, certificates, and other domain essentials.
    * Domain name - **Company.Pri**
    * Network - **192.168.3.0/24**
    * Administrators password - **P@ssw0rd**
* Client - Windows 10 client VM
* 2 Additional domain joined servers


# Current Instructions (Need revision and sameple commands)
1. Extract the zip of PS-Auto-Lab to your c: drive
2. Open Powershell with administrative privledges
3. Change to folder c:\PS-Auto-Lab-Env
4. Run PS> .\Setup-Host.ps1
5. Change to the configuration folder and choose a configuration i.e. c:\Lability\Jason-TestConfig
6. In Powershell, run the script PS> .\Setup-Lab.ps1
        * Note - the first time you run this, it will download all required files including ISO and DSCResources.
        * Note - this may require several hours depending on your Internet connection
        * Note - This only happens the first time -- you will be able to build and wipe the 
                Lab within a minute or so in the future.
7. Optional - if you want the vm's to have internet access, run PS> .\Setup-Internet.ps1
8. Optional - To wipe the lab env. PS> .\Wipe-Lab.ps1, then rebuild with Setup-Lab.ps1


# Special notes and issues
When the lab build is complete, I do not start the VM's automatically. I can, or create an option to do so.
One reason to consider starting them is that the DSC configs (to configure the servers) doesn;t exeucte
Until the first time they are start - causing a delay for the installations to finish. This is an open discussion topic
  
