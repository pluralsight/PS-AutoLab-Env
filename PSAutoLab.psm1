[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "")]

<# Notes:

Authors: Jason Helmick,Melissa (Missy) Janusko, and Jeff Hicks

Note:
This module should not be considered to follow best practices. It provides a
library of commands that wrap around functionality from the Lability module
with the goal of making it easy to setup a new lab environment. The commands
in this module have standard names, but will most often be called by their non-standard
aliases for backwards compatibility.

Disclaimer

This example code is provided without copyright and AS IS.  It is free for you to use and modify.
Note: These demos should not be run as a script. These are the commands that I use in the
demonstrations and would need to be modified for your environment.

#>


#declare the currently supported version of Lability
$LabilityVersion = "0.18.0"
$ConfigurationPath = Join-Path -path $PSScriptRoot -ChildPath Configurations

#dot source functions
. $PSScriptRoot\functions\public.ps1
. $PSScriptRoot\functions\private.ps1


#test for old PSAutoLab module and prompt user to manually remove it

$mod = Get-Module psautolab -ListAvailable
if ($mod) {
    $modpath = Split-Path -path $mod[0].path
    $msg = @"

    An outdated version of this module was detected on this computer.
    It may conflict with the current commands. The recommendation is that
    you manually remove the files at $modpath.
"@

    Write-Warning $msg
}