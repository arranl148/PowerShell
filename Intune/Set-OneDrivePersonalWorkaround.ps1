$Value = "DisableUserAuth"
$PolicyKey = "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftAccount"
if (test-path $policykey) { 
	if ($null -ne (Get-ItemProperty -Name $value -Path $PolicyKey).$value) {
		if ((Get-ItemProperty -Name $value -Path $PolicyKey).$value -ne 0) { 
			New-ItemProperty -Path $PolicyKey -Name $Value -Value 0 -PropertyType DWORD -force 
		}
		}
	}