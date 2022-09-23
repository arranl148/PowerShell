#Powershell to uninstall CMgr Client
#Detect

try {
 $InstallerExe = "C:\Windows\ccmsetup\ccmsetup.exe"
 $InstallerLog = "C:\Windows\ccmsetup\logs\ccmsetup.log"
 if (Test-Path -Path $InstallerExe -PathType Leaf) {
    Write-Host "$InstallerExe found, starting uninstall"
    Start-Process -FilePath $InstallerExe -Wait -ArgumentList "/uninstall"
    }
    else {
        Write-Host "$InstallerExe not found"
        exit 0
        }
 #Check Log file for success
 if (Select-String -Path $InstallerLog -pattern "Uninstall Succeeded") {
        Write-Host "Uninstall succeeded found in CCM log"
        #Force an Intune Sync https://oofhours.com/2019/09/28/forcing-an-mdm-sync-from-a-windows-10-client/
        Get-ScheduledTask | ? {$_.TaskName -eq ‘PushLaunch’} | Start-ScheduledTask
        }
 }
catch {
    $errMsg = $_.Exception.Message
    return $errMsg
    exit 1
}



<#
#Force an Intune Sync - oofhours.com/2019/09/28/forcing-an-mdm-sync-from-a-windows-10-client/
Get-ScheduledTask | ? {$_.TaskName -eq ‘PushLaunch’} | Start-ScheduledTask
#>

#CM Clean Up Tasks

## exit 3010
