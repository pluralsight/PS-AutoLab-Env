---
external help file: PSAutoLab-help.xml
Module Name: PSAutoLab
online version:
schema: 2.0.0
---

# Invoke-ValidateLab

## SYNOPSIS

Validate an Autolab configuration

## SYNTAX

```yaml
Invoke-ValidateLab [[-Path] <String>] [<CommonParameters>]
```

## DESCRIPTION

Lab configurations in Autolab use Desired State Configuration.
These configurations can take some time to finish and converge.
This command will validate that all virtual machines in the configuration are properly configured.
It will loop through every 5 minutes running a Pester test suite for the configuration.
Once all tests pass, the command will run the test one more time to display the results.
You will see errors until all tests have passed.
Depending on the configuration, this test could take up to 60 minutes to complete.
You can press Ctrl+C at any time to break out of the test.
If you prefer, you can also manually run the Pester test.

PS C:\Autolab\Configurations\PowerShellLab> Invoke-Pester .\VMvalidate.test.ps1

You will most likely use the Validate-Lab alias.

## EXAMPLES

### Example 1

```powershell
PS C:\AutoLab\Configurations\Windows10> Validate-Lab
```

You will see errors until all tests have passed.
Press Ctrl+C to break out of the test.
Configuration merging will continue in the virtual machines.

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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS

[Invoke-Pester]()
