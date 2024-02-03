# Lab Definition

This is an updated and revised configuration of the now retired POC-MultiRole.
If you were instructed to use that configuration, this one should work for you.
The NanoServer images has been removed from this configuration because it is no longer a valid platform.

The lab builds the following:

    Computername : DC1
    Description  : Windows Server 2019 Standard 64bit English Evaluation (*GUI*)
    Role         : {DC, DHCP, ADCS,RDP}
    IPAddress    : 192.168.3.10
    MemoryGB     : 4

    Computername : S1
    Description  : Windows Server 2019 Standard 64bit English Evaluation (*GUI*)
    Role         : {DomainJoin, Web,RDP}
    IPAddress    : 192.168.3.50
    MemoryGB     : 2

    Computername : Cli1
    Description  :  Windows 10 64-bit Enterprise 2209/22H2 English Evaluation
    Role         : {domainJoin, RSAT, RDP}
    IPAddress    : 192.168.3.100
    MemoryGB     : 4

## To get started

    To run the full lab setup, which includes Setup-Lab, Run-Lab, Enable-Internet, and Validate-Lab:
    PS> Unattend-Lab

    To run the commands individually to setup the lab environment:

    Run the following for initial setup:
    PS> Setup-Lab

    To start the Lab, and apply configurations the first time:
    PS> Run-Lab

    To enable Internet access for the VMs, run:
    PS> Enable-Internet

    To validate when configurations have converged:
    PS> Validate-Lab

## To Stop and snapshot the lab

    To stop the lab VMs:
    PS> Shutdown-lab

    To checkpoint the VMs:
    PS> Snapshot-Lab

    To quickly rebuild the labs from the checkpoint, run:
    PS> Refresh-Lab

## To Patch a lab

    If you want to make sure the virtual machines have the latest updates from Microsoft, you can run this command:

    PS> Update-Lab

    Because this may take some time to run, you can also run it as a background job.

    PS> Update-Lab -AsJob

## To remove a lab

    To destroy the lab to build again:
    PS> Wipe-Lab

    You will be prompted for each virtual machine. Or you can force the removal and suppress the prompts:

    PS> Wipe-Lab -force

## Troubleshooting

If you encounter errors like `Invalid MOF definition for node 'DC1': Exception calling "ValidateInstanceText" with "1" argument(s): "Undefined
property IsSingleInstance` you might have an older version of a DSCResource module installed.

Run `Get-Module xdhcpserver -list` and remove anything older than version 3.0.0.

uninstall-module xdhcpserver -RequiredVersion 2.0.0.0
