# This resource can be used to install an ADCS Online Responder after the feature has been installed on the server.
# For more information on ADCS Online Responders, see https://technet.microsoft.com/en-us/library/cc725958.aspx

#region Get Resource
Function Get-TargetResource
{
    [OutputType([System.Collections.Hashtable])]
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [String] $IsSingleInstance, 

        [Parameter(Mandatory = $true)]
        [ValidateSet('Present','Absent')]
        [string] $Ensure = 'Present',

        [Parameter(Mandatory = $true)]
        [pscredential] $Credential
    )

    $ADCSParams = @{
        IsSingleInstance = $IsSingleInstance
        Credential = $Credential
        Ensure = $Ensure
    }

    $ADCSParams += @{
        StateOK = Test-TargetResource @ADCSParams
    }
    Return $ADCSParams
}
#endregion

#region Set Resource
Function Set-TargetResource
{
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [String] $IsSingleInstance, 

        [Parameter(Mandatory = $true)]
        [ValidateSet('Present','Absent')]
        [string] $Ensure = 'Present',

        [Parameter(Mandatory = $true)]
        [pscredential] $Credential
    )

    $ADCSParams = @{
        Credential = $Credential
    }

    switch ($Ensure)
    {
        'Present'
        {
            (Install-AdcsOnlineResponder @ADCSParams -Force).ErrorString
        }
        'Absent'
        {
            (Uninstall-AdcsOnlineResponder -Force).ErrorString
        }
    } # Switch
}
#endregion

#region Test Resource
Function Test-TargetResource
{
    [OutputType([System.Boolean])]
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [String] $IsSingleInstance,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Present','Absent')]
        [string] $Ensure = 'Present',

        [Parameter(Mandatory = $true)]
        [pscredential] $Credential
    )

    $ADCSParams = @{
        Credential = $Credential
    }

    try
    {
        $null = Install-AdcsOnlineResponder @ADCSParams -WhatIf
        Switch ($Ensure)
        {
            'Present'
            {
                return $false
            }
            'Absent'
            {
                return $true
            }
        } # Switch
    }
    catch
    {
        Write-verbose -Verbose $_
        Switch ($Ensure)
        {
            'Present'
            {
                return $true
            }
            'Absent'
            {
                return $false
            }
        } # Switch
    } # try
}
#endregion

Export-ModuleMember -Function *-TargetResource
