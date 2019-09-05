#requires -version 5.1

<#
Download Sysinternals tools from web to a local folder in a VM

  ****************************************************************
  * DO NOT USE IN A PRODUCTION ENVIRONMENT UNTIL YOU HAVE TESTED *
  * THOROUGHLY IN A LAB ENVIRONMENT. USE AT YOUR OWN RISK.  IF   *
  * YOU DO NOT UNDERSTAND WHAT THIS SCRIPT DOES OR HOW IT WORKS, *
  * DO NOT USE IT OUTSIDE OF A SECURE, TEST SETTING.             *
  ****************************************************************
#>


[CmdletBinding(DefaultParameterSetName="VM")]
Param(
    [Parameter(Mandatory,ParameterSetName='VM')]
    #specify the name of a VM
    [string]$VMName,
    [Parameter(Mandatory,ParameterSetName='VM')]
    #Specify the user credential
    [pscredential]$Credential,
    [Parameter(Mandatory,ParameterSetName="session")]
    #specify an existing PSSession object
    [System.Management.Automation.Runspaces.PSSession[]]$Session
)

Try {
    if ($PSCmdlet.ParameterSetName -eq 'VM') {
        Write-Host "Creating PSSession to $VMName" -ForegroundColor cyan
        $session = New-PSSession @PSBoundParameters -ErrorAction stop
    }

    $sb = {
        [string]$Destination = "C:\SysInternals"
        if (-Not (Test-Path $Destination)) {
            new-Item -Path $Destination -ItemType Directory
        }

        #start the WebClient service if it is not running
        if ((Get-Service WebClient).Status -eq 'Stopped') {
             Write-host "Starting WebClient" -ForegroundColor Magenta
             #always start the webclient service even if using -Whatif
             Start-Service WebClient -WhatIf:$false
             $Stopped = $True
        }
        else {
            <#
             Define a variable to indicate service was already running
             so that we don't stop it. Making an assumption that the
             service is already running for a reason.
            #>
            $Stopped = $False
        }

        Write-Host "Updating Sysinternals tools from \\live.sysinternals.com\tools to $destination" -ForegroundColor Cyan

        Get-ChildItem -path \\live.sysinternals.com\tools -file | Copy-Item -Destination $Destination -PassThru

        <#
        alternative but this might still copy files that haven't
        really changed
        Robocopy \\live.sysinternals.com\tools $destination /MIR
        #>

        if ( $Stopped ) {
            Write-host "Stopping web client" -ForegroundColor Magenta
            #always stop the service even if using -Whatif
            Stop-Service WebClient -WhatIf:$False
        }

        Write-Host "Sysinternals Update Complete" -ForegroundColor Cyan
        }

       Invoke-Command -ScriptBlock $sb -Session $session

       if ($PSCmdlet.ParameterSetName -eq 'VM') {
            Write-Host "Removing PSSession" -ForegroundColor cyan
            $Session | Remove-PSSession
        }
}
Catch {
    Throw $_
}

