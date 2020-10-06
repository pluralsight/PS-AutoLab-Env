---
external help file: PSAutoLab-help.xml
Module Name: PSAutoLab
online version: https://github.com/pluralsight/PS-AutoLab-Env/blob/master/docs/Invoke-WipeLab.md
schema: 2.0.0
---

# Invoke-WipeLab

## SYNOPSIS

Remove an Autolab configuration.

## SYNTAX

```yaml
Invoke-WipeLab [[-Path] <String>] [-RemoveSwitch] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

You can use this command to remove all files and virtual machines related to an Autolab configuration. The command will stop any running virtual machines for you. It is assumed you will be running this command from within a configuration folder.

If you intend to rebuild the lab or create another configuration, you do not need to delete the virtual switch (LabNet).

Use -Force to suppress all prompts.

You will typically use the Wipe-Lab alias.

## EXAMPLES

### Example 1

```powershell
PS C:\AutoLab\Configurations\Windows10> Wipe-Lab
```

Follow any on-screen prompts or instructions.

### Example 2

```powershell
PS C:\AutoLab\Configurations\SingleServer> Wipe-Lab -force -RemoveSwitch
```

Forcibly remove all lab elements including the virtual switch.

## PARAMETERS

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

### -WhatIf

Shows what would happen if the cmdlet runs. The cmdlet is not run.

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

### -Force

Remove lab elements with no prompting.

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

### -RemoveSwitch

Remove the VM Switch. It is retained by default.

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

[Setup-Lab](Invoke-SetupLab.md)
