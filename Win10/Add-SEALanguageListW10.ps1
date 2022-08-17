$LanguageList = Get-WinUserLanguageList
$LanguageList.Add("ja-JP")
$LanguageList.Add("zh-tw")
$LanguageList.Add("zh-cn")
Set-WinUserLanguageList $LanguageList -force

<#
powershell -command Register-ScheduledTask -Force -TaskName "Add SEA Languages" 
-Action (New-ScheduledTaskAction -Execute "powershell.exe" -Argument '-command Start-Sleep -Seconds 3 ; Write-Host "Adding SEA Languages" ; Try { $LanguageList = Get-WinUserLanguageList ; $LanguageList.Add("ja-JP"); $LanguageList.Add("zh-tw"); $LanguageList.Add("zh-cn"); Set-WinUserLanguageList $LanguageList -force } Catch {Write-Host "Failed to add languages"}' )`
-Trigger (New-ScheduledTaskTrigger -AtLogon) 
-Settings (New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Minutes 3) -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -DontStopOnIdleEnd)
#>

$taskAction = New-ScheduledTaskAction `
    -Execute 'powershell.exe' `
    -Argument {-windowstyle hidden -command Start-Sleep -Seconds 3; Write-Host 'Adding SEA Languages';Try { $LanguageList = Get-WinUserLanguageList ; $LanguageList.Add('ja-JP'); $LanguageList.Add('zh-tw'); $LanguageList.Add('zh-cn'); Set-WinUserLanguageList $LanguageList -force 
        } Catch {Write-Host 'Failed to add languages'}}
#$taskAction

Register-ScheduledTask -Force -TaskName "Add SEA Languages"` -Action $taskAction -Trigger (New-ScheduledTaskTrigger -AtLogon) -Settings (New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Minutes 3) -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -DontStopOnIdleEnd)

