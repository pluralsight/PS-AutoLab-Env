---
external help file: PSAutoLab-help.xml
Module Name: PSAutoLab
online version: https://github.com/pluralsight/PS-AutoLab-Env/blob/master/docs/Invoke-SetupHost.md
schema: 2.0.0
---

# Invoke-SetupHost

## SYNOPSIS

Prepare the localhost for PSAutolab.

## SYNTAX

```yaml
Invoke-SetupHost [[-DestinationPath] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

The first time you install the PSAutoLab module, you will need to configure the localhost. This configuration will include adding the Hyper-V feature if it is not already installed. It will also install the supported version of the Lability module from the PowerShell Gallery. You only need to run this command once. If you update the PSAutoLab module at some point, it is recommended that you run Refresh-Host.

You will typically use the Setup-Host alias.

## EXAMPLES

### Example 1

```powershell
PS C:\> Setup-Host
```

Follow the on-screen prompts. If you have to install the Hyper-V feature you definitely should reboot before setting up any lab configurations.

### Example 2

```powershell
PS C:\> Setup-Host -destination D:\Autolab
```

This will setup the Autolab module but put the necessary files on the D: drive. It is recommended that you use Autolab as the folder name.

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

### -DestinationPath

Specify the parent path for your Autolab setup.
The default is C:\Autolab
The command will create the folder.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: C:\Autolab
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

### None

## NOTES

## RELATED LINKS

[Refresh-Host]()
