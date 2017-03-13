# Lab definition

This lab is specifically designed for the Implementing Windows Server 2016 DHCP from Pluralsight.com. It will provide a fully-function AD environment using company.pri for a domain, and it builds the following servers:

* 1 DC
* 1 Server (s1)
* 2 Clients with RSAT (Cli1,Cli2)

*## To get started:

    To run the full lab setup, which includes Setup-Lab, Run-Lab, Enable-Internet, and Validate-Lab:
    PS> Unattend-Lab
    
    To run the commands individually to setup the lab environment:

    Run the following for initial setup:
    PS> Setup-Lab

    To start the LAb, and apply configurations the first time:
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
