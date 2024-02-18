# Updating from Version 4 to Version 5

> *If you have never installed the PSAutoLab module before, you can disregard this document*.

This document outlines the changes and steps you should take when updating from version 4 to version 5 of the PSAutoLab module. This is a **major** update to the module. It is recommended that you finish and remove all lab configurations before installing this update. Run `Get-VM` to verify you have no lab VMs running.

## Changes

### Lability

Version 5.0 updates the Lability requirement to version 0.25.0. This is what allows downloading of ISO images. If you have older versions of the Lability module imported into your session with version 5.0, you might see errors about missing files or images. Re-open your PowerShell session and re-import the PSAutoLab module.

### Pester

Validation Pester tests have finally been revised to support Pester v5.x. This is a breaking change. If you have any custom Pester tests, you will need to update them to work with Pester v5.x. The Pester dependency has been updated to the most current version.

### Windows Server 2012R2

Lab configurations for Windows Server 2012R2 have been archived and are no longer supported. This is a breaking change. If you attempt to run one of these lab configuration with version 5.0, the lab will fail to build. It is recommended that you manually delete the Windows Server 2012 R2 folders.

## Updating the Module

The module is available from the PowerShell Gallery. You can update the module from the PowerShell console. This module still only works in Windows PowerShell.

```shell
Update-Module -Name PSAutoLab -Force
```

Restart your Windows PowerShell session and import the module.

```shell
Import-Module PSAutoLab
```

You should have at least version `5.0.0`.

```shell
PS C:\> Get-Module PSAutoLab

ModuleType Version    Name                     ExportedCommands
---------- -------    ----                     ----------------
Script     5.0.0      PSAutoLab                {Enable-Internet, Get-LabSnaps...
```

## Update the Host

Version 5.0 uses updated ISO images and lab configurations. You should take the following steps to update your host **after importing the updated module**.

```shell
Import-Module PSAutoLab -Force
```

First, in your Windows PowerShell 5.1 session run `Refresh-Host` to update the lab configurations and install updates to Lability or Pester as needed.

```shell
Refresh-Host
```

Next, change location to your AutoLab folder, and delete all ISO images.

```shell
PS C:\ cd c:\AutoLab
PS C:\AutoLab> Get-ChildItem .\ISOs | Remove-Item
```
You will download new ISO images as needed when you build a lab.

Do the same thing with the master virtual disks. Make sure you have no running VMs that might be using them.

```shell
PS C:\AutoLab> Get-ChildItem .\MasterVirtualHardDisks | Remove-Item
```

These images will be rebuilt as needed when you build a lab.

Finally, if you don't have any running lab configurations, the VMVirtualHardDisks folder should be empty.

Since Windows Server 2012 R2 labs have been removed, you might want to delete the lab configurations.

```shell
PS C:\AutoLab> Get-ChildItem .\Configurations\*2012* | Remove-Item -Recurse -Force
```

At this point you should be able to build a new lab configuration. Be aware that the first time you build a lab, it might take longer than usual as it downloads new ISO images and builds new master virtual disks.
