# Detailed Setup Instructions

Please refer to this document to assist in installing and setting up the `PSAutolab` module on your computer.
Run all commands from an **elevated** Windows PowerShell session.
In other words, *run Windows PowerShell as administrator*.
You will know you are elevated if you see the word `Administrator` in the title bar of the PowerShell window.
Do NOT run this module in PowerShell 7.
It is also assumed you are running this on Windows 10 Professional or Enterprise editions.

It is assumed that you have administrator rights to your computer and can makes changes.
If your computer is controlled by Group Policy, you may encounter problems.

> It is *possible* to run this module with nested virtualization inside a Windows 10 Hyper-V virtual machine but it is **not** recommended.
> Some networking features may not work properly and overall performance will be reduced.

## Pre-Check

Run these commands to verify your computer meets the minimum requirements.

### Operating System and Memory

```powershell
PS C:\> Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object Caption,@{Name="MemoryGB";Expression={$_.TotalVisibleMemorySize/1mb -as [int]}}

Caption                  MemoryGB
-------                  -----
Microsoft Windows 10 Pro    32
```

If the Caption shows anything other than Pro or Enterprise this module will not work.
In fact, if you can't even open a PowerShell prompt, this module won't work on your computer.
The memory size should be at least 12. 16 or greater is recommended.
If the number is less than 12, **STOP**.
It is unlikely you have enough installed memory.
Depending on the configuration you want to run, it might be possible to proceed with less memory.
Open an Issue and ask for guidance indicating your memory settings from this command:

```powershell
PS C:\> Get-CimInstance Win32_OperatingSystem | Select-Object FreePhysicalMemory,TotalVisibleMemorySize

FreePhysicalMemory TotalVisibleMemorySize
------------------ ----------------------
          14357500               33442716
```

Also indicate what configuration you are hoping to run.

### PowerShell Remoting

The module relies on PowerShell remoting which should be enabled **before** installing and using this module.

```powershell
PS C:\> test-wsman

wsmid           : http://schemas.dmtf.org/wbem/wsman/identity/1/wsmanidentity.xsd
ProtocolVersion : http://schemas.dmtf.org/wbem/wsman/1/wsman.xsd
ProductVendor   : Microsoft Corporation
ProductVersion  : OS: 0.0.0 SP: 0.0 Stack: 3.0
```

This is what you should see as a result.
Any errors mean that PowerShell remoting is disabled.
Enable it from your elevated PowerShell session.
This will fail if your only network connection is over a public network.

```powershell
PS C:\ Enable-PSRemoting -force
```

If this fails, **STOP**.
Do not proceed with this module until this is working and `Test-WSMan` gives you a result.
If you are running as Administrator and this command fails it is most likely because the related settings are controlled by a Group Policy or your network is public.
Run `Get-NetConnectionProfile` and look at the NetworkCategory.
If must be `Private` or `DomainAuthenticated`.

### Disk Space

The module requires a lot of disk space for the virtual machines and ISO files.
Run this command to see how much free space you have.

```powershell
PS C:\> get-volume
Drive  SizeGB  FreeGB PercentFree HealthStatus
-----  ------  ------ ----------- ------------
E           0       0             Healthy
            0       0       88.18 Healthy
            1       1       57.65 Healthy
D         477     183       38.41 Healthy
C         237      87       36.71 Healthy
```

You should have close to 100GB of free space on a fixed hard drive such as C or D.
This module has not been tested running off of a USB connected drive.

### Virtualization

The module requires the Hyper-V feature.
Please refer to documentation for your computer to determine if it supports virtualization.
You may need to enable it in your BIOS.
You don't need to manually enable the Hyper-V feature now, although you are welcome to if you want to verify it is available.

## Installation and Configuration

### Install the Module

If you meet the requirements, you are ready to download and install this module.
**Do not download anything from this GitHub repository.**
In your PowerShell session run this command:

```powershell
PS C:\> Install-Module PSAutolab -force
```

You may be prompted to update to a newer version of `nuget`.
Say yes.
To verify use `Get-Module`.

