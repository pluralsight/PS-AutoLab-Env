---
external help file: PSAutoLab-help.xml
Module Name: PSAutoLab
online version:
schema: 2.0.0
---

# Get-PSAutoLabSetting

## SYNOPSIS

Get host and module information related to the PSAutoLab module.

## SYNTAX

```yaml
Get-PSAutoLabSetting [<CommonParameters>]
```

## DESCRIPTION

If you need to report a problem with AutoLab, use this command to get relevant configuration and host information. Please include the output in your GitHub issue.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-PSAutoLabSetting

AutoLab                     : C:\Autolab
PSVersion                   : 5.1.19041.1
PSEdition                   : Desktop
OS                          : Microsoft Windows 10 Pro
FreeSpaceGB                 : 172.49
MemoryGB                    : 32
PctFreeMemory               : 44.66
Processor                   : Intel(R) Core(TM) i7-7700T CPU @ 2.90GHz
IsElevated                  : True
RemotingEnabled             : True
HyperV                      : 10.0.19041.1
PSAutolab                   : {4.10.0, 4.9.0}
Lability                    : {0.19.1, 0.19.0, 0.18.0}
Pester                      : {4.10.1, 4.10.0, 4.9.0, 4.4.4...}
PowerShellGet               : 2.2.3
PSDesiredStateConfiguration : 1.1
```

The output will also show previously installed versions of the PSAutoLab and Lability modules. Only the latest version should be loaded. You can remove the older versions if you no longer need them by running Uninstall-Module -name <modulename> -requiredversion <version number>. The FreeSpaceGB value is the amount of free space on the drive containing your AutoLab folder.

Copy and paste this information into a GitHub issue along with any relevant error messages.

## PARAMETERS

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS

[Get-Module]()

[Get-Volume]()

[Get-CimInstance]()
