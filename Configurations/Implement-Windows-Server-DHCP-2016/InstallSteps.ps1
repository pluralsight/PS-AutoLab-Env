#Install Autolab
#all components for Autolab are available at 

Download the ZIP of this repository to the Host computer.
Extract the zip of PS-AutoLab-Env to your C:\ drive (C:\PS-AutoLab-Env)
Open PowerShell with administrative privileges (Run As Administrator)
Set the execution policy to Bypass (PS> Set-ExecutionPolicy ByPass)
Change to the extracted folder PS-AutoLab-Env.
Run PS> .\ Setup-Host.ps1
Note: The default installation folder is C:\AutoLab. You can change this if desired.
Note: .\Unattend-LabSetup runs setup-lab, Run-Lab, and Validate-Lab all together for faster processing
Change to the configuration folder under the installation folder (C:\AutoLab) and choose a configuration i.e. c:\AutoLab\Configuration<Your Config folder>
Check the Instructions.MD (Get-Content .\Instructions.MD)



Set-ExecutionPolicy Bypass

cd c:\PS-AutoLab-Env

.\Setup-Host.ps1