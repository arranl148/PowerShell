Turn Off Provisioning Mode
PowerShell -> Invoke-WmiMethod -Namespace root\CCM -Class SMS_Client -Name SetClientProvisioningMode -ArgumentList $false
Command-line -> WMIC /namespace:\\root\ccm path sms_client CALL SetClientProvisioningMode "false" /NOINTERACTIVE
Turn On Provisioning Mode
PowerShell -> Invoke-WmiMethod -Namespace root\CCM -Class SMS_Client -Name SetClientProvisioningMode -ArgumentList $true
Command-line -> WMIC /namespace:\\root\ccm path sms_client CALL SetClientProvisioningMode "true" /NOINTERACTIVE