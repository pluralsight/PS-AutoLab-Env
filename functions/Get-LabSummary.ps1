Function Get-LabSummary {
    [CmdletBinding()]
    [Alias("Setup-Lab")]
    Param (
        [Parameter(Position = 0, ValueFromPipeline, HelpMessage = "The PATH to the lab configuration folder. Normally, you should run all commands from within the configuration folder. Do not include the psd1 file name.")]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { Test-Path $_ })]
        [String]$Path = "."
    )

    Begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
        #create the media lookup table
        lability\Get-LabMedia | ForEach-Object -begin { $media=[ordered]@{}} -Process { $media.Add($_.id,$_.description)}
    }
    Process {
        $Path = Convert-Path $path
        Write-Verbose "Searching in $path for VMConfigurationData.psd1"
        $psd1 = $(Join-Path $Path -ChildPath VMConfigurationData.psd1)

        if (Test-Path $psd1) {
            $LabName = Split-Path $Path -Leaf
            Write-Verbose "Getting summary for $LabName"

            Write-Verbose "Getting node data from $psd1"
            $import = Import-PowerShellDataFile -Path $psd1
            $Nodes = $import.AllNodes

            #get the optional prefix value
            $EnvPrefix = $import.NonNodeData.Lability.EnvironmentPrefix
            $nodes.where( { $_.NodeName -ne '*' }).Foreach( {
                    if ($_.lability_StartupMemory) {
                        $mem = $_.lability_StartupMemory
                    }
                    elseif ($_.lability_MinimumMemory) {
                        $mem = $_.lability_MinimumMemory
                    }
                    else {
                        $mem = $nodes[0].Lability_MinimumMemory
                    }
                    if ($_.Lability_ProcessorCount) {
                        $ProcCount = $_.Lability_ProcessorCount
                    }
                    else {
                        $ProcCount = 1
                    }
                    #added for issue #245 where lability_media might not be defined
                    if ($_.lability_media) {
                        $description = $media[$_.lability_media]
                    }
                    else {
                        #check for default
                        if ($nodes[0].lability_media) {
                            $description = $nodes[0].lability_media
                        }
                        else {
                            $description = "unknown"
                        }
                    }
                    [PSCustomObject]@{
                        PSTypeName   = "PSAutolabVM"
                        Computername = $_.NodeName
                        VMName       = "{0}{1}" -f $envPrefix, $_.NodeName
                        InstallMedia = $_.lability_media
                        Description  = $description
                        Role         = $_.Role
                        IPAddress    = $_.IPAddress
                        MemoryGB     = $mem / 1GB
                        Processors   = $ProcCount
                        Lab          = $LabName
                    }
                })
        }
        else {
            Write-Warning "Failed to find $psd1."
        }
    } #process

    End {
        Write-Verbose "Ending $($MyInvocation.MyCommand)"
    }
}
