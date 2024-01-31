Function Enable-Internet {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
        [Parameter(HelpMessage = "The path to the configuration folder. Normally, you should run all commands from within the configuration folder.")]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { Test-Path $_ })]
        [String]$Path = ".",
        [Parameter(HelpMessage = "Run the command but suppress all status messages.")]
        [Switch]$NoMessages
    )

    $Path = Convert-Path $path

    if (-Not $NoMessages) {

        Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Green -Object @"

        This is the Enable-Internet script. This script will perform the following:

        * Enable Internet to the VM's using NAT

        * Note! - If this generates an error, you are already enabled, or one of the default settings below
        does not match your .PSD1 configuration
"@
    }

    $LabData = Import-PowerShellDataFile -Path $path\*.psd1
    $LabSwitchName = $LabData.NonNodeData.Lability.Network.name
    $GatewayIP = $LabData.AllNodes.DefaultGateway
    $GatewayPrefix = $LabData.AllNodes.SubnetMask
    $NatNetwork = $LabData.AllNodes.IPnetwork
    $NatName = $LabData.AllNodes.IPNatName

    $Index = Get-NetAdapter -Name "vethernet ($LabSwitchName)" | Select-Object -ExpandProperty InterfaceIndex

    if ($PSCmdlet.ShouldProcess("Interface index $index", "New-NetIPAddress")) {
        New-NetIPAddress -InterfaceIndex $Index -IPAddress $GatewayIP -PrefixLength $GatewayPrefix -ErrorAction SilentlyContinue
    }

    # Creating the NAT on Server 2016 -- maybe not work on 2012R2
    if ($PSCmdlet.ShouldProcess($NatName, "New-NetNat")) {
        New-NetNat -Name $NatName -InternalIPInterfaceAddressPrefix $NatNetwork -ErrorAction SilentlyContinue
    }

    if (-Not $NoMessages) {

        Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Green -Object @"

        Next Steps:

        When complete, run:
        Run-Lab

        And run:
        Validate-Lab

"@
    }
}
