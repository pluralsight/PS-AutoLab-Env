Function Test-LabDSCResource {
    [CmdletBinding()]
    [OutputType("PSAutolabResource")]
    Param(
        [Parameter(Position = 0, HelpMessage = "Specify the folder path of an Autolab configuration or change locations to the folder and run this command.")]
        [ValidateScript( { Test-Path $_ })]
        [String]$Path = "."
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeOfDay) BEGIN  ] Starting $($MyInvocation.MyCommand)"
        $cPath = Convert-Path -Path $Path
        $config = Join-Path -Path $cPath -ChildPath VMConfigurationData.psd1
        $configName = Split-Path $cPath -Leaf
    } #begin

    Process {
        Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] Testing resources in $cPath "
        Try {
            $data = Import-PowerShellDataFile -Path $config -ErrorAction Stop
        }
        Catch {
            Throw $_
        }
        if ($data.NonNodeData.Lability.DSCResource) {
            $dsc = $data.NonNodeData.Lability.DSCResource
            Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] Found $($dsc.count) required DSC resources"
            $dsc.GetEnumerator() | ForEach-Object {
                $installed = Get-Module $_.name -ListAvailable
                [PSCustomObject]@{
                    PSTypeName        = 'PSAutoLabResource'
                    ModuleName        = $_.Name
                    RequiredVersion   = $_.RequiredVersion
                    Installed         = $installed.version -contains $_.RequiredVersion
                    InstalledVersions = $Installed.version
                    Configuration     = $configName
                }
            }
        }
        else {
            Write-Warning "No DSC Resources found in $config."
        }
    } #process

    End {
        Write-Verbose "[$((Get-Date).TimeOfDay) END    ] Ending $($MyInvocation.MyCommand)"

    } #end

}
