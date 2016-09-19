#This wipes Hyperv of all VM's and Switches
#Dev Note -- The actuall VHDX files need to be deleted
Remove-Item -Path .\*.mof
Remove-LabConfiguration -ConfigurationData .\DC-Client-Servers-GUI.psd1 -RemoveSwitch