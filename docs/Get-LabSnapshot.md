---
external help file: PSAutoLab-help.xml
Module Name: PSAutoLab
online version: https://github.com/pluralsight/PS-AutoLab-Env/blob/master/docs/Get-LabSnapshot.md
schema: 2.0.0
---

# Get-LabSnapshot

## SYNOPSIS

List available snapshots for a lab configuration.

## SYNTAX

```yaml
Get-LabSnapshot [[-Path] <String>] [<CommonParameters>]
```

## DESCRIPTION

You can use Snapshot-Lab to create a set of checkpoints for an Autolab configuration. The default snapshot name is "LabConfigured", but you can create a snapshot with your own name. You need to know the snapshot name in order to restore it with Refresh-Lab. This command makes it easier to discover what snapshots you have created.

Note that if you want to remove a snapshot, use the Hyper-V Manager or PowerShell cmdlets as you would any other snapshot.

## EXAMPLES

### Example 1

```powershell
PS C:\Autolab\Configurations\SingleServer> Get-LabSnapshot

All VMs in the configuration should belong to the same snapshot.

VMName Name          SnapshotType  CreationTime          ParentSnapshotName
------ ----          ------------  ------------          ------------------
S1     PreInstall    Standard      9/11/2020 12:06:51 PM
```

You could restore this snapshot by name using Refresh-Lab.

## PARAMETERS

### -Path

The path to the configuration folder. Normally, you should run all commands from within the configuration folder.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
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

[Snapshot-Lab](Invoke-SnapshotLab.md)

[Refresh-Lab](Invoke-RefreshLab.md)
