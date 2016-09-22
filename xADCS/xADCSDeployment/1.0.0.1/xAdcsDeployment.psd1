@{
# Version number of this module.
ModuleVersion = '1.0.0.1'

# ID used to uniquely identify this module
GUID = '684e3c0d-a443-41f0-9e76-d216efea4540'

# Author of this module
Author = 'Microsoft Corporation'

# Company or vendor of this module
CompanyName = 'Microsoft Corporation'

# Copyright statement for this module
Copyright = '(c) 2013 Microsoft Corporation. All rights reserved.'

# Description of the functionality provided by this module
Description = 'The xCertificateServices module can be used to install or uninstall Certificate Services components in Windows Server.  All of the resources in the DSC Resource Kit are provided AS IS, and are not supported through any Microsoft standard support program or service.'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '4.0'

# Minimum version of the common language runtime (CLR) required by this module
CLRVersion = '4.0'

# Functions to export from this module
FunctionsToExport = '*'

# Cmdlets to export from this module
CmdletsToExport = '*'

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @('DesiredStateConfiguration', 'DSC', 'DSCResourceKit', 'DSCResource')

        # A URL to the license for this module.
        LicenseUri = 'https://github.com/PowerShell/xAdcsDeployment/blob/master/LICENSE'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/PowerShell/xAdcsDeployment'

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        ReleaseNotes = '* Moved Examples folder into root.
* Removed legacy xCertificateServices folder.
* Prevented Unit tests from Violating PSSA rules.
* MSFT_xAdcsWebEnrollment: Created unit tests based on v1.0 Test Template.
                           Update to meet Style Guidelines and ensure consistency.
                           Updated to IsSingleInstance model. **Breaking change**
* MSFT_xAdcsOnlineResponder: Update Unit tests to use v1.0 Test Template.
                             Unit tests can be run without AD CS installed.
                             Update to meet Style Guidelines and ensure consistency.
* Usage of WinRm.exe replaced in Config-SetupActiveDirectory.ps1 example file with Set-WSManQuickConfig cmdlet. 

'

    } # End of PSData hashtable

} # End of PrivateData hashtable
}



