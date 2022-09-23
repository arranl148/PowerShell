<#
Remediation script:
This is a test script - no guarantees - test before use
Query one or more windows update keys based on two arrays (WindowsUpdates and AU)
If any of the problematic Windows Update GPO values exist under a key then remove the key
#>

#Change to true to enable remediation
$Remediate = $false

#Create Windows Update Settings Array
#Software\Policies\Microsoft\Windows\WindowsUpdate
$WUSettingsArray = @()
$WUSettingsArray += "AutoRestartDeadlinePeriodInDays"
$WUSettingsArray += "AutoRestartNotificationSchedule"
$WUSettingsArray += "AutoRestartRequiredNotificationDismissal"
$WUSettingsArray += "BranchReadinessLevel"
$WUSettingsArray += "DisableDualScan"
$WUSettingsArray += "DoNotConnectToWindowsUpdateInternetLocations"
$WUSettingsArray += "EngagedRestartDeadline"
$WUSettingsArray += "EngagedRestartSnoozeSchedule"
$WUSettingsArray += "EngagedRestartTransitionSchedule"
$WUSettingsArray += "PauseFeatureUpdatesStartTime"
$WUSettingsArray += "PauseQualityUpdatesStartTime"
$WUSettingsArray += "ScheduleImminentRestartWarning"
$WUSettingsArray += "ScheduleRestartWarning"
$WUSettingsArray += "SetAutoRestartDeadline"
$WUSettingsArray += "SetAutoRestartNotificationConfig"
$WUSettingsArray += "SetAutoRestartNotificationDisable"
$WUSettingsArray += "SetAutoRestartRequiredNotificationDismissal"
$WUSettingsArray += "SetEDURestart"
$WUSettingsArray += "SetEngagedRestartTransitionSchedule"
$WUSettingsArray += "SetRestartWarningSchd"
$WUSettingsArray += "WUServer"
$WUSettingsArray += "WUStatusServer"

#Collect Scan Source Registry Keys
$WUSettingsArray += "SetPolicyDrivenUpdateSourceForDriverUpdates"
$WUSettingsArray += "SetPolicyDrivenUpdateSourceForFeatureUpdates"
$WUSettingsArray += "SetPolicyDrivenUpdateSourceForOtherUpdates"
$WUSettingsArray += "SetPolicyDrivenUpdateSourceForQualityUpdates"

#Software\Policies\Microsoft\Windows\WindowsUpdate\AU
$WUAUSettingsArray = @()
$WUAUSettingsArray += "AutoInstallMinorUpdates"
$WUAUSettingsArray += "EnableFeaturedSoftware"
$WUAUSettingsArray += "IncludeRecommendedUpdates"
$WUAUSettingsArray += "NoAUAsDefaultShutdownOption"
$WUAUSettingsArray += "NoAUShutdownOption"
$WUAUSettingsArray += "NoAutoRebootWithLoggedOnUsers"
$WUAUSettingsArray += "NoAutoUpdate"
$WUAUSettingsArray += "RebootRelaunchTimeout"
$WUAUSettingsArray += "RebootRelaunchTimeoutEnabled"
$WUAUSettingsArray += "RebootWarningTimeout"
$WUAUSettingsArray += "RebootWarningTimeoutEnabled"
$WUAUSettingsArray += "RescheduleWaitTime"
$WUAUSettingsArray += "RescheduleWaitTimeEnabled"

#Get Default AU Service
$DefaultAUService = (New-Object -ComObject "Microsoft.Update.ServiceManager").services | Where-Object { $_.IsDefaultAUService -eq 'True' } | Select-Object -ExpandProperty Name

#Create Detect Key - Intune flag
$Found = "NotFound"

#Get Registry Values for Software\Policies\Microsoft\Windows\WindowsUpdate\AU if it exists
$WUAURegKey = "HKLM:Software\Policies\Microsoft\Windows\WindowsUpdate\AU"
if (test-path -Path $WUAURegKey -PathType Container) {
    #Check each value in the array
    ForEach ($WUAUSetting in $WUAUSettingsArray) {
        if ((Get-Item -Path $WUAURegKey).GetValue($WUAUSetting) -ne $null) {
            Write-host "Update value $WUAUSetting found" 
            #Found something change Detect Key to trigger response
            $Found = "Found" 
            #Flag for remediation too
            $FoundWUAURegKey = $true
            ##  Get-Item -Path $WUAURegKey | Remove-ItemProperty -Name $WUAUSetting
            }
        }
    #If a value found and remediate enabled remove the key and therefore all values 
    if (($Remediate -eq $true) -and ($FoundWUAURegKey -eq $true)) {
        Write-Host "Removing $WUAURegKey and all values"
        Remove-Item -Path $WUAURegKey
        }
    }

#Get Registry Values for Software\Policies\Microsoft\Windows\WindowsUpdate if it exists
$WURegKey = "HKLM:Software\Policies\Microsoft\Windows\WindowsUpdate"
if (test-path -Path $WURegKey -PathType Container) {
    #Check each value in the array
    ForEach ($WUSetting in $WUSettingsArray) {
        if ((Get-Item -Path $WURegKey).GetValue($WUSetting) -ne $null) {
            Write-host "Update value $WUSetting found" 
            #Found something change Detect Key to trigger response
            $Found = "Found"
            #Flag for remediation too
            $FoundWURegKey = $true
            ##  Get-Item -Path $WURegKey | Remove-ItemProperty -Name $WUSetting
            }
        }
     #If a value found and remediate enabled remove the key and therefore all values 
     if (($Remediate -eq $true) -and ($FoundWURegKey -eq $true)) {
            Write-Host "Removing $WURegKey and all values"
            Remove-Item -Path $WURegKey
        }
    }

#Remediation Not enabled and one or more values found then return 1 for detection
If (($Remediate -eq $false) -and ($Found -eq "Found"))  {
    exit 1}

#Nothing to report
Exit 0