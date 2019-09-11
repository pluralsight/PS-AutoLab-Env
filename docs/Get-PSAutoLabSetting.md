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

PSVersion : 5.1.18362.145
Edition   : Desktop
OS        : Microsoft Windows 10 Pro
PSAutolab : 4.1.0
Lability  : 0.18.0
Memory    : 33442716
```

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
