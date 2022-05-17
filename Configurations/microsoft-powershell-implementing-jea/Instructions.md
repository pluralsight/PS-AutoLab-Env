# Lab Definition

This lab builds the following:

    Computername : DC1
    Description  : Windows Server 2016 Standard Core 64bit English Evaluation
    Role         : {DC, DHCP, ADCS}
    IPAddress    : 192.168.3.10
    MemoryGB     : 2

    Computername : S1
    Description  : Windows Server 2016 Standard Core 64bit English Evaluation
    Role         : {DomainJoin, Web}
    IPAddress    : 192.168.3.50
    MemoryGB     : 1

    Computername : Cli1
    Description  : Windows 10 64bit Enterprise 2109/21H2 English Evaluation
    Role         : {domainJoin, RSAT, RDP}
    IPAddress    : 192.168.3.100
    MemoryGB     : 2

This configuration no longer includes the NanoServer image since it is now deprecated.

## To Get Started

    To run the full lab setup, which includes Setup-Lab, Run-Lab, Enable-Internet, and Validate-Lab:
    PS> Unattend-Lab

    To run the commands individually to setup the lab environment:

    Run the following for initial setup:
    PS> Setup-Lab

    To start the Lsb, and apply configurations the first time:
    PS> Run-Lab

    To enable Internet access for the VMs, run:
    PS> Enable-Internet

    To validate when configurations have converged:
    PS> Validate-Lab

## To Stop and Snapshot the Lab

    To stop the lab VMs:
    PS> Shutdown-lab

    To checkpoint the VMs:
    PS> Snapshot-Lab

    To quickly rebuild the labs from the checkpoint, run:
    PS> Refresh-Lab

## To Patch a Lab

    If you want to make sure the virtual machines have the latest updates from Microsoft, you can run this command:

    PS> Update-Lab

    Because this may take some time to run, you can also run it as a background job.

    PS> Update-Lab -asjob

## To Remove a Lab

    To destroy the lab to build again:
    PS> Wipe-Lab

    You will be prompted for each virtual machine. Or you can force the removal and suppress the prompts:

    PS> Wipe-Lab -force

## Troubleshooting

    If you encounter errors like `Invalid MOF definition for node 'DC1': Exception calling "ValidateInstanceText" with "1" argument(s): "Undefined
    property IsSingleInstance` you might have an older version of a DSCResource module installed.

    Run `Get-Module xdhcpserver -list` and remove anything older than version 3.0.0.

    uninstall-module xdhcpserver -RequiredVersion 2.0.0.0
