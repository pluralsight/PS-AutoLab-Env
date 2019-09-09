
#declare the currently supported version of Lability
$LabilityVersion = "0.18.0"
$ConfigurationPath = Join-Path -path $PSScriptRoot -ChildPath Configurations

#dot source functions
. $PSScriptRoot\functions\public.ps1
. $PSScriptRoot\functions\private.ps1
