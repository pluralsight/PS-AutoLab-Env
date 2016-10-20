## Authoring FAQ

### I'm getting an error when my VM is booting for the first time: *Windows could not parse or process unattend answer file*

Full error: *Windows could not parse or process unattend answer file [C:\Windows\system32\sysprep\unattend.xml] for pass [specialize]. The answer file is invalid.*

Make sure that the configuration changes you've made are valid. 
Specifically, this error is known to be caused by an invalid NodeName. 
NodeName on Windows must match the rules for a Windows Computer Name, notably a 15 character maximum.  
See details here: https://support.microsoft.com/en-us/kb/909264

### How can I avoid issues when changing VM names?

Use `Wipe-Lab` before changing names (i.e `NodeName` or `EnvironmentPrefix`), 
otherwise Wipe-Lab won't work and you'll have to manually cleanup previously created VMs.

### How can I manually clean up a lab?

**todo**

### How can I change a VM's timezone?

1. First, find your desired timezone:

```ps1
# Filter all timezones, take the Id property from the desired timezone:
[System.TimeZoneInfo]::GetSystemTimeZones().Where({$_.Id -like '*Eastern*'})

# Get your current timezone: 
(Get-TimeZone).Id

```
2. Open the lab's `Lab-Name.psd1` and change `Lability_timeZone` per Node. 
