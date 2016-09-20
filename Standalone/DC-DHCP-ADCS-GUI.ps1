Configuration GUILab {

    param (
        [Parameter()] 
        [ValidateNotNull()] 
        [PSCredential] $Credential = (Get-Credential -Credential 'Administrator')
    )

#region DSC Resources
    Import-DSCresource -ModuleName PSDesiredStateConfiguration,
        @{ModuleName="xActiveDirectory";ModuleVersion="2.13.0.0"},
        @{ModuleName="xComputerManagement";ModuleVersion="1.8.0.0"},
        @{ModuleName="xNetworking";ModuleVersion="2.11.0.0"},
        @{ModuleName="XADCSDeployment";ModuleVersion="1.0.0.0"},
        @{ModuleName="xDhcpServer";ModuleVersion="1.5.0.0"}
#endregion

    node $AllNodes.Where({$true}).NodeName {
#region LCM configuration
        
        LocalConfigurationManager {
            RebootNodeIfNeeded   = $true
            AllowModuleOverwrite = $true
            ConfigurationMode = 'ApplyOnly'
           # CertificateID = $node.Thumbprint
        }

#endregion

#region Set ComputerName

        xComputer ComputerName { 
            Name = $Node.NodeName 
        } 
            
#endregion

#region Domain Credentials for Lab machines
    $DomainCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ("$($Credential.UserName)@$($node.DomainName)", $Credential.Password)
#endregion
  
#region IPaddress settings 

 
    If (-not [System.String]::IsNullOrEmpty($node.IPAddress)) {
        xIPAddress 'PrimaryIPAddress' {
            IPAddress      = $node.IPAddress
            InterfaceAlias = $node.InterfaceAlias
            SubnetMask     = $node.SubnetMask
            AddressFamily  = $node.AddressFamily
        }

        If (-not [System.String]::IsNullOrEmpty($node.DefaultGateway)) {     
            xDefaultGatewayAddress 'PrimaryDefaultGateway' {
                InterfaceAlias = $node.InterfaceAlias
                Address = $node.DefaultGateway
                AddressFamily = $node.AddressFamily
            }
        }

        If (-not [System.String]::IsNullOrEmpty($node.DnsServerAddress)) {                    
            xDnsServerAddress 'PrimaryDNSClient' {
                Address        = $node.DnsServerAddress
                InterfaceAlias = $node.InterfaceAlias
                AddressFamily  = $node.AddressFamily
            }
        }

        If (-not [System.String]::IsNullOrEmpty($node.DnsConnectionSuffix)) {
            xDnsConnectionSuffix 'PrimaryConnectionSuffix' {
                InterfaceAlias = $node.InterfaceAlias
                ConnectionSpecificSuffix = $node.DnsConnectionSuffix
            }
        }
    } #End IF
            
#endregion

#region Firewall Rules
        
        xFirewall 'FPS-ICMP4-ERQ-In' {
            Name = 'FPS-ICMP4-ERQ-In'
            DisplayName = 'File and Printer Sharing (Echo Request - ICMPv4-In)'
            Description = 'Echo request messages are sent as ping requests to other nodes.'
            Direction = 'Inbound'
            Action = 'Allow'
            Enabled = 'True'
            Profile = 'Any'
        }

        xFirewall 'FPS-ICMP6-ERQ-In' {
            Name = 'FPS-ICMP6-ERQ-In';
            DisplayName = 'File and Printer Sharing (Echo Request - ICMPv6-In)'
            Description = 'Echo request messages are sent as ping requests to other nodes.'
            Direction = 'Inbound'
            Action = 'Allow'
            Enabled = 'True'
            Profile = 'Any'
        }

        xFirewall 'FPS-SMB-In-TCP' {
            Name = 'FPS-SMB-In-TCP'
            DisplayName = 'File and Printer Sharing (SMB-In)'
            Description = 'Inbound rule for File and Printer Sharing to allow Server Message Block transmission and reception via Named Pipes. [TCP 445]'
            Direction = 'Inbound'
            Action = 'Allow'
            Enabled = 'True'
            Profile = 'Any'
        }
#endregion
                  
    } #end nodes ALL

#region Domain Controller config

    node $AllNodes.Where({$_.Role -in 'DC'}).NodeName {
        
        ## Hack to fix DependsOn with hypens "bug" :(
        foreach ($feature in @(
                'AD-Domain-Services'
                'GPMC',
                'RSAT-AD-Tools',
                'DNS',
                'RSAT-DNS-Server',
                'DHCP',
                'RSAT-DHCP'
            )) {
            WindowsFeature $feature.Replace('-','') {
                Ensure = 'Present';
                Name = $feature;
                IncludeAllSubFeature = $False;
            }
        } #End foreach

            xADDomain FirstDC {
                DomainName = $Node.DomainName
                DomainAdministratorCredential = $DomainCredential
                SafemodeAdministratorPassword = $DomainCredential
                DatabasePath = $Node.DCDatabasePath
                LogPath = $Node.DCLogPath
                SysvolPath = $Node.SysvolPath 
                DependsOn = '[WindowsFeature]ADDomainServices'
            }  
        
        #Add OU, Groups, and Users

            xWaitForADDomain DscForestWait {
                DomainName = $Node.DomainName
                DomainUserCredential = $DomainCredential
                RetryCount = '20'
                RetryIntervalSec = '60'
                DependsOn = "[xADDomain]FirstDC"
            }

            xADOrganizationalUnit IT {
                Name = 'IT'
                Ensure = 'Present'
                Path = $Node.DomainDN
                ProtectedFromAccidentalDeletion = $False
                DependsOn = '[xWaitForADDomain]DscForestWait'
            }

            xADOrganizationalUnit Dev {
                Name = 'Dev'
                Ensure = 'Present'
                Path = $Node.DomainDN
                ProtectedFromAccidentalDeletion = $False
                DependsOn = '[xWaitForADDomain]DscForestWait'
            }

            xADOrganizationalUnit Marketing {
                Name = 'Marketing'
                Ensure = 'Present'
                Path = $Node.DomainDN
                ProtectedFromAccidentalDeletion = $False
                DependsOn = '[xWaitForADDomain]DscForestWait'
            }

            xADOrganizationalUnit Sales {
                Name = 'Sales'
                Ensure = 'Present'
                Path = $Node.DomainDN
                ProtectedFromAccidentalDeletion = $False
                DependsOn = '[xWaitForADDomain]DscForestWait'
            }

            xADOrganizationalUnit Accounting {
                Name = 'Accounting'
                Ensure = 'Present'
                Path = $Node.DomainDN
                ProtectedFromAccidentalDeletion = $False
                DependsOn = '[xWaitForADDomain]DscForestWait'
            }

            xADOrganizationalUnit JEA_Operators {
                Name = 'JEA_Operators'
                Ensure = 'Present'
                Path = $Node.DomainDN
                ProtectedFromAccidentalDeletion = $False
                DependsOn = '[xWaitForADDomain]DscForestWait'
            }

            # Users
            xADUser IT1 {
                DomainName = $node.Domain
                Path = "OU=IT,$($node.DomainDN)"
                UserName = 'DonJ'
                GivenName = 'Don'
                Surname = 'Jones'
                DisplayName = 'Don Jones'
                Description = 'The Main guy'
                Department = 'IT'
                Enabled = $true
                Password = $Credential
                PasswordNeverExpires = $true
                DependsOn = '[xWaitForADDomain]DscForestWait'
            }

            xADUser IT2 {
                DomainName = $node.Domain
                Path = "OU=IT,$($node.DomainDN)"
                UserName = 'Jasonh'
                GivenName = 'Jason'
                Surname = 'Helmick'
                DisplayName = 'Jason Helmick'
                Description = 'The Fun guy'
                Department = 'IT'
                Enabled = $true
                Password = $Credential
                PasswordNeverExpires = $true
                DependsOn = '[xWaitForADDomain]DscForestWait'
            }

            xADUser IT3 {
                DomainName = $node.Domain
                Path = "OU=IT,$($node.DomainDN)"
                UserName = 'GregS'
                GivenName = 'Greg'
                Surname = 'Shields'
                DisplayName = 'Greg Shields'
                Description = 'The Janitor'
                Department = 'IT'
                Enabled = $true
                Password = $Credential
                PasswordNeverExpires = $true
                DependsOn = '[xWaitForADDomain]DscForestWait'
            }

            xADUser Dev1 {
                DomainName = $node.Domain
                Path = "OU=Dev,$($node.DomainDN)"
                UserName = 'SimonA'
                GivenName = 'Simon'
                Surname = 'Allardice'
                DisplayName = 'Simon Allardice'
                Description = 'The Brilliant one'
                Department = 'Dev'
                Enabled = $true
                Password = $Credential
                PasswordNeverExpires = $true
                DependsOn = '[xWaitForADDomain]DscForestWait'
            }

            xADUser Acct1 {
                DomainName = $node.Domain
                Path = "OU=Accounting,$($node.DomainDN)"
                UserName = 'AaronS'
                GivenName = 'Aaron'
                Surname = 'Smith'
                DisplayName = 'Aaron Smith'
                Description = 'Accountant'
                Department = 'Accounting'
                Enabled = $true
                Password = $Credential
                PasswordNeverExpires = $true
                DependsOn = '[xWaitForADDomain]DscForestWait'
            }

            xADUser Acct2 {
                DomainName = $node.Domain
                Path = "OU=Accounting,$($node.DomainDN)"
                UserName = 'AndreaS'
                GivenName = 'Andrea'
                Surname = 'Smith'
                DisplayName = 'Andrea Smith'
                Description = 'Accountant'
                Department = 'Accounting'
                Enabled = $true
                Password = $Credential
                PasswordNeverExpires = $true
                DependsOn = '[xWaitForADDomain]DscForestWait'
            }

            xADUser Acct3 {
                DomainName = $node.Domain
                Path = "OU=Accounting,$($node.DomainDN)"
                UserName = 'AndyS'
                GivenName = 'Andy'
                Surname = 'Smith'
                DisplayName = 'Andy Smith'
                Description = 'Accountant'
                Department = 'Accounting'
                Enabled = $true
                Password = $Credential
                PasswordNeverExpires = $true
                DependsOn = '[xWaitForADDomain]DscForestWait'
            }

            xADUser Sales1 {
                DomainName = $node.Domain
                Path = "OU=Sales,$($node.DomainDN)"
                UserName = 'SamS'
                GivenName = 'Sam'
                Surname = 'Smith'
                DisplayName = 'Sam Smith'
                Description = 'Sales'
                Department = 'Sales'
                Enabled = $true
                Password = $Credential
                PasswordNeverExpires = $true
                DependsOn = '[xWaitForADDomain]DscForestWait'
            }

            xADUser Sales2 {
                DomainName = $node.Domain
                Path = "OU=Sales,$($node.DomainDN)"
                UserName = 'SonyaS'
                GivenName = 'Sonya'
                Surname = 'Smith'
                DisplayName = 'Sonya Smith'
                Description = 'Sales'
                Department = 'Sales'
                Enabled = $true
                Password = $Credential
                PasswordNeverExpires = $true
                DependsOn = '[xWaitForADDomain]DscForestWait'
            }

            xADUser Sales3 {
                DomainName = $node.Domain
                Path = "OU=Sales,$($node.DomainDN)"
                UserName = 'SamanthaS'
                GivenName = 'Samantha'
                Surname = 'Smith'
                DisplayName = 'Samantha Smith'
                Description = 'Sales'
                Department = 'Sales'
                Enabled = $true
                Password = $Credential
                PasswordNeverExpires = $true
                DependsOn = '[xWaitForADDomain]DscForestWait'
            }

            xADUser Market1 {
                DomainName = $node.Domain
                Path = "OU=Marketing,$($node.DomainDN)"
                UserName = 'MarkS'
                GivenName = 'Mark'
                Surname = 'Smith'
                DisplayName = 'Mark Smith'
                Description = 'Marketing'
                Department = 'Marketing'
                Enabled = $true
                Password = $Credential
                PasswordNeverExpires = $true
                DependsOn = '[xWaitForADDomain]DscForestWait'
            }

            xADUser Market2 {
                DomainName = $node.Domain
                Path = "OU=Marketing,$($node.DomainDN)"
                UserName = 'MonicaS'
                GivenName = 'Monica'
                Surname = 'Smith'
                DisplayName = 'Monica Smith'
                Description = 'Marketing'
                Department = 'Marketing'
                Enabled = $true
                Password = $Credential
                PasswordNeverExpires = $true
                DependsOn = '[xWaitForADDomain]DscForestWait'
            }

            xADUser Market3 {
                DomainName = $node.Domain
                Path = "OU=Marketing,$($node.DomainDN)"
                UserName = 'MattS'
                GivenName = 'Matt'
                Surname = 'Smith'
                DisplayName = 'Matt Smith'
                Description = 'Marketing'
                Department = 'Marketing'
                Enabled = $true
                Password = $Credential
                PasswordNeverExpires = $true
                DependsOn = '[xWaitForADDomain]DscForestWait'
            }

            xADUser JEA1 {
                DomainName = $node.Domain
                Path = "OU=JEA_Operators,$($node.DomainDN)"
                UserName = 'JimJ'
                GivenName = 'Jim'
                Surname = 'Jea'
                DisplayName = 'Jim Jea'
                Description = 'JEA'
                Department = 'IT'
                Enabled = $true
                Password = $Credential
                PasswordNeverExpires = $true
                DependsOn = '[xWaitForADDomain]DscForestWait'
            }

            xADUser JEA2 {
                DomainName = $node.Domain
                Path = "OU=JEA_Operators,$($node.DomainDN)"
                UserName = 'JillJ'
                GivenName = 'Jill'
                Surname = 'Jea'
                DisplayName = 'Jill Jea'
                Description = 'JEA'
                Department = 'IT'
                Enabled = $true
                Password = $Credential
                PasswordNeverExpires = $true
                DependsOn = '[xWaitForADDomain]DscForestWait'
            }
 
            #Groups
            xADGroup ITG1 {
                GroupName = 'IT'
                Path = "OU=IT,$($node.DomainDN)"
                Category = 'Security'
                GroupScope = 'Universal'
                Members = 'DonJ', 'Jasonh', 'GregS'
                DependsOn = '[xWaitForADDomain]DscForestWait'
            }

            xADGroup SalesG1 {
                GroupName = 'Sales'
                Path = "OU=Sales,$($node.DomainDN)"
                Category = 'Security'
                GroupScope = 'Universal'
                Members = 'SamS', 'SonyaS', 'SamanthaS'
                DependsOn = '[xWaitForADDomain]DscForestWait'
            }

            xADGroup MKG1 {
                GroupName = 'Marketing'
                Path = "OU=Marketing,$($node.DomainDN)"
                Category = 'Security'
                GroupScope = 'Universal'
                Members = 'MarkS', 'MonicaS', 'MattS'
                DependsOn = '[xWaitForADDomain]DscForestWait'
            }

            xADGroup AccountG1 {
                GroupName = 'Accounting'
                Path = "OU=Accounting,$($node.DomainDN)"
                Category = 'Security'
                GroupScope = 'Universal'
                Members = 'AaronS', 'AndreaS', 'AndyS'
                DependsOn = '[xWaitForADDomain]DscForestWait'
            }

            xADGroup JEAG1 {
                GroupName = 'JEA Operators'
                Path = "OU=JEA_Operators,$($node.DomainDN)"
                Category = 'Security'
                GroupScope = 'Universal'
                Members = 'JimJ', 'JillJ'
                DependsOn = '[xWaitForADDomain]DscForestWait'
            }
       
    } #end nodes DC

#endregion 

#region DHCP
    node $AllNodes.Where({$_.Role -in 'DHCP'}).NodeName {
 
        xWaitForADDomain DscForestWait {
            DomainName = $Node.DomainName
            DomainUserCredential = $DomainCredential
            RetryCount = '20'
            RetryIntervalSec = '60'
        }
 

        foreach ($feature in @(
                'DHCP',
                'RSAT-DHCP'
            )) {

            WindowsFeature $feature.Replace('-','') {
                Ensure = 'Present';
                Name = $feature;
                IncludeAllSubFeature = $False;
                DependsOn = '[xWaitForADDomin]DSCForestWait'
            }
        } #End foreach  
        
        xDhcpServerAuthorization 'DhcpServerAuthorization' {
            Ensure = 'Present';
            DependsOn = '[WindowsFeature]DHCP','[xADDomain]FirstDC'
        }
        
        xDhcpServerScope 'DhcpScope' {
            Name = $Node.DHCPName;
            IPStartRange = $Node.DHCPIPStartRange
            IPEndRange = $Node.DHCPIPEndRange
            SubnetMask = $Node.DHCPSubnetMask
            LeaseDuration = $Node.DHCPAddressFamily
            State = $Node.DHCPState
            AddressFamily = $Node.DHCPLeaseDuration
            DependsOn = '[WindowsFeature]DHCP'
        }

        xDhcpServerOption 'DhcpOption' {
            ScopeID = $Node.DHCPScopeID
            DnsServerIPAddress = $Node.DHCPDnsServerIPAddress
            Router = $node.DHCPRouter
            AddressFamily = $Node.DHCPAddressFamily
            DependsOn = '[xDhcpServerScope]DhcpScope'
        }  
 
    } #end DHCP Config
 #endregion

#region ADCS

    node $AllNodes.Where({$_.Role -in 'ADCS'}).NodeName {
                
        xWaitForADDomain DscForestWait {
            DomainName = $Node.DomainName
            DomainUserCredential = $DomainCredential
            RetryCount = '20'
            RetryIntervalSec = '60'
        }
 
        ## Hack to fix DependsOn with hypens "bug" :(
        foreach ($feature in @(
                'ADCS-Cert-Authority',
                'ADCS-Enroll-Web-Pol',
                'ADCS-Enroll-Wev-Dsv',
                'ADCS-Web-Enrollment'
            )) {

            WindowsFeature $feature.Replace('-','') {
                Ensure = 'Present';
                Name = $feature;
                IncludeAllSubFeature = $False;
                DependsOn = '[xWaitForADDomin]DSCForestWait'
            }
        } #End foreach  
        
        xAdcsCertificationAuthority ADCSConfig
        {
            CAType = $Node.ADCSCAType
            Credential = $DomainCredential
            CryptoProviderName = $Node.CryptoProviderName
            HashAlgorithmName = $Node.HashAlgorithmName
            KeyLength = $Node.KeyLength
            CACommonName = $Node.CACN
            CADistinguishedNameSuffix = $Node.CADNSuffix
            DatabaseDirectory = $Node.CADatabasePath
            LogDirectory = $Node.CALogPath
            ValidityPeriod = $node.ValidityPeriod
            ValidityPeriodUnits = $Node.ValidityPeriodUnits
            DependsOn = '[WindowsFeature]ADCSCertAuthority'    
        }
    #Add GPO for PKI AutoEnroll
        script CreatePKIAEGpo
        {
            Credential = $DomainCredential
            TestScript = {
                            if ((get-gpo -name "PKI AutoEnroll" -ErrorAction SilentlyContinue) -eq $Null) {
                                return $False
                            } 
                            else {
                                return $True}
                        }
            SetScript = {
                            new-gpo -name "PKI AutoEnroll"
                        }
            GetScript = {
                            $GPO= (get-gpo -name "PKI AutoEnroll")
                            return @{Result = $GPO}
                        }
            DependsOn = '[xADDomain]FirstDC'
        }
        
        script setAEGPRegSetting1
        {
            Credential = $DomainCredential
            TestScript = {
                            if ((Get-GPRegistryValue -name "PKI AutoEnroll" -Key "HKLM\SOFTWARE\Policies\Microsoft\Cryptography\AutoEnrollment" -ValueName "AEPolicy" -ErrorAction SilentlyContinue).Value -eq 7) {
                                return $True
                            }
                            else {
                                return $False
                            }
                        }
            SetScript = {
                            Set-GPRegistryValue -name "PKI AutoEnroll" -Key "HKLM\SOFTWARE\Policies\Microsoft\Cryptography\AutoEnrollment" -ValueName "AEPolicy" -Value 7 -Type DWord
                        }
            GetScript = {
                            $RegVal1 = (Get-GPRegistryValue -name "PKI AutoEnroll" -Key "HKLM\SOFTWARE\Policies\Microsoft\Cryptography\AutoEnrollment" -ValueName "AEPolicy")
                            return @{Result = $RegVal1}
                        }
            DependsOn = '[Script]CreatePKIAEGpo'
        }

        script setAEGPRegSetting2 
        {
            Credential = $DomainCredential
            TestScript = {
                            if ((Get-GPRegistryValue -name "PKI AutoEnroll" -Key "HKLM\SOFTWARE\Policies\Microsoft\Cryptography\AutoEnrollment" -ValueName "OfflineExpirationPercent" -ErrorAction SilentlyContinue).Value -eq 10) {
                                return $True
                                }
                            else {
                                return $False
                                 }
                         }
            SetScript = {
                            Set-GPRegistryValue -Name "PKI AutoEnroll" -Key "HKLM\SOFTWARE\Policies\Microsoft\Cryptography\AutoEnrollment" -ValueName "OfflineExpirationPercent" -value 10 -Type DWord
                        }
            GetScript = {
                            $Regval2 = (Get-GPRegistryValue -name "PKI AutoEnroll" -Key "HKLM\SOFTWARE\Policies\Microsoft\Cryptography\AutoEnrollment" -ValueName "OfflineExpirationPercent")
                            return @{Result = $RegVal2}
                        }
            DependsOn = '[Script]setAEGPRegSetting1'

        }
                                  
        script setAEGPRegSetting3
        {
            Credential = $DomainCredential
            TestScript = {
                            if ((Get-GPRegistryValue -Name "PKI AutoEnroll" -Key "HKLM\SOFTWARE\Policies\Microsoft\Cryptography\AutoEnrollment" -ValueName "OfflineExpirationStoreNames" -ErrorAction SilentlyContinue).value -match "MY") {
                                return $True
                                }
                            else {
                                return $False
                                }
                        }
            SetScript = {
                            Set-GPRegistryValue -Name "PKI AutoEnroll" -Key "HKLM\SOFTWARE\Policies\Microsoft\Cryptography\AutoEnrollment" -ValueName "OfflineExpirationStoreNames" -value "MY" -Type String
                        }
            GetScript = {
                            $RegVal3 = (Get-GPRegistryValue -Name "PKI AutoEnroll" -Key "HKLM\SOFTWARE\Policies\Microsoft\Cryptography\AutoEnrollment" -ValueName "OfflineExpirationStoreNames")
                            return @{Result = $RegVal3}
                        }
            DependsOn = '[Script]setAEGPRegSetting2'
        }
      
        Script SetAEGPLink
        {
            Credential = $DomainCredential
            TestScript = {
                            try {
                                    set-GPLink -name "PKI AutoEnroll" -target $Using:Node.DomainDN -LinkEnabled Yes -ErrorAction silentlyContinue
                                    return $True
                                }
                            catch
                                {
                                    return $False
                                }
                         }
            SetScript = {
                            New-GPLink -name "PKI AutoEnroll" -Target $Using:Node.DomainDN -LinkEnabled Yes 
                        }
            GetScript = {
                            $GPLink = set-GPLink -name "PKI AutoEnroll" -target $Using:Node.DomainDN
                            return @{Result = $GPLink}
                        }
            DependsOn = '[Script]setAEGPRegSetting3'
        }                           
 
    } #end ADCS Config
 #endregion

#region Server config
   node $AllNodes.Where({$_.Role -in 'Server'}).NodeName {
 
        xWaitForADDomain DscForestWait {
            DomainName = $Node.DomainName
            DomainUserCredential = $DomainCredential
            RetryCount = '20'
            RetryIntervalSec = '60'
        }

         xComputer JoinDC {
            Name = $Node.NodeName
            DomainName = $Node.DomainName
            Credential = $DomainCredential
            DependsOn = '[xWaitForADDomain]DSCForestWait'
        }
    }#end Server Config
#endregion

#region Client config
   node $AllNodes.Where({$_.Role -in 'Client'}).NodeName {
 
        xWaitForADDomain DscForestWait {
            DomainName = $Node.DomainName
            DomainUserCredential = $DomainCredential
            RetryCount = '20'
            RetryIntervalSec = '60'
        }

         xComputer JoinDC {
            Name = $Node.NodeName
            DomainName = $Node.DomainName
            Credential = $DomainCredential
            DependsOn = '[xWaitForADDomain]DSCForestWait'
        }
    }#end Server Config
#endregion

#region Web config
   node $AllNodes.Where({$_.Role -in 'Web'}).NodeName {
        
        foreach ($feature in @(
                'web-Server'
                #'GPMC',
                #'RSAT-AD-Tools',
                #'DHCP',
                #'RSAT-DHCP'
            )) {
            WindowsFeature $feature.Replace('-','') {
                Ensure = 'Present'
                Name = $feature
                IncludeAllSubFeature = $False
            }
        }
        
    }#end Server Config
#endregion


} #end Configuration Example

GUILab -OutputPath .\ -ConfigurationData .\DC-Client-Servers-GUI.psd1
