---
external help file: PSAutoLab-help.xml
Module Name: PSAutoLab
online version: https://github.com/pluralsight/PS-AutoLab-Env/blob/master/docs/Invoke-ShutdownLab.md
schema: 2.0.0
---

# Invoke-ShutdownLab

## SYNOPSIS

Shutdown an Autolab configuration.

## SYNTAX

```yaml
Invoke-ShutdownLab [[-Path] <String>] [-NoMessages] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

Use this command to shutdown the virtual machines of an Autolab configuration in the proper order. You can also manually use the Hyper-V management console or cmdlets to do the same thing. It is recommended that you shut down any domain controllers in your configuration last. It is assumed you are running this from within the configuration folder.

You will typically use the Shutdown-Lab alias.

## EXAMPLES

### Example 1

```powershell
PS C:\Autolab\Configurations\PowerShellLab> Shutdown-Lab
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

### -Path

The path to the configuration folder. Normally, you should run all commands from within the configuration folder.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: Current Directory
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

### -NoMessages
Run the command but suppress all status messages.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: Quiet

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

[Run-Lab](Invoke-RunLab.md)
