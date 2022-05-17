[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "")]
param()

#dot source functions
. $PSScriptRoot\functions\public.ps1
. $PSScriptRoot\functions\private.ps1

#this variable is used for Refresh-Host to copy configurations from the module to Autolab\Configurations
$ConfigurationPath = Join-Path -Path $PSScriptRoot -ChildPath Configurations

#declare the currently supported version of Pester
#Pester v5 is incompatible with the current validation tests
$PesterVersion = "4.10.1"

#declare the currently supported version of Lability
$LabilityVersion = "0.21.1"

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