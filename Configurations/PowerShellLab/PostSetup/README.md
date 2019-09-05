# Post Setup

The PowerShell scripts in this directory can be run after the lab setup is complete. You can use these scripts to perform some additional configuration of the virtual machines.  Because these files are all PowerShell scripts you need to specify the full path to the file. If you are in the current directory you can use a .\ to reference the current location.

Usage of these scripts is completely optional and are provided for your convenience. You may elect to manually accomplish these tasks from the PostSetup folder. For any installations to the Windows 10 client, you should launch an interactive session first to the virtual machine with the credential you intend to use to force a profile creation.

```powershell
vmconnect localhost Win10
```

## Run-WindowsUpdate.ps1

Use this script to run Windows Update on one or more virtual machines. The script will install all updates. The process may take some time depending on the number of virtual machines.

```powershell
.\Run-WindowsUpdate -vmname srv1,srv2,win10 -credential company\administrator
```

The credential you specify will be used for all virtual machines. The default password should be `P@ssw0rd`.
You can also run the command as a background job.

```powershell
.\Run-WindowsUpdate -vmname srv3 -credential srv3\administrator -asjob
```

When finished, you can retrieve the job results.

```powershell
PS C:\AutoLabConfigurations\PowerShellLab\PostSetup> receive-job 12 -keep
[SRV3] Create update session objects
[SRV3] Retrieving available updates
[SRV3] Retrieved 2 updates
[SRV3] Processing 2 updates
[SRV3] Installing 2 updates
[SRV3] Installing 2017-08 Update for Windows Server 2016 for x64-based Systems (KB4035631)


RebootRequired : True
InstallDate    : 10/4/2017 2:59:19 PM
Result         : Success
Computername   : SRV3
Severity       :
Title          : 2017-08 Update for Windows Server 2016 for x64-based Systems (KB4035631)
PSComputerName : SRV3
RunspaceId     : 3591e46b-e37f-42e0-a516-388f63ecc105

[SRV3] Installing 2017-09 Cumulative Update for Windows Server 2016 for x64-based Systems (KB4038782)
RebootRequired : False
InstallDate    : 10/4/2017 2:59:26 PM
Result         : Success
Computername   : SRV3
Severity       : Critical
Title          : 2017-09 Cumulative Update for Windows Server 2016 for x64-based Systems (KB4038782)
PSComputerName : SRV3
RunspaceId     : 3591e46b-e37f-42e0-a516-388f63ecc105

[SRV3] One or more updates requires a reboot.
```

You can then remove any PSSessions.

```powershell
get-pssession | remove-pssession
```

## Install-SysInternals.ps1

Use this script to download the SysInternals suite from Microsoft. All of the files will be stored in a new folder, `C:\Sysinternals`. It is assumed you will only need to run this for the client virtual machine.

```powerShell
.\Install-SysInternals -vmname win10 -credential company\administrator
```

If you already have an existing PSSession to the virtual machine you can use that instead:

```powershell
.\Install-SysInternals -session $sess
```

## Download-Git.ps1

This script will download the current Windows version of the git setup file. The file will be saved to the root of C:\. You will need to manually setup and configure git in the virtual machine.

```powershell
.\Download-Git -VMName win10 -Credential company\artd
```

If you already have an existing PSSession to the virtual machine you can use that of the VMName and credential.

## Install-VSCode.ps1

This script will download and install the current version of Visual Studio Code. The file will be saved to the root of C:\. It is assumed you will run this for the client virtual machine.

```powershell
.\Install-VSCode -vmname win10 -credential company\aprils
```

If you already have an existing PSSession to the virtual machine you can use that of the VMName and credential.
Once installed, you can logon as and finish configuration such as installing the PowerShell VSCode extension.

## Notes

If you want to restart all of the virtual machines, use a command like this:

```powershell
Get-VM Dom1,Srv*,Win10 | Stop-VM -force -passthru | Start-VM -passthru
```

The virtual machines must be running before using any of these scripts.
