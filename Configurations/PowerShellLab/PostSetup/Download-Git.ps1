#requires -version 5.1

[CmdletBinding(DefaultParameterSetName = "VM")]
Param(
    [Parameter(Mandatory, ParameterSetName = 'VM')]
    #specify the name of a VM
    [string]$VMName,
    [Parameter(Mandatory, ParameterSetName = 'VM')]
    #Specify the user credential
    [PSCredential]$Credential,
    [Parameter(Mandatory, ParameterSetName = "session")]
    #specify an existing PSSession object
    [System.Management.Automation.Runspaces.PSSession[]]$Session,
    [switch]$Install
)

Try {
    if ($PSCmdlet.ParameterSetName -eq 'VM') {
        Write-Host "Creating PSSession to $VMName" -ForegroundColor cyan

        $session = New-PSSession @PSBoundParameters -ErrorAction stop
    }

    $sb = {
        Param([switch]$Install)

        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

        #download the latest 64bit version of Git for Windows
        $uri = 'https://git-scm.com/download/win'
        #path to store the downloaded file
        $path = "C:\"
        Write-Host "Getting latest version of git from $uri" -ForegroundColor cyan
        #get the web page
        $page = Invoke-WebRequest -Uri $uri -UseBasicParsing -DisableKeepAlive

        #get the download link
        $dl = ($page.links | where-object outerhtml -match 'git-.*-64-bit.exe' | Select-Object -first 1 * ).href
        Write-Host "Found download link $dl" -ForegroundColor cyan

        #split out the filename
        $filename = split-path $dl -leaf

        #construct a filepath for the download
        $out = Join-Path -Path $path -ChildPath $filename
        Write-Host "Downloading $out from $dl" -ForegroundColor cyan

        #download the file
        Try {
            Invoke-WebRequest -uri $dl -OutFile $out -UseBasicParsing -DisableKeepAlive -ErrorAction Stop

            if ($install) {
                &$out /verysilent /norestart /suppressmessageboxes
            }
            else {
                #check it out
                Get-Item $out
            }
        }
        Catch {
            Throw $_
        }
    }

    Invoke-Command -ScriptBlock $sb -Session $session -ArgumentList $Install

    if ($PSCmdlet.ParameterSetName -eq 'VM') {
        Write-Host "Removing PSSession" -ForegroundColor cyan
        $Session | Remove-PSSession
    }
}
Catch {
    Throw $_
}


