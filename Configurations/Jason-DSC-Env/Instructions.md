# Lab Definition

This lab builds the following:

* 1 DC with users, groups and OU's - GUI
* 1 DHCP server on the DC
* 2 Domain joined servers (s1 and s2)
* 1 Domain joined Windows 10 Client with RSAT tools

## To get started

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
