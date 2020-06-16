# Authoring FAQ

This guide is intended for people who are creating their own lab configurations.If you want to do so, the best approach is to make a copy of a configuration folder that is closest to what you want and then modify those files.

**It is not recommended to attempt to author your own configuration without solid PowerShell, Desired State Configuration and Hyper-V experience.**

## How do I specify a different operating system

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

You will need to change the `Lability_Media` section. At a PowerShell prompt run `Get-LabMedia`. Copy the appropriate ID and replace the `Lability_Media` value. The first time you build the configuration with new media, the corresponding ISO file will be downloaded.

## I'm getting an error when my VM is booting for the first time

Full error: *Windows could not parse or process the unattend answer file [C:\Windows\system32\sysprep\unattend.xml] for pass [specialize]. The answer file is invalid.*

Make sure that the configuration changes you've made are valid. Specifically, this error is known to be caused by an invalid NodeName. NodeName on Windows must match the rules for a Windows Computer Name, notably a 15 character maximum. See details here: https://support.microsoft.com/en-us/kb/909264

## How can I avoid issues when changing VM names

Use `Wipe-Lab` before changing names (i.e `NodeName` or `EnvironmentPrefix`), otherwise Wipe-Lab won't work and you'll have to manually cleanup previously created VMs.

## How can I manually clean up a lab

Normally, when you run `Wipe-Lab` that should handle everything for you. But if there is a problem you can take these manual steps.

+ Open the Hyper-V manager and manually shutdown or turn off the virtual machines in your lab configuration.
+ In the Hyper-V manager, manually select each virtual machine and delete it.
+ Open Windows Explorer or a PowerShell prompt and change to the configuration directory.
+ Manually delete any MOF files.
+ Change to C:\Autolab\VMVirtualDisks (or the drive where you have Autolab configured).
+ Manually delete any files that are named with virtual machines from your configuration.

## How can I change a VM's timezone

1. First, find your desired timezone using one of these PowerShell commands:

```powershell
# Filter all timezones, take the Id property from the desired timezone:
[System.TimeZoneInfo]::GetSystemTimeZones().Where({$_.Id -like '*Eastern*'})

# Get your current timezone:
(Get-TimeZone).Id
```

2. Open the lab's `Lab-Name.psd1` and change `Lability_timeZone` per Node.

Another option is to use the `-UseLocalTimeZone` parameter when running `Setup-Lab` or `Unattend-Lab`. This will configure all virtual machines in the lab configuration to use the same time zone as the local host.

### last updated 2020-04-23 18:21:49Z UTC