```powerShell
PS C:\> Get-Module psautolab -list

    Directory: C:\Program Files\WindowsPowerShell\Modules


ModuleType Version    Name                                ExportedCommands
---------- -------    ----                                ----------------
Script     4.7.0      PSAutoLab                           {Enable-Internet, Invoke-RefreshLab, Invoke-RunLab, Invoke...
```

You may see a different version number.

### Setup the Host

You have to setup your computer one-time to use this module.
In your elevated PowerShell session run this command:

```powershell
PS C:\> Setup-Host
```

This command will create a directory structure for the module and all of its files.
The default is `C:\Autolab` which you should be able to accept.
If you are low on space or want to use an alternate drive, then you can specify an alternative top level path.

```powershell
PS C:\> Setup-Host -destinationpath D:\Autolab
```

This process will install additional modules and files.
If necessary, it will enable the Hyper-V feature.
If Hyper-V is enabled, please reboot your computer before proceeding.

To verify your configuration, run `Get-PSAutolabSetting`.

```powershell
PS C:\> Get-PSAutoLabSetting

PSVersion        : 5.1.18362.628
PSEdition        : Desktop
OS               : Microsoft Windows 10 Pro
MemoryGB         : 32
PctFreeMemory    : 40.58
IsElevated       : True
RemotingEnabled  : True
HyperV           : 10.0.18362.1
PSAutolab        : 4.8.0
Lability         : {0.19.1, 0.19.0, 0.18.0}
Pester           : 4.10.1
PowerShellGet    : 2.2.3
AutoLab          : C:\Autolab
AutoLabFreeSpace : 196644032512
```

If Hyper-V is not installed you will see errors.
Any errors indicate a problem with your setup.
Please post this information when reporting an issue.

### Setup a Configuration Unattended

In an elevated PowerShell session, **change directory** to the configuration folder that you want to use.

```powershell
PS C:\> cd C:\Autolab\Configurations\SingleServer-GUI-2016\
PS C:\Autolab\Configurations\SingleServer-GUI-2016>
```

You can look at the `instructions.md` file to get more information about the configuration.

```powershell
PS C:\Autolab\Configurations\SingleServer-GUI-2016> get-content .\Instructions.md
```

You can run `Unattend-Lab` for a completely hands-free experience.

```powershell
PS C:\Autolab\Configurations\SingleServer-GUI-2016> unattend-lab
```

The very first time you run a setup, the command will download ISO images of evaluation software from Microsoft.
These files will be at least 4GB in size.
If you are setting up a domain-based configuration, this means you will be downloading ISO images for Windows Server and Windows 10.
This download only happens once.

Note that during the validation phase you will see errors.
This is to be expected until all of the configurations merge.
You can press `Ctrl+C` to break out of the testing.
The virtual machines will continue to prepare themselves.

### Manual Configuration Setup

If you encounter errors running an unattended setup, it may have helpful to step through the process manually to identify where exactly and error is occuring. Make sure you are in an elevated PowerShell session and you have changed location to the configuration folder. If you have tried to setup the lab before run `Wipe-Lab` to remove previous set up files. Then run each of these commands individually:

* `Setup-Lab`
* `Enable-Internet`
* `Run-Lab`

Errors that affect setup should happen in one of these steps. If so, open an issue with configuration name, the step you were working on and the error message. Also include the output from `Get-PSAutolabSetting`.

After about 10 minutes, you can manually test to see if the configuration has finalized.

```powershell
Invoke-Pester .\Vmvalidate.test.ps1
```

You might still see errors, in which case try again in 10 minute intervals until the test completely passes.

### Help

All of the commands in this module have help and examples.
You are also encouraged to read the about help topic.

```powershell
PS C:\> help about_psautolab
```

## Getting Help

If encounter problems getting any of this to work, you are welcome to post an Issue.
If you get the module installed, please include the results of `Get-PSAutolabsetting`.
If your problem is meeting one of the requirements, we will do our best to help.
Although if your computer is locked down or otherwise controlled by corporate policies there may not be much that we can do.

last updated 2020-04-22 01:36:20Z UTC
