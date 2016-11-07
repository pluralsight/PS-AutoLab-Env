# StandAlone Confonfigurations

This is intented for those that wish to build their own VM's, in hyper-v or VMware,
and apply configurations directly to those VM's wihtout using the AutoLab infrastructure. This requires knowledge of Desired State Configuration (DSC)

## Note Pluralsight has courses on DSC if needed. 

All setup reqarding the vm's, installation, deploying DSCResource modules, Network configuration, and the deployment of the DSC resources is your own responsibility.

The general steps of deploying a DSC config and its Resources are as follows:

## Step 1
On a vm client (Win 10) on the same network as the other VM's, you must install all the DSC resources required for your configurations form PSGallery.
Example: 

Install-Module -Name xActiveDirectory -RequiredVersion 2.13.0.0
Install-Module -Name xComputerManagement -RequiredVersion 1.8.0.0
Install-Module -Name xNetworking -RequiredVersion 2.12.0.0
Install-Module -Name xDhcpServer -RequiredVersion 1.5.0.0
Install-Module -Name xADCSDeployment -RequiredVersion 1.0.0.0

These DSC Resource modules will be copied to c:\program files\WindowsPowerShell\modules

## Step 2
You must deploy (copy) those same DSC Reource modules to your other computers to the destination of c:\program files\WindowsPowerShell\modules

## Step 3
In the folder where your DSC configuration is located, you must run the configuration to build the .mof files

## Step 4
To deploy the mof files, you must run Start-DSCConfiguration from Powershell.
Start-DscConfiguration -Path .\ -ComputerName DC -Verbose -Wait
