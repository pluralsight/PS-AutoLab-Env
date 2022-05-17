# Updating the PSAutolab Module

This module and its dependencies will be installed and updated from the PowerShell Gallery. It is strongly recommended that you __do not__ upgrade  the module if you have configured labs and virtual machines. If AutoLab is in use now, you can wait until you are finished with the lab configuration. Otherwise, use the `Wipe-Lab` command in any configuration folder that has MOF files with virtual machines.

__Note:__ The terms `AutoLab` and `PSAutoLab` are used interchangeably. PSAutoLab is technically the PowerShell module that manages your AutoLab configuration.

You should be able to run

```powershell
Update-Module PSAutolab
```

## Updating Troubleshooting

However, there is the potential for issues with required Lability module. You can always try this:

```powershell
Update-Module Lability
Update-Module PSAutolab
```

In certain situations, the Lability module may encounter a security validation bug between versions. You can try this sequence of commands.

```powershell
Install-Module Lability -SkipPublisherCheck -force
Update-Module PSAutolab
```

If you *still* have issues, the best course of action is to uninstall the modules and re-install.

```powershell
get-module psautolab -ListAvailable | uninstall-module
get-module lability -ListAvailable | uninstall-module
```

You might need to repeat this process until this command shows no modules.

```powershell
get-module lability,PSAutoLab -ListAvailable
```

With a clean slate run:

```powershell
Install-Module PSAutolab -SkipPublisherCheck -Force
```

You __do not__ need to run `Setup-Host`. But you should run `Refresh-Host` to copy updated lab configurations to your Autolab setup.

## Disk Image Update

If you have been using PSAutolab for awhile, are updating it and plan to continue using it, you might want to refresh the virtual disk images. An update to the PSAutolab module might also include a reference to a new version of the Lability module. This module is responsible for downloading the latest ISO images and creating the master virtual hard disks.

You should only refresh disk images if __you have no configured virtual machines__.

```powershell
Get-childitem C:\autolab\VMVirtualHardDisks
```

If this directory is empty, then you can proceed.

```powershell
Get-ChildItem D:\Autolab\MasterVirtualHardDisks\ | Remove-Item
```

The next time you build a lab, the master disk image will be recreated.

## ISO Management

Likewise, you might want to refresh the ISO images found in `C:\Autolab\ISOs`. You can delete any or all ISO images. The latest version of a required ISO will be downloaded the next time you build a lab.
