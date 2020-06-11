---
external help file: PSAutoLab-help.xml
Module Name: PSAutoLab
online version:
schema: 2.0.0
---

# Test-LabDSCResource

## SYNOPSIS

Test for required DSC resources

## SYNTAX

```yaml
Test-LabDSCResource [[-Path] <String>] [<CommonParameters>]
```

## DESCRIPTION

This is a troubleshooting command for the PSAutoLab module. It is designed to be be run in a lab configuration folder. It will report on the required Desired State Configuration (DSC) resources and any versions that may already be installed. This can be used to diagnose potential version conflicts. Resource are installed automatically when you build a configuration so you don't need to take any action unless directed.

## EXAMPLES

### Example 1

```powershell
PS C:\Auto\Lab\Configurations\MultiRole> Test-LabDSCResource

ModuleName        : xActiveDirectory
RequiredVersion   : 3.0.0.0
Installed         : True
InstalledVersions : {3.0.0.0, 2.16.0.0, 2.14.0.0}
Configuration     : MultiRole

ModuleName        : xComputerManagement
RequiredVersion   : 4.1.0.0
Installed         : True
InstalledVersions : {4.1.0.0, 2.0.0.0, 1.8.0.0}
Configuration     : MultiRole

ModuleName        : xNetworking
RequiredVersion   : 5.7.0.0
Installed         : True
InstalledVersions : 5.7.0.0
Configuration     : MultiRole

ModuleName        : xDhcpServer
RequiredVersion   : 2.0.0.0
Installed         : True
InstalledVersions : {2.0.0.0, 1.5.0.0}
Configuration     : MultiRole

ModuleName        : xWindowsUpdate
RequiredVersion   : 2.8.0.0
Installed         : True
InstalledVersions : {2.8.0.0, 2.7.0.0, 2.5.0.0}
Configuration     : MultiRole

ModuleName        : xPSDesiredStateConfiguration
RequiredVersion   : 9.1.0
Installed         : True
InstalledVersions : {9.1.0, 9.0.0, 8.10.0.0, 8.9.0.0…}
Configuration     : MultiRole

ModuleName        : xPendingReboot
RequiredVersion   : 0.4.0.0
Installed         : True
InstalledVersions : {0.4.0.0, 0.3.0.0}
Configuration     : MultiRole

ModuleName        : xADCSDeployment
RequiredVersion   : 1.4.0.0
Installed         : True
InstalledVersions : {1.4.0.0, 1.1.0.0, 1.0.0.0}
Configuration     : MultiRole

ModuleName        : xDnsServer
RequiredVersion   : 1.16.0.0
Installed         : True
InstalledVersions : {1.16.0.0, 1.15.0.0, 1.14.0.0, 1.7.0.0}
Configuration     : MultiRole
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

### System.Object

## NOTES

## RELATED LINKS
