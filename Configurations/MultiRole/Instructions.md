# Lab Definition

This is an updated and revised configuration of the now retired POC-Multirole.
If you were instructed to use that configuration, this one should work for you.

The lab builds the following:

* 1 DC (DC1)
* 1 Server (S1)
* 1 Nano (N1)
* 1 Client with RSAT (Cli1)

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
