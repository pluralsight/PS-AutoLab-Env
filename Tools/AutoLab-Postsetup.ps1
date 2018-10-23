#requires -version 5.0

<#
You can use this script for any one-time post-installation processing that
you wish to do for virtual machines. This script will process a special
hashtable that you define. 

Computername - The hashtable has a string for the virtual machine name.

FileCopy - A collection of nested hashtables with source and destination
paths. The file copy will be done over a remoting session using -Recurse
and -Container.

Install - A collection of nested hashtables for command line installations.
You need to specify the path the exe and any arguments. Installation happens
after files are copied.

PSCommands - An array of PowerShell scriptblocks to execute.

You can also define a setting with a computername of *. These settings will
apply to all computers defined in your array. The script will process 
computer-specific settings and then those for all computers.

The assumption is that you will make a copy of this script file and place
it in the configuration file. Edit as needed and manually run after setup
and convergence has completed.

#>

<#
$all = @( 
#these settings will apply to all defined nodes
Computername = "*"
FileCopy = @(
  @{Source="C:\Get-WindowsUpdate.ps1";Destination="C:\"},
  @{Source="C:\Install-WindowsUpdate.ps1";Destination="C:\"}
  ) 
Install = @()
PSCommands = @(
 #a collection of scriptblocks
 {Set-Content -value "I was here" -path "c:\kilroy.txt"}
 {Get-ComputerInfo | Export-Clixml -Path c:\cinfo.xml}
 #{Update-Help -force}
)

},
@{
Computername = "CLI1"
FileCopy = @(
    @{source="c:\MyTools";Destination="C:\Sourcefiles"}
    @{Source="c:\files\MySpecial.ps1";Destination="C:\"}
  ) 
Install = @(
 @{Path="C:\sourcefiles\Git-2.10.2-64-bit.exe";Arguments="/SP- /SILENT /SUPPRESSMSGBOXES /NORESTART /NOCLOSEAPPLICATIONS"}
 )
PSCommands = @(
 #a collection of scriptblocks
 {Get-ComputerInfo | Export-Clixml -Path c:\cinfo.xml}
)

}
)
#>


$all = @( 

@{
#these settings will apply to all defined nodes
Computername = "*"
FileCopy = @(
  @{Source="C:\Get-WindowsUpdate.ps1";Destination="C:\"},
  @{Source="C:\Install-WindowsUpdate.ps1";Destination="C:\"}
  ) 
Install = @()
PSCommands = @(
 #a collection of scriptblocks
 {Set-Content -value "I was here" -path "c:\kilroy.txt"}
 {Get-ComputerInfo | Export-Clixml -Path c:\cinfo.xml}
 #{Update-Help -force}
)

},
@{
#enter server specific settings
Computername="DC1"
Filecopy = @()
Install=@()
PSCommands = @(
 {Get-ADDomain | out-file c:\adtxt}
)
}
@{
Computername = "CLI1"
FileCopy = @(
  @{source="c:\MyCopy";Destination="C:\Sourcefiles"}
  ) 
Install = @(
 @{Path="C:\sourceFiles\BoxSyncSetup.exe";Arguments="/install /quiet /norestart"}
 @{Path="C:\sourcefiles\Git-2.10.2-64-bit.exe";Arguments="/SP- /SILENT /SUPPRESSMSGBOXES /NORESTART /NOCLOSEAPPLICATIONS"}
 )
PSCommands = @(
 #a collection of scriptblocks
 {Get-WindowsPackage -online | Export-clixml -Path c:\winpkg.xml}
)
}
,
@{
Computername = "S1"
FileCopy = @( ) 
Install = @( )
PSCommands = @(
 #a collection of scriptblocks
 {Get-WindowsFeature | Where Installed | Out-file c:\features.txt}
 )
}

)

#pull credential information from configuration psd1 file
$Secure = ConvertTo-SecureString -String "P@ssw0rd" -AsPlainText -Force 
$Domain = "company"
$cred = New-Object PSCredential "Company\Administrator",$Secure

#split the collection so that $nodes are the invidual nodes and
#$allnodes is the * setting that will apply to all computers

$nodes,$allnodes =  $all.where({$_.computername -ne '*'}, "split")

Foreach ($node in $nodes) {
  Write-Host "Running post-installation tasks for $($node.computername)" -ForegroundColor Yellow
  #create a PSSession
  Try {
   $sess = New-PSSession -VMName $node.Computername -Credential $cred -ErrorAction Stop
  }
  Catch {
    Write-Warning "Failed to create session to $($node.computername)"
    Write-Warning $_.Exception.Message
  }

  if ($sess) {
  Write-Host "Copying files" -ForegroundColor Cyan
  foreach ($set in $node.FileCopy) {
    Write-Host "   Copying $($set.source) to $($set.destination)" -ForegroundColor Cyan
    Copy-item -Path $set.source -Destination $set.Destination -Container -Recurse -ToSession $sess -Force
  }
  foreach ($set in $allnodes.filecopy) {
    Write-Host "   Copying $($set.source) to $($set.destination)" -ForegroundColor Cyan
    Copy-item -Path $set.source -Destination $set.Destination -Container -Recurse -ToSession $sess -Force

  }

  Write-Host "Installing additional programs" -ForegroundColor Cyan
  foreach ($app in $node.Install) {
    $cmd = ("{0} {1}" -f $app.path,$app.arguments).Trim()
    Write-Host "   Invoking $cmd" -ForegroundColor Cyan
    Invoke-Command { Start-Process -FilePath $using:app.path -ArgumentList $using:app.arguments} -session $sess
  }

  foreach ($app in $allnodes.Install) {
    $cmd = ("{0} {1}" -f $app.path,$app.arguments).Trim()
    Write-Host "   Invoking $cmd" -ForegroundColor Cyan
    Invoke-Command { Start-Process -FilePath $using:app.path -ArgumentList $using:app.arguments} -session $sess
  }

  Write-Host "Running additional PowerShell commands" -ForegroundColor Cyan
  foreach ($sb in $node.psCommands) {
    Write-host "   $sb" -ForegroundColor Cyan
    Invoke-Command -ScriptBlock $sb -session $sess -HideComputerName
  }

  foreach ($sb in $allnodes.psCommands) {
    Write-host "   $sb" -ForegroundColor Cyan
    Invoke-Command -ScriptBlock $sb -session $sess -HideComputerName
  }

  } #if $sess

  #remove the PSSession
  $sess | Remove-PSSession
  Write-Host "Post-installation complete" -ForegroundColor green
}

