Function Test-ISOImage {
    [CmdletBinding()]
    [OutputType("ISOTest")]
    Param()

    $progParam = @{
        Activity         = $MyInvocation.MyCommand
        PercentComplete  = 0
        CurrentOperation = ""
    }

    Write-Verbose "Starting $($MyInvocation.MyCommand)"
    Try {
        $LabHost = Lability\Get-LabHostDefault -ErrorAction stop
        $ISOPath = $LabHost.IsoPath

        $progParam.Add("Status", "Validating ISO image files in $ISOPath")
    }
    Catch {
        Throw $_
    }
    Write-Verbose "Testing ISO images under $ISOPath"
    $files = Get-ChildItem -Path $ISOPath -Filter *.iso

    if ($files.count -gt 0) {
        #initialize a counter
        $i = 0
        foreach ($file in $files) {
            $i++
            $progParam.PercentComplete = ($i / $files.count) * 100
            $progParam.CurrentOperation = $file.name
            Write-Progress @progParam
            #construct the checksum file
            $ChkFile = Join-Path -Path $ISOPath -ChildPath "$($file.name).checksum"
            Write-Verbose "Processing $($file.name)"
            $HashData = Get-FileHash -Path $file.FullName -Algorithm MD5

            if (Test-Path $ChkFile) {
                $chkSum = Get-Content -Path $ChkFile
                if ($chkSum -eq $HashData.hash) {
                    $Valid = $True
                }
            }
            else {
                Write-Warning "Missing checksum file $ChkFile"
                $chkSum = "unknown"
                $Valid = $False
            }

            #write a custom object to the pipeline
            [PSCustomObject]@{
                PSTypeName = "ISOTest"
                Path       = $HashData.Path
                Valid      = $Valid
                Size       = (Get-Item -Path $HashData.path).length
                Hash       = $HashData.Hash
                Checksum   = $chkSum
                Algorithm  = $HashData.Algorithm
            }
        } #foreach file
    } #if files
    else {
        Write-Warning "Failed to find any ISO files in $ISOPath."
    }
    Write-Verbose "Ending $($MyInvocation.MyCommand)"
}
