#Original taken from https://www.andrewj.net/blog/troubleshooting-wufb-workload/
# CMPivot query for CM:Registry('HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate') | where Value == '1'
#

$key = 'HKLMSoftwarePoliciesMicrosoftWindowsWindowsUpdate'
New-ItemProperty -Path $key -Name DoNotConnectToWindowsUpdateInternetLocations -Value 0 -propertyType DWord -Force -Verbose
New-ItemProperty -Path $key -Name DisableDualScan -Value 0 -propertyType DWord -Force -Verbose
New-ItemProperty -Path $key -Name SetPolicyDrivenUpdateSourceForDriverUpdates -Value 0 -propertyType DWord -Force -Verbose
New-ItemProperty -Path $key -Name SetPolicyDrivenUpdateSourceForFeatureUpdates -Value 0 -propertyType DWord -Force -Verbose
New-ItemProperty -Path $key -Name SetPolicyDrivenUpdateSourceForOtherUpdates -Value 0 -propertyType DWord -Force -Verbose
New-ItemProperty -Path $key -Name SetPolicyDrivenUpdateSourceForQualityUpdates -Value 0 -propertyType DWord -Force -Verbose