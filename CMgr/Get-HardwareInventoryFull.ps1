$comp=”localhost”

$HardwareInventoryID = '{00000000-0000-0000-0000-000000000001}'

    Get-WmiObject -ComputerName $comp -Namespace   'Root\CCM\INVAGT' -Class 'InventoryActionStatus' -Filter "InventoryActionID='$HardwareInventoryID'" | Remove-WmiObject

    Start-Sleep -s 5

    Invoke-WmiMethod -computername $comp -Namespace root\CCM -Class SMS_Client -Name TriggerSchedule -ArgumentList "{00000000-0000-0000-0000-000000000001}"
	
	
	
	<#
Invoke-WMIMethod -ComputerName <computerName> -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000001}" # Hardware Inventory

Invoke-WMIMethod -ComputerName <computerName> -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000002}" # Software Inventory

Invoke-WMIMethod -ComputerName <computerName> -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000003}" # Heartbeat Discovery
	#>