[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "")]
param()

#Show a warning if not running Windows PowerShell 5.1
if ($PSEdition -ne 'Desktop') {
    $warn = @"

    This module is not supported in PowerShell $($PSVersionTable.PSVersion).
    Please use Windows PowerShell 5.1 for the best experience.

    The PSAutoLab module will still be imported into this session but will
    not have any commands. You can manually remove it.

    Remove-Module PSAutoLab

"@
    Write-Warning $warn
    Return
}
else {
    #dot source functions
    Get-ChildItem -path $PSScriptRoot\Functions\*.ps1 | ForEach-Object { . $_.FullName }

    #this variable is used for Refresh-Host to copy configurations from the module to Autolab\Configurations
    $ConfigurationPath = Join-Path -Path $PSScriptRoot -ChildPath Configurations

    #declare the currently supported version of Pester
    #Pester v5 is supported with v5.0.0 of this module

    $PesterVersion = "5.5.0"

    #validate Pester version on module import. Even though it is marked as a required module,
    #But it won't be installed unless using -SkipPublisherCheck
    #This code is a failsafe to ensure the correct version is installed
    if (-not ((Get-Module pester -ListAvailable)[0].version -ge $PesterVersion)) {
        Write-Warning "Pester v$PesterVersion or later is required to use this module. Please install it from the PowerShell Gallery: Install-Module Pester -Force -SkipPublisherCheck"
    }

    #declare the currently supported version of Lability
    $LabilityVersion = "0.25.0"

    #configure TLS protocol to avoid problems downloading files from Microsoft
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    #open the PDF help file
    Function Open-PSAutoLabHelp {
        [cmdletbinding()]
        Param()

        $pdf = Join-Path -Path $PSScriptRoot -ChildPath PSAutoLabManual.pdf
        if (Test-Path -Path $pdf) {
            Try {
                Start-Process -FilePath $pdf -ErrorAction Stop
            }
            Catch {
                Write-Warning "Failed to automatically open the PDF. You will need to manually open $pdf."
            }
        }
        else {
            Write-Warning "Can't find $pdf."
        }
    }
}