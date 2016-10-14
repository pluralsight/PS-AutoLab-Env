
Function createhostDefaultsFile {

	$hostDefaults = @{
		ConfigurationPath="C:\Users\admin\Dropbox (Personal)\Pluralsight courses\Implementing and Securing Windows Server 2016 Core Networking\PS-AutoLab-Env\Configurations";
		DifferencingVhdPath="%SYSTEMDRIVE%\Lability\VMVirtualHardDisks";
		HotfixPath="%SYSTEMDRIVE%\Lability\Hotfixes";
		IsoPath="%SYSTEMDRIVE%\Lability\ISOs";
		ModuleCachePath="%ALLUSERSPROFILE%\Lability\Modules";
		ParentVhdPath="%SYSTEMDRIVE%\Lability\MasterVirtualHardDisks";
		ResourcePath="%SYSTEMDRIVE%\Lability\Resources";
		ResourceShareName="Resources";
		DisableLocalFileCaching=$false;
	}

	$hostDefaults | convertto-json | out-file HostDefaults.json

}

createHostDefaultsFile