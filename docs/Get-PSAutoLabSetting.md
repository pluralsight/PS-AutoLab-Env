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

If you need to report a problem with Autolab, use this command to get relevant configuration and host information.
Include the output in your GitHub issue.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-PSAutoLabSetting

PSVersion     : 5.1.18362.145
PSEdition     : Desktop
OS            : Microsoft Windows 10 Pro
IsElevated    : True
HyperV        : 10.0.18362.1
PSAutolab     : {4.3.0, 4.1.1, 4.1.0, 4.0.0}
Lability      : {0.18.0, 0.12.4, 0.10.1}
Pester        : 4.9.0
MemoryGB      : 32
PctFreeMemory : 15.24
```

The output will also show previously installed versions of the PSAutolab and Lability modules.
Only the latest version should be loaded. You can remove the older versions if you no longer need them by running Uninstall-Module -name <modulename> -requiredversion <version number>.

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
