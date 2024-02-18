---
external help file: PSAutoLab-help.xml
Module Name: PSAutoLab
online version: https://github.com/pluralsight/PS-AutoLab-Env/blob/master/docs/Invoke-ValidateLab.md
schema: 2.0.0
---

# Invoke-ValidateLab

## SYNOPSIS

Validate an Autolab configuration.

## SYNTAX

```yaml
Invoke-ValidateLab [[-Path] <String>] [-NoMessages] [<CommonParameters>]
```

## DESCRIPTION

Lab configurations in Autolab use Desired State Configuration. These configurations can take some time to finish and converge. This command will validate that all virtual machines in the configuration are properly configured.
It will loop through every 5 minutes running a Pester test suite for the configuration. Once all tests pass, the command will run the test one more time to display the results. You will see errors until all tests have passed. Depending on the configuration, this test could take up to 60 minutes to complete. You can press Ctrl+C at any time to break out of the test. If you prefer, you can also manually run the Pester test.

PS C:\Autolab\Configurations\PowerShellLab> Run-Pester

You will typically use the Validate-Lab alias.

Note that beginning in v4.21.0, this validation command will keep track of the number of testing loops. After 2 loops it will check for any virtual machine that is failing a test to see if it has stopped. If so, it will be started. After 4 loops and virtual machine that is still failing tests will be restarted. Ideally, Validation should complete in 30 minutes or less. The validation process will abort after 65 minutes.

Run Validate-Lab -Verbose to see details about the number of testing loops and which virtual machines are started or restarted.

## EXAMPLES

### Example 1

```shell
PS C:\AutoLab\Configurations\Windows10> Validate-Lab -verbose
```

You will see errors until all tests have passed. Press Ctrl+C to break out of the test. Configuration merging will continue in the virtual machines.

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

[Invoke-PesterTest](Invoke-PesterTest.md)
