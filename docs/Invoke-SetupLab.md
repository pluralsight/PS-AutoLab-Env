---
external help file: PSAutoLab-help.xml
Module Name: PSAutoLab
online version: https://github.com/pluralsight/PS-AutoLab-Env/blob/master/docs/Invoke-SetupLab.md
schema: 2.0.0
---

# Invoke-SetupLab

## SYNOPSIS

Set up an Autolab configuration.

## SYNTAX

```yaml
Invoke-SetupLab [[-Path] <String>] [-IgnorePendingReboot] [-UseLocalTimeZone] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION

Once you have configured the local host, change to a configuration folder under Autolab\Configurations and run a setup. It is recommended that you first review any readme or instruction files. This command will generate the DSC MOFs, download required DSC resources and create the virtual machines. Follow on-screen instructions to continue.

You will typically use the Setup-Lab alias.

## EXAMPLES

### Example 1

```powershell
PS C:\Autolab\Configurations\Windows10> Setup-Lab
```

Follow on screen instructions and prompts.

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

### -IgnorePendingReboot

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

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

### -UseLocalTimeZone

Override any configuration specified time zone and use the local time zone on this computer.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

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

[Unattend-Lab]()
