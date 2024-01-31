Function Update-Lab {
    [CmdletBinding()]
    Param(
        [Parameter(HelpMessage = "The path to the configuration folder. Normally, you should run all commands from within the configuration folder.")]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { Test-Path $_ })]
        [String]$Path = ".",
        [Switch]$AsJob
    )

    Begin {
        Write-Verbose "[$((Get-Date).TimeOfDay) BEGIN  ] Starting $($MyInvocation.MyCommand)"
        $data = Import-PowerShellDataFile -Path $path\*.psd1

        #The prefix only changes the name of the VM not the guest computername
        $prefix = $data.NonNodeData.Lability.EnvironmentPrefix

        $upParams = @{
            VMName     = $null
            Credential = $null
        }
        if ($AsJob) {
            Write-Verbose "[$((Get-Date).TimeOfDay) BEGIN  ] Will update as background job"
            $upParams.Add("AsJob", $True)
        }
    } #begin

    Process {
        Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] Updating Lab"
        if ($data) {
            $pass = ConvertTo-SecureString -String $data.AllNodes.LabPassword -AsPlainText -Force
            $domain = $data.AllNodes.domainName
            $DomCred = New-Object PSCredential -ArgumentList "$($domain)\administrator", $pass
            $WGCred = New-Object PSCredential -ArgumentList "administrator", $pass

            #get defined nodes
            $nodes = ($data.AllNodes).where( { $_.NodeName -ne '*' })
            foreach ($node in $nodes) {
                $vmNode = ("{0}{1}" -f $prefix, $node.NodeName)
                #Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] ... $($node.NodeName)"
                Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] ... $vmNode"

                #verify VM is running
                $vm = Hyper-V\Get-VM -Name $vmNode # $node.NodeName
                if ($vm.state -ne 'running') {
                    #   Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] ... Starting VM $($node.NodeName)"
                    Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] ... Starting VM $vmNode"
                    $vm | Start-VM
                    Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] ... Waiting 30 seconds to give VM time to boot"
                    Start-Sleep -Seconds 30
                }

                $upParams.VMName = $vmNode #$node.NodeName
                if ($node.role -contains "DC" -or $node.role -contains "DomainJoin") {
                    $upParams.Credential = $DomCred
                }
                else {
                    $upParams.Credential = $WGCred
                }
                #calling a private function
                Invoke-WUUpdate @upParams
            }
        }
        else {
            Throw "Failed to find lab configuration data"
        }

    } #process

    End {
        Write-Verbose "[$((Get-Date).TimeOfDay) END    ] Ending $($MyInvocation.MyCommand)"

    } #end

}
