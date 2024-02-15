---
external help file: PSAutoLab-help.xml
Module Name: PSAutoLab
online version: https://github.com/pluralsight/PS-AutoLab-Env/blob/master/docs/Invoke-UnattendLab.md
schema: 2.0.0
---

# Invoke-UnattendLab

## SYNOPSIS

Create an Autolab configuration unattended.

## SYNTAX

```
Invoke-UnattendLab [[-Path] <String>] [-AsJob] [-UseLocalTimeZone] [-NoMessages] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION

Normally when you set up an Autolab configuration, you can do it manually by running commands in order:

* Setup-Lab
* Run-Lab
* Enable-Internet
* Validate-Lab

Or you can use this command which will string all of these commands together. You may need to answer an initial prompt to update the version of nuget.exe otherwise the installation should run unattended.

The installation process will wait for five minutes before starting the testing loop. Note that the validation will loop until the configurations are finalized and converged. You can press Ctrl+C at any time to break out of the test. You can run Run-Pester at any time to manually run the Pester test.

You should run this command from within the configuration folder.

You will typically use the Unattend-Lab alias.

## EXAMPLES

### Example 1

```powershell
PS C:\Autolab\Configurations\PowerShellLab> Unattend-Lab
```

Follow any on-screen instructions or prompts.

### Example 2

```powershell
PS C:\Autolab\Configurations\MultiRole> Unattend-Lab -AsJob
```

Run the setup unattended in a background job.

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

### -AsJob

Run the unattend process in a PowerShell background job.

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

[Setup-Lab](Invoke-SetupLab.md)

[Run-Lab](Invoke-RunLab.md)

[Run-Pester](Invoke-Pester.md)
