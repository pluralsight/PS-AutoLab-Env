# Lab Definition

This lab builds the following:

    Computername : Win10Ent
    Description  : Windows 10 64bit Enterprise 2009 English Evaluation (20H2)
    Role         : {RSAT, RDP}
    IPAddress    : 192.168.3.101
    MemoryGB     : 2

It will also create a local user account with a password of `P@ssw0rd` using same name as the person running the configuration. In other words, it will use the value of `$env:username`.

## To get started

    To run the full lab setup, which includes Setup-Lab, Run-Lab, Enable-Internet, and Validate-Lab:
    PS> Unattend-Lab

    To run the commands individually to setup the lab environment:

    Run the following for initial setup:
    PS> Setup-Lab

    To start the Lab, and apply configurations the first time:
    PS> Run-Lab

    To enable Internet access for the VM, run:
    PS> Enable-Internet

    To validate when configurations have converged:
    PS> Validate-Lab

    Once validation is complete you should connect to the VM, logon as the non-administrator account and let Windows 10 finish setting up. Then restart the computer applying any pending updates. After this you can, and should, snapshot the VM.

## To Stop and snapshot the lab

    To stop the lab VM:
    PS> Shutdown-lab

    To checkpoint the VM:
    PS> Snapshot-Lab

    To quickly rebuild the labs from the checkpoint, run:
    PS> Refresh-Lab

## To Patch a lab

    If you want to make sure the virtual machines have the latest updates from Microsoft, you can run this command:

    PS> Update-Lab

    Because this may take some time to run, you can also run it as a background job.

    PS> Update-Lab -asjob

## To remove a lab

    To destroy the lab to build again:
    PS> Wipe-Lab

    You will be prompted for each virtual machine. Or you can force the removal and suppress the prompts:

    PS> Wipe-Lab -force
