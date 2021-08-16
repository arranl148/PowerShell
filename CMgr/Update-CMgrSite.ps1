#$CMID = (get-wmiobject -ComputerName '.' -Namespace root\ccm -Query "Select ClientID from CCM_Client" |Select ClientID)
$MECM = new-object –comobject "Microsoft.SMS.Client";
Write-host "Changing Site to PS1"
if ($MECM.GetAssignedSite() –ne "PS1") {$MECM.SetAssignedSite("PS1")}

$CMGPath = "PDMSSABPCMG.POWERONPULSE.COM"
$InternetMP = "CCM_Proxy_MutualAuth/72057594037927939"

Write-host "Changing CMGFQDNs"
#Key1
$registryPathCMGFQDN = "HKLM:\SOFTWARE\Microsoft\CCM"
#ValueName
$NameCMGFQDN = "CMGFQDNs"
#ValueData
$valueCMGFQDN = $CMGPath

#Create or Update
IF(!(Test-Path $registryPathCMGFQDN)){
    New-Item -Path $registryPathCMGFQDN -Force | Out-Null
    New-ItemProperty -Path $registryPathCMGFQDN -Name $NameCMGFQDN -Value $CMGPath  -PropertyType String -Force | Out-Null
    }
    ELSE {
        New-ItemProperty -Path $registryPathCMGFQDN -Name $NameCMGFQDN -Value $CMGPath  -PropertyType String -Force | Out-Null
        }

Write-host "Changing InternetMP"
#Key2
$registryPathInternetMP = "HKLM:\SOFTWARE\Microsoft\SMS\Client\Internet Facing"
#ValueName
$NamePathInternetMP = "Internet MP Hostname"
#ValueData
$valueInternetMP = join-Path -Path $CMGPath -ChildPath $InternetMP

#Create or Update
IF(!(Test-Path $registryPathInternetMP)){
    New-Item -Path $registryPathInternetMP -Force | Out-Null
    New-ItemProperty -Path $registryPathInternetMP -Name $nameInternetMP -Value $valueInternetMP -PropertyType String -Force | Out-Null
    }
    ELSE {
        New-ItemProperty -Path $registryPathInternetMP -Name $nameInternetMP -Value $valueInternetMP -PropertyType String -Force | Out-Null
        }

Restart-Service -DisplayName "SMS Agent Host" -force -ErrorAction Ignore
