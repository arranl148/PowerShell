$RegistryKeys = "HKLM:\SOFTWARE\Microsoft\Enrollments", "HKLM:\SOFTWARE\Microsoft\Enrollments\Status","HKLM:\SOFTWARE\Microsoft\EnterpriseResourceManager\Tracked", "HKLM:\SOFTWARE\Microsoft\PolicyManager\AdmxInstalled", "HKLM:\SOFTWARE\Microsoft\PolicyManager\Providers","HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Accounts", "HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Logger", "HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Sessions"

$IntuneCert = Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object {
		$_.Issuer -match "Intune MDM" 
	} | Remove-Item

$EnrollmentID = Get-ScheduledTask | Where-Object {$_.TaskPath -like "*Microsoft*Windows*EnterpriseMgmt*"} | Select-Object -ExpandProperty TaskPath -Unique | Where-Object {$_ -like "*-*-*"} | Split-Path -Leaf
	
Get-ScheduledTask | Where-Object {$_.Taskpath -match $EnrollmentID} | Unregister-ScheduledTask -Confirm:$false
			
			foreach ($Key in $RegistryKeys) {
				if (Test-Path -Path $Key) {
					get-ChildItem -Path $Key | Where-Object {$_.Name -match $EnrollmentID} | Remove-Item -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue
	}
			}

			Start-Sleep -Seconds 30
		
$EnrollmentProcess = Start-Process -FilePath "C:\Windows\System32\DeviceEnroller.exe" -ArgumentList "/C /AutoenrollMDM" -NoNewWindow -Wait -PassThru