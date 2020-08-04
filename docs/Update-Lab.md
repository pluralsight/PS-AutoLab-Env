---
external help file: PSAutoLab-help.xml
Module Name: PSAutoLab
online version: https://github.com/pluralsight/PS-AutoLab-Env/blob/master/docs/Update-Lab.md
schema: 2.0.0
---

# Update-Lab

## SYNOPSIS

Run Windows update on Autolab virtual machines.

## SYNTAX

```yaml
Update-Lab [[-Path] <String>] [-AsJob] [<CommonParameters>]
```

## DESCRIPTION

When you build an lab, you are creating Windows virtual machines based on evaluation software. You might still want to make sure the virtual machines are up to date with security patches and updates. You can use this command to invoke Windows update on all lab members. This can be a time consuming process, especially for labs with multiple virtual machines. The recommended syntax is to use the -AsJob parameter which runs the update process for each virtual machine in a background job. Use PowerShell's job cmdlets to manage the jobs. Do not close your PowerShell session before the jobs complete.

The virtual machine must be running in order to update it.

It is recommended that you reboot all the lab virtual machines after updating.

## EXAMPLES

### Example 1

```powershell
PS C:\Autolab\Configurations\PowerShellLab> update-lab -AsJob

Id     Name            PSJobTypeName   State         HasMoreData     Location             Command
--     ----            -------------   -----         -----------     --------             -------
18     WUUpdate        RemoteJob       Running       True            DOM1                  WUUpdate
21     WUUpdate        RemoteJob       Running       True            SRV1                  WUUpdate
24     WUUpdate        RemoteJob       Running       True            SRV2                  WUUpdate
27     WUUpdate        RemoteJob       Running       True            SRV3                  WUUpdate
30     WUUpdate        RemoteJob       Running       True            WIN10                 WUUpdate

PS C:\Autolab\Configurations\PowerShellLab> receive-job -id 27 -Keep
[11/22/2019 12:05:43] Found 5 updates to install on SRV3
[11/22/2019 12:25:13] Update process complete on SRV3
WARNING: SRV3 requires a reboot
```

Run the update process as a background job. Use the PowerShell job cmdlets to manage.

## PARAMETERS

### -AsJob

Run the update process in a background job.

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

The path to the configuration folder.
Normally, you should run all commands from within the configuration folder.

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

[Get-Job]()

[Receive-Job]()
