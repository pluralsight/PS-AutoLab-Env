
#dot source functions
. $PSScriptRoot\functions\public.ps1
. $PSScriptRoot\functions\private.ps1

$ConfigurationPath = Join-Path -path $PSScriptRoot -ChildPath Configurations

#declare the currently supported version of Pester
#Pester v5 is incompatible with the current validation tests
$PesterVersion = "4.10.1"

#declare the currently supported version of Lability
$LabilityVersion = "0.19.1"
