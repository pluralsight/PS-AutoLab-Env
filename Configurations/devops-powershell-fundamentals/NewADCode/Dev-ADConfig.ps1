#requires -version 5.0

<#
Here are some sample ways for creating the necessary json file. You need
to export values you need in your configuration.

$password = "P@ssw0rd1"
$Domain = "company"
$Secure = ConvertTo-SecureString -String $Password -AsPlainText -force
$cred = New-Object PSCredential "Company\Administrator",$Secure

$s = new-pssession -VMName DC -Credential $cred
$OU = invoke-command { get-adorganizationalunit -filter "Name -notlike 'Domain Controllers'" -properties Name,Description} -session $S -HideComputerName | 
Select Name,Description

$OU | ConvertTo-Json | Set-Content -path .\AD-OU.json

#$d = Get-DscResource xADUser

$prop = "DistinguishedName","Name","SamAccountname","GivenName","Surname","DisplayName","Description","Department"

Invoke-command {
(get-aduser -filter * -properties $using:prop).where({$_.name -notmatch "Administrator|Guest|Default|krbtgt"})
} -session $s |
Select $Prop |
ConvertTo-Json | Set-Content -path .\AD-Users.json


invoke-command {
get-adgroup -filter "name -like 'IT' -or name -like 'Sales' -or name -like 'marketing' -or name -like 'JEA'" | 
Select DistinguishedName,Name,
@{Name="GroupCategory";Expression={$_.GroupCategory.tostring()}},
@{Name="GroupScope";Expression={$_.GroupScope.toString()}},
@{Name="Members";Expression = { (Get-ADGroupmember $_ ).samaccountname}}
} -session $s -HideComputerName | 
Select DistinguishedName,Name,GroupCategory,GroupScope,Members |
ConvertTo-Json | Set-Content -Path .\AD-Group.json

#>

Configuration ADPOC {

Param()

Import-DSCResource -module PSDesiredStateConfiguration,
xActiveDirectory

foreach ($node in $AllNodes.Where({$_.role -eq 'AD'})) {

Node $Node.Nodename {
    xWaitForADDomain $Node.Domain {
        DomainName = $Node.Domain
        RetryIntervalSec = 30
    }
    
    foreach ($OU in $node.OUs) {
          xADOrganizationalUnit $OU.Name {
        Path = $node.DomainDN
        Name = $OU.Name
        Description = $OU.Description
        Ensure = "Present"
      }
    } #OU
    
    foreach ($user in $node.Users) {
    
        xADUser $user.samaccountname {
            Ensure = "Present"
            Path = $user.distinguishedname.split(",",2)[1]
            DomainName = $node.domainDN
            Username = $user.samaccountname
            GivenName = $user.givenname
            Surname = $user.Surname
            DisplayName = $user.Displayname
            Description = $user.description
            Department = $User.department
            Enabled = $true
            Password = $node.Credential
            DomainAdministratorCredential = $node.Credential
            PasswordNeverExpires = $True
            DependsOn = "[xwaitForADDomain]$($node.domain)"
        }
    } #user

    Foreach ($group in $node.Groups) {
        xADGroup $group.Name {
            GroupName = $group.name
            Ensure = 'Present'
            Path = $group.distinguishedname.split(",",2)[1]
            Category = $group.GroupCategory
            GroupScope = $group.GroupScope
            Members = ($group.members -join ",")
            DependsOn = "[xwaitForADDomain]$($node.domain)"
        }
    }
   
 } #node

} #AD

} #configuration

$password = "P@ssw0rd1"
$Secure = ConvertTo-SecureString -String $Password -AsPlainText -force
$credential = New-Object PSCredential "Company\Administrator",$Secure


$ConfigData = @{
 AllNodes = @(
   @{
   Nodename = "DC"
   Role = "AD"
   Domain = "Company"
   DomainDN = "DC=Company,DC=Pri"
   OUs = (Get-Content .\AD-OU.json | ConvertFrom-Json)
   Users = (Get-Content .\AD-Users.json | ConvertFrom-Json)
   Groups = (Get-Content .\AD-Group.json | ConvertFrom-Json)
   Credential = $Credential
   PSDscAllowPlainTextPassword = $true
   PSDscAllowDomainUser = $true 
   }
 )

}

ADPOC -ConfigurationData $ConfigData

psedit .\ADPOC\dc.mof

