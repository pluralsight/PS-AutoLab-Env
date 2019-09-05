[cmdletbinding(SupportsShouldProcess)]

Param(
    [ValidateScript({Test-Path $_})]
    [ValidateNotNullorEmpty()]
    [alias("Path")]
    [string]$Destination = 'C:\Program Files\WindowsPowerShell\Modules'
)

Copy-Item -Path "$PSScriptRoot\PSAutoLab" -Destination $Destination -Recurse -Force -Container
