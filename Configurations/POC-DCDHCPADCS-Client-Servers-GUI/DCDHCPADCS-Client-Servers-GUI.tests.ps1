$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Test DC server for installation completeness" {
    Context "Active Directory object existence" {

    It "Created AD OU named IT" {
        Get-ADOrganizationalUnit -Identity "IT" -server DC | should not Throw
        }

    It "Created AD OU named Dev" {
     Get-ADOrganizationalUnit -Identity "IT" -server DC | should not Throw
        }
    
    It "Created AD OU named Marketing" {
     Get-ADOrganizationalUnit -Identity "Marketing" -Server DC | should not Throw
        }

    It "Created AD OU named Sales" {
     Get-ADOrganizationalUnit -Identity "Sales" -Server DC | should not Throw
        }
    
    It "Created AD OU named Accounting" {
     Get-ADOrganizationalUnit -Identity "Accounting" -Server DC | should not Throw
        }

It "Created AD OU named JEA_Operators" {
     Get-ADOrganizationalUnit -Identity "JEA_Operators" -Server DC | should not Throw
        }

    }
}
