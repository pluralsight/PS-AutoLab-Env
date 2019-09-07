# Lab definition

This lab builds the following:

* 1 Windows Server 2016 domain controller with users, groups and OU's - GUI
* 1 DHCP server on the DOM1
* 2 Domain joined servers (SRV1 and SRV2) running Windows Server 2016 Core
* 1 workgroup based server (SRV3) running Windows Server 2019 Core
* 1 Domain joined Windows 10 Client with RSAT tools installed

## To get started

To run the full lab setup, which includes Setup-Lab, Run-Lab, Enable-Internet, and Validate-Lab. You should run all commands from the directory with the MOF and psd1 files.

```powershell
PS> Unattend-Lab
```

To run the commands individually to setup the lab environment:

Run the following for initial setup:

```powershell
PS> Setup-Lab 
```

To start the Lab, and apply configurations the first time:

```powershell
PS> Run-Lab
```

To enable Internet access for the VM's, run:

```powershell
PS> Enable-Internet
```

To validate when configurations have converged:

```powershell
PS> Validate-Lab
```

Or you can run the Pester test directly

```powershell
PS> Invoke-Pester vmvalidate.test.ps1
```

## To Stop and snapshot the lab

To stop the lab VM's:

```powershell
PS> Shutdown-lab
```

To checkpoint the VM's:

```powershell
PS> Snapshot-Lab
```

To quickly rebuild the labs from the checkpoint, run:

```powershell
PS> Refresh-Lab
```

## To remove a lab

To destroy the lab to build again:

```powershell
PS> Wipe-Lab
```
