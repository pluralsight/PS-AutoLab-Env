$config = get-content .\VMConfigurationData.psd1
$defaultlocal = (get-timezone).id
$config = $config.Replace("US Mountain Standard Time",$defaultlocal)
$config | Out-File newconfig.psd1 