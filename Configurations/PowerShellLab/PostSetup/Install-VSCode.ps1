#requires -version 5.1

#Download and install the latest 64bit version of VSCode

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
    [System.Management.Automation.Runspaces.PSSession]$Session
)

#download the setup file on the host and then copy to VM to avoid strange name resolution problems
$path = $env:temp
$uri = 'https://vscode-update.azurewebsites.net/latest/win32-x64/stable'
# 'https://vscode-update.azurewebsites.net/latest/win32-x64/stable'
# 'https://go.microsoft.com/fwlink/?Linkid=852157'
$out = Join-Path -Path $Path -ChildPath VSCodeSetup-x64.exe

Try {
    Write-Host " Downloading from $uri" -foreground magenta
    Invoke-WebRequest -Uri $uri -OutFile $out -DisableKeepAlive -UseBasicParsing
}
Catch {
    Throw $_
    #bail out
    Return
}

Try {
    if ($PSCmdlet.ParameterSetName -eq 'VM') {
        Write-Host "Creating PSSession to $VMName" -ForegroundColor cyan
        $session = New-PSSession @PSBoundParameters -ErrorAction stop
    }

    #copy the file to the VM
    copy-item -Path $out -Destination C:\ -ToSession $Session

    $sb = {
        $file = 'C:\VSCodeSetup-x64.exe'
        Write-Host "[$($env:computername)] Installing VSCode" -foreground magenta
        $loadInf = '@
[Setup]
Lang=english
Dir=C:\Program Files\Microsoft VS Code
Group=Visual Studio Code
NoIcons=0
Tasks=desktopicon,addcontextmenufiles,addcontextmenufolders,addtopath
@'
        $infPath = "${env:TEMP}\load.inf"
        $loadInf | Out-File $infPath

        Start-Process -FilePath $file -ArgumentList "/VERYSILENT /LOADINF=${infPath}" -Wait
        Write-Host "[$($env:computername)] Finished Installing VSCode" -foreground magenta
    } #close scriptblock

    Invoke-Command -ScriptBlock $sb -Session $session

    if ($PSCmdlet.ParameterSetName -eq 'VM') {
        Write-Host "Removing PSSession" -ForegroundColor cyan
        $Session | Remove-PSSession
    }
}
Catch {
    Throw $_
}

