---
external help file: PSAutoLab-help.xml
Module Name: PSAutoLab
online version: https://github.com/pluralsight/PS-AutoLab-Env/blob/master/docs/Invoke-SnapshotLab.md
schema: 2.0.0
---

# Invoke-SnapshotLab

## SYNOPSIS

Create virtual machine snapshots of your Autolab configuration.

## SYNTAX

```yaml
Invoke-SnapshotLab [[-Path] <String>] [-SnapshotName <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

Use this command to snapshot or checkpoint an entire Autolab configuration. You can later restore your configuration with Refresh-Lab. It is assumed you are running this command from within the configuration folder.

You will typically use the Snapshot-Lab alias.

## EXAMPLES

### Example 1

```powershell
PS C:\Autolab\Configurations\Windows10> Snapshot-Lab
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

### -SnapshotName

Specify a name for the virtual machine checkpoint

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: LabConfigured
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

[Refresh-Lab](Invoke-RefreshLab.md)

[Get-LabSnapshot](Get-LabSnapshot.md)
