[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "")]
param()

#dot source functions
. $PSScriptRoot\functions\public.ps1
. $PSScriptRoot\functions\private.ps1

#this variable is used for Refresh-Host to copy configurations from the module to Autolab\Configurations
$ConfigurationPath = Join-Path -path $PSScriptRoot -ChildPath Configurations

#declare the currently supported version of Pester
#Pester v5 is incompatible with the current validation tests
$PesterVersion = "4.10.1"

#declare the currently supported version of Lability
$LabilityVersion = "0.19.1"
