<# v 2023.07.15 Rebuild detection Arrays to allow for values
#>

$WUPolicyKey = 'HKLM:Software\Policies\Microsoft\Windows\WindowsUpdate'
$WUAUPolicyKey = 'HKLM:Software\Policies\Microsoft\Windows\WindowsUpdate\AU'

#Software\Policies\Microsoft\Windows\WindowsUpdate
$WUValueToCheck = @(
#ServiceBreaking
'DisableDualScan'
'DoNotConnectToWindowsUpdateInternetLocations'
#ServiceAffecting
'AutoRestartDeadlinePeriodInDays'
'AutoRestartNotificationSchedule'
'AutoRestartRequiredNotificationDismissal'
'BranchReadinessLevel'
'EngagedRestartDeadline'
'EngagedRestartSnoozeSchedule'
'EngagedRestartTransitionSchedule'
'IncludeRecommendedUpdates'
'NoAUAsDefaultShutdownOption'
'PauseFeatureUpdatesStartTime'
'PauseQualityUpdatesStartTime'
'ScheduleImminentRestartWarning'
'ScheduleRestartWarning'
'SetAutoRestartDeadline'
'SetAutoRestartNotificationConfig'
'SetAutoRestartNotificationDisable'
'SetAutoRestartRequiredNotificationDismissal'
'SetEDURestart'
'SetEngagedRestartTransitionSchedule'
'SetRestartWarningSchd'
#GPO
'WUServer'
'WUStatusServer'
)

#Software\Policies\Microsoft\Windows\WindowsUpdate\AU
$WUAUValueToCheck = @(
#ServiceBreaking
'NoAutoUpdate'
#ServiceAffecting
'AutoInstallMinorUpdates'
'EnableFeaturedSoftware'
'NoAUShutdownOption'
'NoAutoRebootWithLoggedOnUsers'
'RebootRelaunchTimeout'
'RebootRelaunchTimeoutEnabled'
'RebootWarningTimeout'
'RebootWarningTimeoutEnabled'
'RescheduleWaitTime'
'RescheduleWaitTimeEnabled'
)
#Set Count to 0
$KeyExists = 0

#Check WU Key Values
ForEach ($Value in $WUValueToCheck) { 
    If (Test-Path $WUPolicyKey -PathType Container) { 
        If ($null -ne (Get-Item -Path $WUPolicyKey).GetValue($value)) {
            Remove-ItemProperty -Path $WUPolicyKey -name $value -Force
            $KeyExists += 1 
            } 
        }
    }

#Check WU AU Key Values
ForEach ($Value in $WUAUValueToCheck) { 
    If (Test-Path $WUAUPolicyKey -PathType Container) { 
        If ($null -ne (Get-Item -Path $WUAUPolicyKey).GetValue($value)) {
            Remove-ItemProperty -Path $WUAUPolicyKey -name $value -Force
            $KeyExists += 1 
            } 
        }
    }

If ($KeyExists -eq 0) { 
    Write-Output "No Service-Breaking Keys Exist." 
    #Exit 0
    } Else { 
        Write-Output "$KeyExists Service-Breaking Keys Remediated." 
        #Cleanup
        #$defaultValueName = '(default)'
        if (Test-path $WUAUPolicyKey) {
            #Delete the registry key unless it has a subkey and or more than only the default value
            $key = Get-Item -Path $WUAUPolicyKey -ErrorAction SilentlyContinue
            $subkeys = Get-ChildItem -Path $WUAUPolicyKey -ErrorAction SilentlyContinue
            if ((Test-path $WUAUPolicyKey) -and ($null -eq $subkeys) -and $key.GetValueNames().Count -eq 0 ) {
                # Delete the WU AU registry key
                Remove-Item -Path $WUAUPolicyKey -Recurse -Force
                #Write-Host "Registry key '$WUAUPolicyKey' deleted."
                }
                #else {Write-Host "Registry key '$WUAUPolicyKey' does not have only the default value or has subkeys."}
            }
        if (Test-path $WUPolicyKey) {
            $key = Get-Item -Path $WUPolicyKey -ErrorAction SilentlyContinue
            $subkeys = Get-ChildItem -Path $WUPolicyKey -ErrorAction SilentlyContinue
            if ((Test-path $WUPolicyKey) -and ($null -eq $subkeys) -and $key.GetValueNames().Count -eq 0 ) {
                # Delete the WU registry key
                Remove-Item -Path $WUPolicyKey -Recurse -Force
                #Write-Host "Registry key '$WUPolicyKey' deleted."
                }
                #else {Write-Host "Registry key '$WUPolicyKey' does not have only the default value or has subkeys."}
            }
    #we have removed keys if empty
    Exit 0
    }