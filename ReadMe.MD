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



    
