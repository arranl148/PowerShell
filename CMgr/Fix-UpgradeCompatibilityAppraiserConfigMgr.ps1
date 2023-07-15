# Fix Upgrade Compatibility Appraiser - ConfigMgr
# https://www.anoopcnair.com/sccm-windows-11-upgrade-readiness-report-sql/
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' -Name 'AllowTelemetry' -Value '1'
Start-ScheduledTask -TaskPath "\Microsoft\Windows\Application Experience"-TaskName "Microsoft Compatibility Appraiser" 
Start-Sleep -Seconds 30 
Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000001}"