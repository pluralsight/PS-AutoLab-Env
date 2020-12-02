# Usage FAQ

These are some common questions you might have about this module or errors that you might encounter. Although most of this document is retained merely for archival reference purposes. If you haven't already done so, you should read the [README](https://github.com/pluralsight/PS-AutoLab-Env/blob/master/README.md) file. And don't forget the [About_PSAutolab](https://github.com/pluralsight/PS-AutoLab-Env/blob/master/docs/about_PSAutoLab.md) file.

+ __I get an error trying to update Lability__

If you try to run `Refresh-Host` you might see an error about a certificate mismatch. Between v0.18.0 and v0.19.0 the Lability module changed code signing certificates. If you encounter this problem, run `Refresh-Host -SkipPublisherCheck`.

+ __I get an error about trying to modify TrustedHosts__

The module commands must be able to use PowerShell remoting to configure and test the virtual machines within a configuration. Because there is no Kerberos authentication between the local host and the virtual machines, you need to configure TrustedHosts. If TrustedHosts can't be configured, you will likely encounter errors. You should make sure remoting is enabled on the localhost. Run this command.

```powershell
Test-WSMan
```

If you get errors, you may need to enable PowerShell remoting.

```powershell
Enable-PSRemoting
```

Ensure that you are running an elevated PowerShell session (Run as Administrator). **If your TrustedHosts configuration is managed by Group Policy, it is unlikely you will be able to use this module.**

+ __I get an error about my network connection type being set to Public.__

You might see this error message:

```text
Set-WSManQuickConfig : <f:WSManFault xmlns:f="http://schemas.microsoft.com/wbem/wsman/1/wsmanfault" Code="2150859113" Machine="localhost"><f:Message><f:ProviderFault provider="Config provider" path="%systemroot%\system32\WsmSvc.dll"><f:WSManFault xmlns:f="http://schemas.microsoft.com/wbem/wsman/1/wsmanfault" Code="2150859113" Machine="tablet"><f:Message>WinRM firewall exception will not work since one of the network connection types on this machine is set to Public. Change the network connection type to either Domain or Private and try again. </f:Message></f:WSManFault></f:ProviderFault></f:Message></f:WSManFault>
At line:116 char:17
+                 Set-WSManQuickConfig -force
+                 ~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: (:) [Set-WSManQuickConfig], InvalidOperationException
    + FullyQualifiedErrorId : WsManError,Microsoft.WSMan.Management.SetWSManQuickConfigCommand
```

To solve this you can try to modify the connection profile.

```powershell
# Find connections with a NetworkCategory set to Public
Get-NetConnectionProfile

# For each connection, change to Private or Domain
Set-NetConnectionProfile -InterfaceIndex 3 -NetworkCategory Private
```

+ __Enable-Internet fails on New-NetNat__

You might get an error like "The parameter is incorrect."

```text
New-NetNat : The parameter is incorrect.
At C:\Lability\Configurations\POC-StandAlone-Server-GUI\Enable-Internet.ps1:50 char:9
+         New-NetNat -Name $NatName -InternalIPInterfaceAddressPrefix $ ...
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
+ CategoryInfo          : InvalidArgument: (MSFT_NetNat:root/StandardCimv2/MSFT_NetNat) [New-NetNat], CimException
+ FullyQualifiedErrorId : Windows System Error 87,New-NetNat
```

Currently, Hyper-V only supports a single NAT network, you can read more about this here:
[https://blogs.technet.microsoft.com/virtualization/2016/05/25/windows-nat-winnat-capabilities-and-limitations/](https://blogs.technet.microsoft.com/virtualization/2016/05/25/windows-nat-winnat-capabilities-and-limitations/).

Likely, if you receive the error above, you already have a NAT network created. For example, `Docker for Windows` creates a DockerNAT virtual switch and NAT network. You can check if this is the case with the `Get-NetNat` PowerShell cmdlet. If you get back a NAT network object, then you won't be able to create another one for your lab. The solution is to coordinate a single NAT network so it covers all of your NAT networking needs.

+ That likely means creating a larger NAT subnet that covers the IP ranges of all of your networks.
+ Which also means coordinating IP ranges across apps so they can fall under a single NAT subnet.
+ The NAT subnet cannot overlap with the external network that the host is attached to. If a host is attached to 192.168.0.0/24, you can't use 192.168.0.0/16 as a NAT network.

Here's a visualization from the above limitations article:

![overlapping prefixes](https://msdnshared.blob.core.windows.net/media/2016/05/Overlapping-Internal-Prefixes.jpg)

Refer to this article for help on creating NAT networks: [https://msdn.microsoft.com/en-us/virtualization/hyperv_on_windows/user_guide/setup_nat_network](https://msdn.microsoft.com/en-us/virtualization/hyperv_on_windows/user_guide/setup_nat_network)

Run this command to list NAT networks, take note of the IP range and subnet

```powershell
Get-NetNat
```

If you have an existing that is conflicting, _and that no longer need_, remove it . Here's an example removing an existing NAT network called DockerNAT

```powershell
Remove-NetNat DockerNAT
```

You can then create a NAT network using the corresponding subnet.

```powershell
New-NetNat -Name DockerAndLabilityNAT -InternalIPInterfaceAddressPrefix "192.168.3.0/24"
```

Docker for Windows network settings can be updated from the windows tray icon. Lab network changes require modifying the module's source code. If you are running Docker for Windows *and* the PSAutoLab module, please post an issue on GitHub.

+ __How can I change a virtual machine's timezone?__

First, find your desired timezone using one of these techniques:

```powershell
# Filter all timezones, take the Id property from the desired timezone:
[System.TimeZoneInfo]::GetSystemTimeZones()
[System.TimeZoneInfo]::GetSystemTimeZones().Where({$_.Id -like '*Eastern*'})

# Get your current timezone:
(Get-TimeZone).Id
```

Next, open the lab's `VMConfigurationData.psd1` in your script editor and change `Lability_timeZone` per Node.

```powershell
 @{
            NodeName                = 'Win10Ent'
            IPAddress               = '192.168.3.101'
            Role                    = @('RSAT','RDP')
            Lability_ProcessorCount = 2
            Lability_MinimumMemory  = 2GB
            Lability_Media          = 'WIN10_x64_Enterprise_EN_Eval'
            Lability_BootOrder      = 20
            Lability_timeZone       = 'Central Standard Time' #[System.TimeZoneInfo]::GetSystemTimeZones()
            Lability_Resource       = @()
        }
```

Or, when you run `Setup-Lab` or `Unattend-Lab` you can use the `UseLocalTimeZone` parameter to set the time zone for all lab members to use the same time zone as the local host.

+ __How can I avoid issues when changing VM names?__

Use `Wipe-Lab` before changing names (i.e `NodeName` or `EnvironmentPrefix`), otherwise `Wipe-Lab` won't work and you'll have to manually cleanup previously created VMs.

+ __How can I manually clean up a lab?__

Normally, when you run `Wipe-Lab` that should handle everything for you. But if there is a problem you can take these manual steps.

+ Open the Hyper-V manager and manually shutdown or turn off the virtual machines in your lab configuration.
+ In the Hyper-V manager, manually select each virtual machine and delete it.
+ Open Windows Explorer or a PowerShell prompt and change to the configuration directory.
+ Manually delete any MOF files.
+ Change to C:\Autolab\VMVirtualDisks (or the drive where you have Autolab configured).
+ Manually delete any files that are named with virtual machines from your configuration.

## Authoring a Custom Configuration

The expectation is that one of the included configurations will meet your needs or has been specified by a Pluralsight author.However, are free to modify or create your own configuration. This process assumes you have experience with writing Desired State Configuration (DSC) scripts, including the use of configuration data files (*.psd1) and Pester. Because configurations might be updated in future versions of the PSAutoLab module, you are encouraged to create a new configuration and not edit existing files.

Find a configuration that is close to your needs and copy it to a new folder under `Autolab\Configurations`. Technically, you can put the configuration folder anywhere but it is easier if all of your configurations are in one location.

Once the files have been copied, use your script editor to modify the files. Don't forget to update the Pester test.
You should keep the same file names.

### Specify a Different Operating System

First, find the node information in the VMConfigurationData.psd1 file.

```powershell
@{
    NodeName           = 'S1'
    IPAddress          = '192.168.3.50'
    #Role = 'DomainJoin' # example of multiple roles @('DomainJoin', 'Web')
    Role               = @('DomainJoin', 'Web')
    Lability_BootOrder = 20
    Lability_timeZone  = 'US Mountain Standard Time' #[System.TimeZoneInfo]::GetSystemTimeZones()
    Lability_Media     = '2019_x64_Standard_EN_Core_Eval'
}
```

You will need to change the `Lability_Media` section. At a PowerShell prompt, run `Get-LabMedia`. Copy the appropriate ID and replace the `Lability_Media` value. The first time you build the configuration with new media, the corresponding ISO file will be downloaded.

### I'm getting an error when my VM is booting for the first time

You might see this error message.

```text
Full error: *Windows could not parse or process the unattend answer file [C:\Windows\system32\sysprep\unattend.xml] for pass [specialize]. The answer file is invalid.*
```

Make sure that the configuration changes you've made are valid. Specifically, this error is known to be caused by an invalid NodeName. NodeName on Windows must match the rules for a Windows Computer Name, notably a 15 character maximum. See details here: [https://support.microsoft.com/en-us/kb/909264](https://support.microsoft.com/en-us/kb/909264)

## I'm Still Stuck

For all other questions, comments or problems, please post an [Issue](https://github.com/pluralsight/PS-AutoLab-Env/issues) in this repository.

Last updated 2020-10-06 15:37:01Z
