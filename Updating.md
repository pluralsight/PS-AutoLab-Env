# Updating From PSAutoLab v3.x

At this point in time, this information should be irrelevant but will be retained just in case.

If you were running older versions of PSAutoLab, most likely v3.x, you might have encountered problems. It is hoped that the updates to 4.x will resolve most if not all of those problems. The plan going forward is to pay closer attention to issues and update the module as needed. This will be easier now that the module is deployed through the PowerShell Gallery.

__Note:__ The terms `AutoLab` and `PSAutoLab` are used interchangeably. PSAutoLab is technically the PowerShell module that manages your AutoLab configuration.

## Before You Upgrade

The new module will be installed and updated from the PowerShell Gallery. To avoid conflicts, you should clean up the previous setup before installing the new version. The recommended procedure is to wipe everything and start fresh.

**All existing issues from the previous version have been closed as the previous code-base is deprecated.**

### Wipe Labs

If AutoLab is is in use now, you can wait until you are finished with the lab configuration. Otherwise, use the `Wipe-Lab` command in any configuration folder that has MOF files with virtual machines. On the last configuration you wipe, you can answer yes to remove the LabNet switch.

### Remove LabNet

If you didn't remove the NAT switch, you should manually remove it.

```powershell
Remove-VMSwitch LabNet
```

You might also run `Get-VMSwitch` to discover the actual name if it varies from this documentation.

To be on the safe side, you should remove the NAT network configuration if it still exists. If this command gives you a result:

```powershell
Get-NetNat LabNat
```

Then you can run:

```powershell
Remove-NetNat LabNat
```

### Remove Module

The previous version was manually copied to your module folder, `C:\Program Files\WindowsPowerShell\Modules`. You can always find the install location with a command like this:

```powershell
Get-Module PSAutoLab -ListAvailable | Select-Object Path
```

### Delete AutoLab Folder

Delete your AutoLab folder and all sub-folders which should be `C:\AutoLab` if you accepted the defaults during installation. This will delete all of the ISO files which means you'll need to re-download them when you build a new configuration. But that is OK because the current version of the module contains the correct links to all the relevant evaluation ISO files.

## Update and Reboot

It is not necessary to remove Hyper-V. But it is recommended that you install all pending Windows updates and reboot your computer.

## Verify

After reboot, open an elevated Windows PowerShell prompt. Type this command to verify you have removed the previous module:

```powershell
Get-Module PSAutoLab -listavailable
```

## Install

Assuming you are clean, you can now install the new version.

```powershell
Install-Module PSAutoLab -repository PSGallery
```

Next, setup your local host:

```powershell
Setup-Host
```

If Hyper-V had to be installed, then you should definitely reboot.

## Setup a Configuration

From this point, you should be set with the new version. Read the about help topic to learn more.

```powershell
help about_PSAutoLab
```

Or refer to the GitHub repository [README](README.md) file.

Last updated 2020-12-01 22:17:55Z
