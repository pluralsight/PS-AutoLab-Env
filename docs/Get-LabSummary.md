---
external help file: PSAutoLab-help.xml
Module Name: PSAutoLab
online version: https://github.com/pluralsight/PS-AutoLab-Env/blob/master/docs/Get-LabSummary.md
schema: 2.0.0
---

# Get-LabSummary

## SYNOPSIS

Get a summary of the AutoLab configuration.

## SYNTAX

```yaml
Get-LabSummary [[-Path] <String>] [<CommonParameters>]
```

## DESCRIPTION

This command makes it easy to see what the lab will look like when finished. You can see the computer names, what operating system they will be running, and how much memory each will require. Even though dynamic memory will be used in the Hyper-V configuration, for planning purposes you should assume you will need the full amount. This should make it easier to determine if you have enough available memory in your computer. Run the command in the root of the configuration folder.

If you have modified the configuration data file to use the EnvironmentPrefix setting, that value will be included as part of the virtual machine name.

Run Test-LabDSCResource from the configuration directory to see what DSC resources will be required and if they are already installed.

## EXAMPLES

### Example 1

```powershell
PS C:\Autolab\Configurations\Windows10> Get-LabSummary

   Computername: Win10Ent VMName: Win10Ent

Lab           IPAddress       MemGB Procs Role            Description
---           ---------       ----- ----- ----            -----------
Windows10     192.168.3.101       2     2 {RSAT, RDP}     Windows 10 64bit
                                                          Enterprise 1903
                                                          English Evaluation
```

Get the configuration for the Windows 10 lab. The command has an associated formatting file to display the results as you see here. You might also want to pipe the Get-LabSummary command to Format-List to see all properties.

### Example 2

```powershell
PS C:\Autolab\Configurations\> Get-Childitem -Directory | Get-LabSummary |
Select-Object * | Out-GridView
```

Go through every active configuration and pipe the folder to Get-LabSummary.
The total results are displayed using Out-GridView.

## PARAMETERS

### -Path

The PATH to the lab configuration folder. Normally, you should run all commands from within the configuration folder. Do NOT include the psd1 file name.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS

[Test-LabDSCResource](Test-LabDSCResource.md)

[Get-VM]()
