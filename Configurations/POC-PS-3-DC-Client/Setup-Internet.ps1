

Function Set-Internet {
    Param(
         [Parameter(Mandatory=$False)]
         [string]$LabSwitchName = 'LabNet',

         [Parameter(Mandatory=$False)]
         [string]$GatewayIP = '192.168.3.1',

         [Parameter(Mandatory=$False)]
         [byte]$GatewayPrefix = '24',

         [Parameter(Mandatory=$False)]
         [string]$NatNetwork = '192.168.3.0/24',

         [Parameter(Mandatory=$False)]
         [string]$NatName = 'LabNat'

    )

        $Index = Get-NetAdapter -name "vethernet ($LabSwitchName)" | Select-Object -ExpandProperty InterfaceIndex
        New-NetIPAddress -InterfaceIndex $Index -IPAddress $GatewayIP -PrefixLength $GatewayPrefix
        # Creating the NAT on Server 2016 -- maybe not work on 2012R2
        New-NetNat -Name $NatName -InternalIPInterfaceAddressPrefix $NatNetwork   
}

Set-Internet


