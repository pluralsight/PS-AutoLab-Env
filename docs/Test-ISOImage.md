---
external help file: PSAutoLab-help.xml
Module Name: PSAutoLab
online version: https://github.com/pluralsight/PS-AutoLab-Env/blob/master/docs/Test-ISOImage.md
schema: 2.0.0
---

# Test-ISOImage

## SYNOPSIS

Test PSAutolab ISO images

## SYNTAX

```yaml
Test-ISOImage [<CommonParameters>]
```

## DESCRIPTION

This command is designed to test and validate downloaded ISO images used by the PSAutolab module. Each ISO file should have a corresponding checksum file with the valid MD5 hash. Test-ISOImage will test each ISO image file and compare it to the checksum value if found. If you have not setup any lab configurations, then you won't have any ISO image files.

ISO image files are only downloaded once during setup. If any of the ISO images fail to pass validation, you should delete the file along with its associated checksum file. Wipe the lab that is using the image and set it up again.

## EXAMPLES

### Example 1

```powershell
PS C:\> Test-ISOImage

Path                                           Valid Size
----                                           ----- ----
C:\autolab\ISOs\2016_x64_EN_Eval.iso           True  6972221440
C:\autolab\ISOs\2019_x64_EN_Eval.iso           True  4973780992
C:\autolab\ISOs\WIN10_x64_ENT_19H2_EN_Eval.iso True  4892766208
```

You can pipe the results to Select-Object * to see all property values.

## PARAMETERS

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### ISOTest

## NOTES

## RELATED LINKS

[Get-FileHash]()
