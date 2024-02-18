---
external help file: PSAutoLab-help.xml
Module Name: PSAutoLab
online version: https://github.com/pluralsight/PS-AutoLab-Env/blob/master/docs/Test-LabDSCResource.md
schema: 2.0.0
---

# Test-LabDSCResource

## SYNOPSIS

Test for required DSC resources.

## SYNTAX

```yaml
Test-LabDSCResource [[-Path] <String>] [<CommonParameters>]
```

## DESCRIPTION

This is a troubleshooting command for the PSAutoLab module. It is designed to be  run in a lab configuration folder. It will report on the required Desired State Configuration (DSC) resources and any versions that may already be installed. This can be used to diagnose potential version conflicts. Resources are installed automatically when you build a configuration so you don't need to take any action unless directed.

## EXAMPLES

### Example 1

```shell
PS C:\autolab\Configurations\MultiRole> Test-LabDSCResource


   Configuration: MultiRole

ModuleName                   RequiredVersion Installed InstalledVersions
----------                   --------------- --------- -----------------
xActiveDirectory             3.0.0.0         True      3.0.0.0
xComputerManagement          4.1.0.0         True      4.1.0.0
xNetworking                  5.7.0.0         True      5.7.0.0
xDhcpServer                  3.0.0           True      3.0.0
xWindowsUpdate               2.8.0.0         True      2.8.0.0
xPSDesiredStateConfiguration 9.1.0           True      9.1.0
xPendingReboot               0.4.0.0         True      0.4.0.0
xADCSDeployment              1.4.0.0         True      1.4.0.0
xDnsServer                   1.16.0.0        True      1.16.0.0
```

Run this command from the lab configuration folder.

## PARAMETERS

### -Path

Specify the folder path of an AutoLab configuration or change locations to the folder and run this command.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: .
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### PSAutoLabResource

## NOTES

## RELATED LINKS

[Get-LabSummary](Get-LabSummary.md)

[Get-DSCResource]()
