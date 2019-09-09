## Usage FAQ

__This document is under review and update.__

*"I get an error about my network connection type being set to Public."*

### Full error:

```powershell
Set-WSManQuickConfig : <f:WSManFault xmlns:f="http://schemas.microsoft.com/wbem/wsman/1/wsmanfault" Code="2150859113" Machine="localhost"><f:Message><f:ProviderFault provider="Config provider" path="%systemroot%\system32\WsmSvc.dll"><f:WSManFault xmlns:f="http://schemas.microsoft.com/wbem/wsman/1/wsmanfault" Code="2150859113" Machine="tablet"><f:Message>WinRM firewall exception will not work since one of the network connection types on this machine is set to Public. Change the network connection type to either Domain or Private and try again. </f:Message></f:WSManFault></f:ProviderFault></f:Message></f:WSManFault>
At line:116 char:17
+                 Set-WSManQuickConfig -force
+                 ~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: (:) [Set-WSManQuickConfig], InvalidOperationException
    + FullyQualifiedErrorId : WsManError,Microsoft.WSMan.Management.SetWSManQuickConfigCommand
```

### Fix:

```powershell
# Find connections with a NetworkCategory set to Public
Get-NetConnectionProfile

# For each connection, change to Private or Domain
Set-NetConnectionProfile -InterfaceIndex 3 -NetworkCategory Private
```

*Enable-Internet.ps1 fails on New-NetNat : The parameter is incorrect.*

Full error:

```text
New-NetNat : The parameter is incorrect.
At C:\Lability\Configurations\POC-StandAlone-Server-GUI\Enable-Internet.ps1:50 char:9
+         New-NetNat -Name $NatName -InternalIPInterfaceAddressPrefix $ ...
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
+ CategoryInfo          : InvalidArgument: (MSFT_NetNat:root/StandardCimv2/MSFT_NetNat) [New-NetNat], CimException
+ FullyQualifiedErrorId : Windows System Error 87,New-NetNat
```

Currently, Hyper-V only supports a single NAT network, you can read more about this here:
https://blogs.technet.microsoft.com/virtualization/2016/05/25/windows-nat-winnat-capabilities-and-limitations/.
Likely, if you receive the error above, you already have a NAT network created.
For example, `Docker for Windows` creates a DockerNAT virtual switch and NAT network.
You can check if this is the case with the `Get-NetNat` PowerShell cmdlet.
If you get back a NAT network object, then you won't be able to create another one for your lab.

The solution is to coordinate a single NAT network so it covers all of your NAT networking needs.
- That likely means creating a larger NAT subnet that covers the IP ranges of all of your networks.
- Which also means coordinating IP ranges across apps so they can fall under a single NAT subnet.
- Also, the NAT subnet cannot overlap with the external network that the host is attached to. So if a host is attached to 192.168.0.0/24, you can't use 192.168.0.0/16 as a NAT network.

Here's a visualization from the above limitations article:
![overlapping prefixes](https://msdnshared.blob.core.windows.net/media/2016/05/Overlapping-Internal-Prefixes.jpg)

Refer to this article for help on creating NAT networks: https://msdn.microsoft.com/en-us/virtualization/hyperv_on_windows/user_guide/setup_nat_network

Here are some helpful PowerShell commands

### List NAT networks, take note of the IP range and subnet

```powershell
Get-NetNat
```

### Remove an existing NAT network called DockerNAT

```powershell
Remove-NetNat DockerNAT
```

### Create a NAT network with coordinated subnet

```powershell
New-NetNat -Name DockerAndLabilityNAT -InternalIPInterfaceAddressPrefix "10.10.0.0/16"
```

Docker for Windows network settings can be updated from the windows tray icon. Lab network changes require updating both `Enable-Internet.ps1` and the `Lab.psd1` files.
