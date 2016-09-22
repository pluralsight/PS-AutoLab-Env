#region Get Resource
Function Get-TargetResource
{
    [OutputType([System.Collections.Hashtable])]
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [String] $IsSingleInstance,

        [ValidateSet('Present','Absent')]
        [string] $Ensure = 'Present',

        [string] $CAConfig,

        [Parameter(Mandatory = $true)]
        [pscredential] $Credential
    )

    $ADCSParams = @{
        IsSingleInstance = $IsSingleInstance
        Credential = $Credential
        Ensure = $Ensure        
    }

    if ($CAConfig)
    {
        $ADCSParams += @{
            CAConfig = $CAConfig
        }
    } # if

    $ADCSParams += @{
        IsCAWeb = Test-TargetResource @ADCSParams
    }
    return $ADCSParams
}
# Get-TargetResource -Name 'Test' -Credential (Get-Credential)
# Expected Outcome: Return a table of appropriate values.
#endregion

#region Set Resource
Function Set-TargetResource
{
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [String] $IsSingleInstance,

        [ValidateSet('Present','Absent')]
        [string] $Ensure = 'Present',

        [string] $CAConfig,

        [Parameter(Mandatory = $true)]
        [pscredential] $Credential
    )

    if (-not $CAConfig)
    {
        $ADCSParams = @{
            Credential = $Credential
        }
    }
    else
    {
        $ADCSParams = @{
            CAConfig = $CAConfig
            Credential = $Credential
        }
    } # if

    switch ($Ensure)
    {
        'Present'
        {
            (Install-AdcsWebEnrollment @ADCSParams -Force).ErrorString
        }
        'Absent'
        {
            (Uninstall-AdcsWebEnrollment -Force).ErrorString
        }
    } # switch
}
# Set-TargetResource -Name 'Test' -Credential (Get-Credential)
# Expected Outcome: Setup Certificate Services Web Enrollment on this node.
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

        [ValidateSet('Present','Absent')]
        [string] $Ensure = 'Present',

        [string] $CAConfig,

        [Parameter(Mandatory = $true)]
        [pscredential] $Credential
    )

    if (-not $CAConfig)
    {
        $ADCSParams = @{
            Credential = $Credential
        }
    }
    else
    {
        $ADCSParams = @{
            CAConfig = $CAConfig
            Credential = $Credential
        }
    } # if

    try
    {
        $null = Install-AdcsWebEnrollment @ADCSParams -WhatIf
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
        } # switch
    }
    catch
    {
        Write-verbose $_
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
        } # switch
    } # try
}
# Test-TargetResource -Name 'Test' -Credential (Get-Credential)
# Expected Outcome: Returns a boolean indicating whether Certificate Services Web Enrollment is installed on this node.
#endregion

Export-ModuleMember -Function *-TargetResource
