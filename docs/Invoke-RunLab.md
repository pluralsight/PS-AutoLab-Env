---
external help file: PSAutoLab-help.xml
Module Name: PSAutoLab
online version:
schema: 2.0.0
---

# Invoke-RunLab

## SYNOPSIS

Start a PSAutolab configuration.

## SYNTAX

```yaml
Invoke-RunLab [[-Path] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

Use this command to start a PSAutolab configuration.
This command will start all of the virtual machines in the proper order.
It is assumed you are running this from within the configuration folder.

You will most likely use the Run-Lab alias.

## EXAMPLES

### Example 1

```powershell
PS C:\AutoLab\Configurations\Windows10> Run-Lab
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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS

[Shutdown-Lab]()
