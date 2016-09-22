[![Build status](https://ci.appveyor.com/api/projects/status/2uua9s0qgmfmqqrh/branch/master?svg=true)](https://ci.appveyor.com/project/PowerShell/xadcsdeployment/branch/master)

# xAdcsDeployment

The **xAdcsDeployment** DSC resources have been specifically tested as a method to populate a Certificate Services server role on Windows Server 2012 R2 after the Certificate Services role and the Web Enrollment feature have been enabled.
Active Directory Certificate Services (AD CS) is used to create certification authorities and related role services that allow you to issue and manage certificates used in a variety of applications.

## Scenario

Certificates are widely used to establish trust relationships between computers.
This DSC resource can be used to address some of the most common scenarios including the need for a Stand-Alone Certificate Authority or an Active Directory Trusted Root Certificate Authority and the Certificate Services website for users to submit and complete certificate requests.

In a specific example, when building out a web server workload such as an internal website that provides confidential information to be accessed from computers that are members of an Active Directory domain, AD CS can provide a source for the SSL certificats that will automatically be trusted.

## Resources

* **xAdcsCertificationAuthority**
* **xAdcsWebEnrollment**
* **xAdcsOnlineResponder**

### xAdcsCertificationAuthority

#### Properties

`CAType = <String> { EnterpriseRootCA | EnterpriseSubordinateCA | StandaloneRootCA | StandaloneSubordinateCA }`
  Specifies the type of certification authority to install.

| Required | Key?  | Default value |
| -------- | ----- | ------------- |
| True     | True  | none          |
  
`Credential = <PSCredential>`
  To install an enterprise certification authority, the computer must be joined to an Active Directory Domain Services domain and a user account that is a member of the Enterprise Admin group is required.
  To install a standalone certification authority, the computer can be in a workgroup or AD DS domain.
  If the computer is in a workgroup, a user account that is a member of Administrators is required.
  If the computer is in an AD DS domain, a user account that is a member of Domain Admins is required. 
  
| Required | Key?  | Default value |
| -------- | ----- | ------------- |
| True     | False | none          |
  
`Ensure = <String> { Present | Absent }`
  Specifies whether the Certificate Authority should be installed or uninstalled. 
  
| Required | Key?  | Default value |
| -------- | ----- | ------------- |
| False    | False | Present       |
  
`CACommonName = <String>`
  Specifies the certification authority common name. 

| Required | Key?  | Default value |
| -------- | ----- | ------------- |
| False    | False | none          |
  
`CADistinguishedNameSuffix = <String>`
  Specifies the certification authority distinguished name suffix. 
  
| Required | Key?  | Default value |
| -------- | ----- | ------------- |
| False    | False | none          |
  
`CertFile = <String>`
  Specifies the file name of certification authority PKCS 12 formatted certificate file. 
  
| Required | Key?  | Default value |
| -------- | ----- | ------------- |
| False    | False | none          |

`CertFilePassword = <PSCredential>`
  Specifies the password for certification authority certificate file. 

| Required | Key?  | Default value |
| -------- | ----- | ------------- |
| False    | False | none          |
  
`CertificateID = <String>`
  Specifies the thumbprint or serial number of certification authority certificate. 
  
| Required | Key?  | Default value |
| -------- | ----- | ------------- |
| False    | False | none          |

`CryptoProviderName = <String>`
  The name of the cryptographic service provider or key storage provider that is used to generate or store the private key for the CA. 

| Required | Key?  | Default value |
| -------- | ----- | ------------- |
| False    | False | none          |

`DatabaseDirectory = <String>`
  Specifies the folder location of the certification authority database. 

| Required | Key?  | Default value |
| -------- | ----- | ------------- |
| False    | False | none          |  

`HashAlgorithmName = <String>`
  Specifies the signature hash algorithm used by the certification authority. 

| Required | Key?  | Default value |
| -------- | ----- | ------------- |
| False    | False | none          |

`IgnoreUnicode = <Boolean>`
  Specifies whether Unicode characters are allowed in certification authority name string. 

| Required | Key?  | Default value |
| -------- | ----- | ------------- |
| False    | False | none          |

`KeyContainerName = <String>`
  Specifies the name of an existing private key container. 

| Required | Key?  | Default value |
| -------- | ----- | ------------- |
| False    | False | none          |
  
`KeyLength = <UInt32>`
  Specifies the length of an existing private key container. 

| Required | Key?  | Default value |
| -------- | ----- | ------------- |
| False    | False | none          |

`LogDirectory = <String>`
  Specifies the folder location of the certification authority database log. 
  
| Required | Key?  | Default value |
| -------- | ----- | ------------- |
| False    | False | none          |

`OutputCertRequestFile = <String>`
  Specifies the folder location for certificate request file. 

| Required | Key?  | Default value |
| -------- | ----- | ------------- |
| False    | False | none          |

`OverwriteExistingCAinDS = <Boolean>`
  Specifies that the computer object in the Active Directory Domain Service domain should be overwritten with the same computer name. 

| Required | Key?  | Default value |
| -------- | ----- | ------------- |
| False    | False | none          |

`OverwriteExistingDatabase = <Boolean>`
  Specifies that the existing certification authority database should be overwritten. 

| Required | Key?  | Default value |
| -------- | ----- | ------------- |
| False    | False | none          |

`OverwriteExistingKey = <Boolean>`
  Overwrite existing key container with the same name. 

| Required | Key?  | Default value |
| -------- | ----- | ------------- |
| False    | False | none          |

`ParentCA = <String> { Hours | Days | Months | Years }`
  Specifies the configuration string of the parent certification authority that will certify this CA. 

| Required | Key?  | Default value |
| -------- | ----- | ------------- |
| False    | False | none          |

`ValidityPeriod = <String>`

| Required | Key?  | Default value |
| -------- | ----- | ------------- |
| False    | False | none          |

`ValidityPeriodUnits = <UInt32>`
  Validity period of the certification authority certificate.
  If this is a subordinate CA, do not specify this parameter because the validity period is determined by the parent CA. 

| Required | Key?  | Default value |
| -------- | ----- | ------------- |
| False    | False | none          |

### xAdcsWebEnrollment

`IsSingleInstance = <String>`
  Specifies the resource is a single instance, the value must be 'Yes'

| Required | Key?  | Default value |
| -------- | ----- | ------------- |
| True     | True  | none          |

`CAConfig = <String>`
  CAConfig parameter string. 
  Do not specify this if there is a local CA installed. 

| Required | Key?  | Default value |
| -------- | ----- | ------------- |
| False    | False | none          |

`Credential = <PSCredential>`
  If the Web Enrollment service is configured to use Standalone certification authority, then an account that is a member of the local Administrators on the CA is required.
  If the Web Enrollment service is configured to use an Enterprise CA, then an account that is a member of Domain Admins is required.

| Required | Key?  | Default value |
| -------- | ----- | ------------- |
| True     | False | none          |

`Ensure = <String> { Present | Absent }`
  Specifies whether the Web Enrollment feature should be installed or uninstalled. 

| Required | Key?  | Default value |
| -------- | ----- | ------------- |
| False    | False | Present       |

### xAdcsOnlineResponder

This resource can be used to install an ADCS Online Responder after the feature has been installed on the server.

For more information on ADCS Online Responders, see [this article on TechNet](https://technet.microsoft.com/en-us/library/cc725958.aspx).

#### Properties

`IsSingleInstance = <String>`
  Specifies the resource is a single instance, the value must be 'Yes'

| Required | Key?  | Default value |
| -------- | ----- | ------------- |
| True     | True  | none          |

`Credential = <PSCredential>`
  If the Online Responder service is configured to use Standalone certification authority, then an account that is a member of the local Administrators on the CA is required.
  If the Online Responder service is configured to use an Enterprise CA, then an account that is a member of Domain Admins is required.

| Required | Key?  | Default value |
| -------- | ----- | ------------- |
| True     | False | none          |

`Ensure = <String> { Present | Absent }`
  Specifies whether the Online Responder feature should be installed or uninstalled.

| Required | Key?  | Default value |
| -------- | ----- | ------------- |
| True     | False | Present       |

## Versions

### Unreleased

### 1.0.0.0

* Moved Examples folder into root.
* Removed legacy xCertificateServices folder.
* Prevented Unit tests from Violating PSSA rules.
* MSFT_xAdcsWebEnrollment: Created unit tests based on v1.0 Test Template.
                           Update to meet Style Guidelines and ensure consistency.
                           Updated to IsSingleInstance model. **Breaking change**
* MSFT_xAdcsOnlineResponder: Update Unit tests to use v1.0 Test Template.
                             Unit tests can be run without AD CS installed.
                             Update to meet Style Guidelines and ensure consistency.
* Usage of WinRm.exe replaced in Config-SetupActiveDirectory.ps1 example file with Set-WSManQuickConfig cmdlet. 

### 0.2.0.0

* Added the following resources:
    * MSFT_xADCSOnlineResponder resource to install the Online Responder service.
*   Correction to xAdcsCertificationAuthority property title in Readme.md.
*   Addition of .gitignore to ensure DSCResource.Tests folder is committed.
*   Updated AppVeyor.yml to use WMF 5 build environment.

### 0.1.0.0

*   Initial release with the following resources 
    *   <span style="font-family:Calibri; font-size:medium">xAdcsCertificationAuthority and xAdcsWebEnrollment.</span>

### Examples

#### Example 1: Add a Certificate Authority and configure it for AD CS and Web Enrollment. 

This example will add the Windows Server Roles and Features to support a Certificate Authority and configure it to provide AD CS and Web Enrollment.

```powershell
Configuration CertificateAuthority
{
    Node ‘NodeName’
    {
        WindowsFeature ADCS-Cert-Authority
        {
               Ensure = 'Present'
               Name = 'ADCS-Cert-Authority'
        }
        xADCSCertificationAuthority ADCS
        {
            Ensure = 'Present'
            Credential = $Node.Credential
            CAType = 'EnterpriseRootCA'
            DependsOn = '[WindowsFeature]ADCS-Cert-Authority'
        }
        WindowsFeature ADCS-Web-Enrollment
        {
            Ensure = 'Present'
            Name = 'ADCS-Web-Enrollment'
            DependsOn = '[WindowsFeature]ADCS-Cert-Authority'
        }
        xADCSWebEnrollment CertSrv
        {
            Ensure = 'Present'
            IsSingleInstance = 'Yes'
            Credential = $Node.Credential
            DependsOn = '[WindowsFeature]ADCS-Web-Enrollment','[xADCSCertificationAuthority]ADCS'
        }
    }
}
```

#### Example 2: Remove the AD CS functionality from a server

```powershell
Configuration RetireCertificateAuthority
{        
    Node ‘NodeName’
    {
        xADCSWebEnrollment CertSrv
        {
            Ensure = 'Absent'
            Name = 'CertSrv'
        }
        {
            Ensure = 'Absent'
            Name = 'ADCS-Web-Enrollment'
            DependsOn = '[xADCSWebEnrollment]CertSrv'
        }
        xADCSCertificationAuthority ADCS
        {
            Ensure = 'Absent'
            DependsOn = '[WindowsFeature]ADCS-Web-Enrollment'
        }
            WindowsFeature ADCS-Cert-Authority
        {
            Ensure = 'Absent'
            Name = 'ADCS-Cert-Authority'
            DependsOn = ‘[xADCSCertificationAuthority]ADCS’
        }
    }
}
```

## Contributing
Please check out common DSC Resources [contributing guidelines](https://github.com/PowerShell/DscResource.Kit/blob/master/CONTRIBUTING.md).
