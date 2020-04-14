---
external help file: PSAutoLab-help.xml
Module Name: PSAutoLab
online version:
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

This command makes it easy to see what the lab will look like when finished. You can see the computer names, what operating system they will be running and how much memory each will require. Even though dynamic memory will be used in the Hyper-V configuration, for planning purposes you should assume you will need the full amount. This should make it easier to determine if you have enough memory in your computer. Run the command in the root of the configuration folder.

## EXAMPLES

### Example 1

```powershell
PS C:\Autolab\Configurations\MultiRole-Server-2016> Get-LabSummary


Computername : DC1
InstallMedia : 2016_x64_Standard_Core_EN_Eval
Description  : Windows Server 2016 Standard Core 64bit English Evaluation
Role         : {DC, DHCP, ADCS}
IPAddress    : 192.168.3.10
MemoryGB     : 2
Processors   : 2
Lab          : MultiRole-Server-2016

Computername : S1
InstallMedia : 2016_x64_Standard_Core_EN_Eval
Description  : Windows Server 2016 Standard Core 64bit English Evaluation
Role         : {DomainJoin, Web}
IPAddress    : 192.168.3.50
MemoryGB     : 1
Processors   : 1
Lab          : MultiRole-Server-2016

Computername : N1
InstallMedia : 2016_x64_Standard_Nano_DSC_EN_Eval
Description  :
Role         :
IPAddress    : 192.168.3.60
MemoryGB     : 1
Processors   : 1
Lab          : MultiRole-Server-2016

Computername : Cli1
InstallMedia : WIN10_x64_Enterprise_EN_Eval
Description  : Windows 10 64bit Enterprise 1903 English Evaluation
Role         : {domainJoin, RSAT, RDP}
IPAddress    : 192.168.3.100
MemoryGB     : 2
Processors   : 2
Lab          : MultiRole-Server-2016
```

Get the configuration for the MultiRole-Server-2016 lab.

### Example 2

```powershell
PS C:\Autolab\Configurations> dir -Directory -exclude Archive | Get-LabSummary | Out-GridView
```

Go through every active configuration and pipe the folder to Get-LabSummary.
The total results are displayed using Out-GridView.

## PARAMETERS

### -Path

The PATH to the lab configuration folder.
Normally, you should run all commands from within the configuration folder.
Do NOT include the psd1 file name.

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
