$regkeypath= "hklm:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
$ValueList = @('AcceptTrustedPublisherCerts'
    'AllowAutoWindowsUpdateDownloadOverMetered'
    'AUPowerManagement'
    'BranchReadinessLevel'
#
    'DeferFeatureUpdatesPeriodInDays'
	'DeferQualityUpdates'
    'DeferQualityUpdatesPeriodInDays'
    'DeferUpdatePeriod'
    'DeferUpgrade'
    'DeferUpgradePeriod'
    'DeferQualityUpdate'
    'ExcludeWUDriversInQualityUpdate'
    'ManagePreviewBuilds'
    'ManagePreviewBuildsPolicyValue'
    'PauseDeferrals'
    'PauseFeatureUpdate'
    'PauseFeatureUpdatesStartTime'
    'PauseQualityUpdate'
    'PauseQualityUpdatesStartTime'
    'ScheduleRestartWarning'
#
    'UpdateNotificationLevel'
#
    'Test456') 
Foreach ($RegValue in $ValueList) {
    $value1 = (Get-ItemProperty $regkeypath).$RegValue -eq $null 
    If ($value1 -eq $False) 
        {Remove-ItemProperty -path $regkeypath -name $RegValue} 
    Else 
        {Write-Host "The value does not exist"}
}