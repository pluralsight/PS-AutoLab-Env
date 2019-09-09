---
external help file: PSAutoLab-help.xml
Module Name: PSAutoLab
online version:
schema: 2.0.0
---

# Invoke-RefreshHost

## SYNOPSIS

Refresh local host Autolab configuration

## SYNTAX

```yaml
Invoke-RefreshHost [[-Destination] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

If you keep the PSAutoLab module for any length of time, you will most likely update from time to time.
Part of the update might include fixes or enhancements to current configurations or even entirely new configurations.
This command makes it easier to keep your configurations up to date.
After updating the PSAutoLab module, run this command which will verify you have the correct version of the Lability module and copy configuration files to your Autolab\ConfigurationPath folder.
This will not overwrite any MOF files or delete anything.

You will most likely use the Refresh-Host alias.

## EXAMPLES

### Example 1

```powershell
PS C:\> Refresh-Host
Version 0.18.0 of Lability is already installed
Updating configuration files from C:\Program Files\WindowsPowerShell\Modules\PSAutoLab\4.0.0\Configurations
This process will not remove any configurations that have been deleted from the module.
```

## PARAMETERS

### -Confirm

Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Destination

The path to your configurations folder.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: <drive>:\Autolab\Configurations
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf

Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
