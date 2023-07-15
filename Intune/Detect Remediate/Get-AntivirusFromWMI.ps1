﻿# Obtain Antivirus information from WMI 
$AntivirusProduct = Get-WmiObject -Namespace "root\SecurityCenter2" -Query "SELECT * FROM AntiVirusProduct" -ErrorAction 'SilentlyContinue'
# Check for returned values, if null, write output and exit 1
if ($AntiVirusProduct -gt $null) {
	# Check for antivirus display name value, if null, write output and exit 1
	if (-not ([string]::IsNullOrEmpty($($AntivirusProduct.Displayname)))) {
		# Write antivirus product name out for proactive remediations display purposes and set exit success
		Write-Output $AntivirusProduct.displayName
		Exit 0
	} else {
		Write-Output "Antivirus product not found"
		Exit 1
	}
} else {
	Write-Output "Could not query root\SecurityCenter2 WMI namespace"
	Exit 1
}