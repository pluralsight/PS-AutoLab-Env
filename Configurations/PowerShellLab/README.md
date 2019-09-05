# PowerShellLab

These files are used for configuration with the [PSAutolab](https://github.com/pluralsight/PS-AutoLab-Env) project. The intent is to setup a small domain environment for testing and teaching Windows PowerShell 5.1.

If you are using the newer PSAutolab project, version 4.0.0 or later, this configuration is already included.

## Instructions

To use the scripts and configurations, download the [current release ](https://github.com/jdhitsolutions/PowerShellLab/archive/0.10.0.zip). Extract the contents of the zip file folder to your Autolab Configurations directory. You should end up with something like C:\Autolab\Configurations\PowerShellLab which contains the files from this repository.

```powershell
PS C:\> dir C:\Autolab\Configurations\PowerShellLab\


    Directory: C:\Autolab\Configurations\PowerShellLab


Mode                LastWriteTime         Length Name
----                -------------         ------ ----
d-----        8/25/2017   7:35 PM                PostSetup
-a----        8/25/2017   7:35 PM             24 .gitignore
-a----        8/25/2017   7:35 PM           2017 AD-Group.json
-a----        8/25/2017   7:35 PM            506 AD-OU.json
-a----        8/25/2017   7:35 PM           5017 AD-Users.json
-a----        8/25/2017   7:35 PM           1054 Instructions.md
-a----        8/25/2017   7:35 PM           1576 README.md
-a----        8/25/2017   7:35 PM          36159 VMConfiguration.ps1
-a----        8/25/2017   7:35 PM           8903 VMConfigurationData.psd1
-a----        8/25/2017   7:35 PM           6020 VMValidate.test.ps1
```

Change to that directory and continue with the Autolab setup instructions.

## Domain Setup

Domain name: Company.pri
Password for all accounts is: `P@ssw0rd`

You most likely will want to use one or more of these accounts.

- The user Art Deco (ArtD) is a member of the Domain Admins group.
- The user April Showers (AprilS) is a member of the Domain Admins group.
- The user Mike Smith (MikeS) is a standard, non-domain admin, user.

## Servers

All servers run an evaluation version of Windows Server 2016 Core:

- DOM1 Domain Controller
- SRV1 Domain Member server
- SRV2 Domain Member server
- SRV3 Workgroup server

## Desktops

- Win10 - Windows 10 Enterprise (evaluation version) with Remote Server Administration Tools (RSAT) installed.
- PowerShell remoting has been enabled. You will need to run `Update-Help` and manually install items like [VS Code](https://code.visualstudio.com/Download).

## Notes

- All computers are set for Mountain Time with a location of Phoenix, Arizona.
- It is strongly recommended that you run Windows update on the virtual machines, especially the Windows 10 client.
- The PostSetup folder contains a number of optional scripts you might want to run after the Autolab setup is complete. It has a separate [README](./PostSetup/README.md) file.
- To connect to a virtual machine, in a PowerShell prompt you can use the `vmconnect` command: `vmconnect localhost win10` where you specify the name of the Hyper-V host (your local machine) and the name of the virtual machine.

*Last updated 4 September 2019*
