#Remove Autopatch Breaking Keys
if((Get-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate).PSObject.Properties.Name -contains 'DoNotConnectToWindowsUpdateInternetLocations') { 
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "DoNotConnectToWindowsUpdateInternetLocations" 
}

if((Get-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate).PSObject.Properties.Name -contains 'DisableWindowsUpdateAccess') { 
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "DisableWindowsUpdateAccess"
}

if((Get-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate).PSObject.Properties.Name -contains 'WUServer') { 
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "WUServer"
}

if((Get-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU).PSObject.Properties.Name -contains 'UseWUServer') { 
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer"
}

if((Get-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU).PSObject.Properties.Name -contains 'NoAutoUpdate') { 
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoUpdate"
}