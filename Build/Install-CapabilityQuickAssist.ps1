<#
## This script is for when: 'DISM /online /add-capability ...'  fails
## From <https://www.manishbangia.com/deploy-quick-assist-using-sccm/> 
#>
<# Disable WSUServer value to 1 Run Windows Capability to directly download the components 
from internet Enable WSUServer value to 0 #>
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" -Value 0
Restart-Service "Windows Update" -ErrorAction SilentlyContinue
Write-Host "Adding Components…" -ForegroundColor Green
## DISM /online /add-capability /capabilityname:"App.Support.QuickAssist~~~~0.0.1.0" Add-WindowsCapability -Online -Name App.Support.QuickAssist~~~~0.0.1.0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" -Value 1
Restart-Service "Windows Update" -ErrorAction SilentlyContinue
