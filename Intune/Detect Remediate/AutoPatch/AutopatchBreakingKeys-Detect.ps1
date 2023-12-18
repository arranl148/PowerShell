#If any Autopatch braking keys found return 1
if((Get-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate).PSObject.Properties.Name -contains 'DoNotConnectToWindowsUpdateInternetLocations') {  
    Exit 1 
}

if((Get-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate).PSObject.Properties.Name -contains 'DisableWindowsUpdateAccess') {  
    Exit 1 
}

if((Get-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate).PSObject.Properties.Name -contains 'WUServer') {  
    Exit 1 
}

if((Get-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU).PSObject.Properties.Name -contains 'UseWUServer') {  
    Exit 1 
}
if((Get-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU).PSObject.Properties.Name -contains 'NoAutoUpdate') {  
    Exit 1 
}
#No Breaking keys found
   exit 0 
