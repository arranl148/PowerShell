<#
## This script is for when: 'DISM /online /add-capability ...'  fails
## Developed from <https://www.manishbangia.com/deploy-quick-assist-using-sccm/> 
#>
<# Disable WSUServer value to 1 Run Windows Capability to directly download the components 
from internet Enable WSUServer value to 0 #>

$QuickAssistStatus = (get-WindowsCapability -Online -Name App.Support.QuickAssist~~~~0.0.1.0).state
if( $QuickAssistStatus -ne "Installed") {
    try{
        write-host "Disabling WU" -ForegroundColor Green 
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" -Value 0
        Restart-Service "Windows Update" -ErrorAction SilentlyContinue
        Write-Host "Adding Components" -ForegroundColor Green
        ## DISM /online /add-capability /capabilityname:"App.Support.QuickAssist~~~~0.0.1.0" 
        Add-WindowsCapability -Online -Name App.Support.QuickAssist~~~~0.0.1.0
        write-host "Reenabling WU " -ForegroundColor Green 
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" -Value 1
        Restart-Service "Windows Update" -ErrorAction SilentlyContinue
        } catch {
            write-host "DISM Add-Capability failed see WinDir\Logs\DISM log for details" -ForegroundColor Red 
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" -Value 1
            Restart-Service "Windows Update" -ErrorAction SilentlyContinue
            }
    } else { write-host "Quick Assist enabled, nothing to do" -ForegroundColor Green }