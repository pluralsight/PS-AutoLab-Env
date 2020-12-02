---
external help file: PSAutoLab-help.xml
Module Name: PSAutoLab
online version: https://github.com/pluralsight/PS-AutoLab-Env/blob/master/docs/Get-PSAutoLabSetting.md
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
PSVersion                   : 5.1.19041.610
PSEdition                   : Desktop
OS                          : Microsoft Windows 10 Pro
FreeSpaceGB                 : 705.95
MemoryGB                    : 32
PctFreeMemory               : 68.27
Processor                   : Intel(R) Core(TM) i9-10900T CPU @ 1.90GHz
IsElevated                  : True
RemotingEnabled             : True
NetConnectionProfile        : Private
HyperV                      : 10.0.19041.1
PSAutolab                   : {4.18.0, 4.17.0}
Lability                    : {0.19.1,0.18.0}
Pester                      : {5.1.0, 4.10.1, 3.4.0}
PowerShellGet               : 2.2.5
PSDesiredStateConfiguration : 1.1
```

The output will also show previously installed versions of the PSAutoLab and Lability modules. Only the latest version of each module will be used. You can remove the older versions if you no longer need them by running a command like `Uninstall-Module -name Lability -requiredversion 0.18.0`. The FreeSpaceGB value is the amount of free space on the drive containing your AutoLab folder.

Copy and paste this information into a GitHub issue along with any relevant error messages.

Note that the command uses a custom formatting file to display key values in color.

## PARAMETERS

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### PSAutoLabSetting

## NOTES

## RELATED LINKS

[Get-Module]()

[Get-Volume]()

[Get-CimInstance]()

[Get-NetConnectionProfile]()
