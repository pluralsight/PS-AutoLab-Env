Function Get-PSAutoLabSetting {
    [CmdletBinding()]
    [OutputType("PSAutoLabSetting")]
    Param()

    Write-Verbose "Starting $($MyInvocation.MyCommand)"

    $PSVer = $PSVersionTable
    Try {
        Write-Verbose "Getting operating system details"
        $CimOS = Get-CimInstance -class Win32_OperatingSystem -Property caption, FreePhysicalMemory, TotalVisibleMemorySize -ErrorAction Stop
        $os = $CimOS.caption
        $mem = $CimOS.TotalVisibleMemorySize
        $pctFree = [math]::round(($CimOS.FreePhysicalMemory / $CimOS.TotalVisibleMemorySize) * 100, 2)
    }
    Catch {
        $os = ""
        $mem = 0
        $pctFree = 0
    }

    Write-Verbose "Getting Autolab folder if installed and free hard drive space"
    Try {
        $LabHost = Lability\Get-LabHostDefault -ErrorAction stop
        $AutoLab = Split-Path $LabHost.ConfigurationPath
        $free = (Get-Volume $autolab[0]).SizeRemaining
    }
    Catch {
        $AutoLab = "NotFound"
        $free = (Get-Volume C).SizeRemaining  #Assume C drive
    }

    Write-Verbose "Get network category for LabNet"
    $net = Get-NetConnectionProfile -InterfaceAlias *LabNet*
    if ($net) {
        $NetProfile = $net.NetworkCategory
    }
    else {
        $NetProfile = "unknown"
    }

    [PSCustomObject]@{
        PSTypeName                  = "PSAutoLabSetting"
        AutoLab                     = $Autolab
        PSVersion                   = $PSVer.PSVersion
        PSEdition                   = $PSVer.PSEdition
        OS                          = $os
        FreeSpaceGB                 = [math]::Round($free / 1GB, 2)
        MemoryGB                    = ($mem * 1kb) / 1GB -as [Int]
        PctFreeMemory               = $pctFree
        Processor                   = (Get-CimInstance -ClassName Win32_Processor -Property Name).Name
        IsElevated                  = (Test-IsAdministrator)
        RemotingEnabled             = $(try { [void](Test-WSMan -ErrorAction stop); $True } catch { $false })
        NetConnectionProfile        = $NetProfile
        HyperV                      = (Get-Item $env:windir\System32\vmms.exe).VersionInfo.ProductVersion
        PSAutolab                   = (Get-Module -Name PSAutolab -ListAvailable | Sort-Object -Property Version -Descending).version
        Lability                    = (Get-Module -Name Lability -ListAvailable | Sort-Object -Property Version -Descending).version
        Pester                      = (Get-Module -Name Pester -ListAvailable | Sort-Object -Property Version -Descending).version
        PowerShellGet               = (Get-Module -Name PowerShellGet -ListAvailable | Sort-Object -Property Version -Descending | Select-Object -First 1).version
        PSDesiredStateConfiguration = (Get-Module -Name PSDesiredStateConfiguration -ListAvailable | Sort-Object -Property Version -Descending | Select-Object -First 1).version
    }

    if ($NetProfile -eq 'Unknown' -or (-not $NetProfile)) {
        Write-Warning "The network connection profile for LabNet is not set to Private or DomainAuthenticated. Commands that rely on PowerShell remoting may fail."
    }
    if ([math]::Round($free / 1GB, 2) -le 50) {
        Write-Warning "You may not have enough free disk space. 100GB is recommended, although you can get by with less depending on the lab configuration you need to run."
    }
    if (($mem * 1kb) / 1GB -as [Int] -le 16) {
        Write-Warning "You may not have enough memory. 16GB or more is recommended"
    }

    Write-Verbose "Ending $($MyInvocation.MyCommand)"
}
