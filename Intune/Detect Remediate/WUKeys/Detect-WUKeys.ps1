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
$KeyExists = 0

#Check WU Key Values
ForEach ($Value in $WUValueToCheck) { 
    If (Test-Path $WUPolicyKey -PathType Container) { 
        If ((Get-Item -Path $WUPolicyKey).GetValue($value) -ne $null) {
        $KeyExists += 1 
        Write-Host $Value
        } 
        Else { 
            $KeyExists += 0 
            Write-Host "Nope"
            }
        }
    }

ForEach ($Value in $WUAUValueToCheck) { 
    If (Test-Path $WUAUPolicyKey -PathType Container) { 
        If ((Get-Item -Path $WUAUPolicyKey).GetValue($value) -ne $null) {
            $KeyExists += 1 
            Write-Host $Value
            } 
            Else { 
                $KeyExists += 0 
                Write-Host "Nope"
                }
        }
}


If ($KeyExists -eq 0) { 
Write-Output "No Service Breaking Keys Exist." 
#Exit 0
}
Else { 
Write-Output "Service Breaking Keys Exist. Remediate." 
#Exit 1
Write-host "Exit $KeyExists"
}