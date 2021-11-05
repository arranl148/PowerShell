<#
.NOTES
    Brad Biehl - Premier Field Engineering (Microsoft)
    Blog: http://infrastructureanonymous.com/
    Last Update: 08/02/2015

    Release Notes:
    v1.3
    - First release to TechNet
        
.SYNOPSIS
    Reviews and compiles AppLocker logs

.DESCRIPTION    
    The Audit-AppLockerLogs script parses and summarizes AppLocker Event Logs. 
    It then compiles them into summary event logs and optionally exports a comprehensive HTML report. 
    For best results, aggregate client/server AppLocker logs to a single collector host and audit from there.

    Disclaimer:
    This sample script is not supported under any Microsoft standard support program or service. 
    The sample script is provided AS IS without warranty of any kind. Microsoft further disclaims 
    all implied warranties including, without limitation, any implied warranties of merchantability 
    or of fitness for a particular purpose. The entire risk arising out of the use or performance of 
    the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, 
    or anyone else involved in the creation, production, or delivery of the scripts be liable for any 
    damages whatsoever (including, without limitation, damages for loss of business profits, business 
    interruption, loss of business information, or other pecuniary loss) arising out of the use of or 
    inability to use the sample scripts or documentation, even if Microsoft has been advised of the 
    possibility of such damages
.PARAMETER collectionHost
    The server/client to collect Event Logs. If not specified, reverts to the local host.
.PARAMETER collectionWindow
    The number of days in the past to collect logs.
.PARAMETER html 
    Comprehensive report will be written to disk.
.PARAMETER htmlPath
    Path to write the HTML report. By default: %systemroot%\debug\AppLocker_Report.html
.PARAMETER verboseOutput 
    Enables Verbose logging with will log additional output from PS prompt. Normally used for troubleshooting.
.PARAMETER suppressEvents 
    Enables Disabled creation of Event Logs during execution. Normally used for troubleshooting when needing to quickly perform numerous test runs.
.EXAMPLE
    PS C:\audit-applockerlogs.ps1 -collectionWindow 5 -html  
    Result: Compiles AppLocker logs with a Summary sent to the EventLog and an HTML report is created in the default location.
.EXAMPLE
    PS C:\audit-applockerlogs.ps1 -collectionWindow 1 -html -suppressEvents
    Result: Compiles AppLocker logs with a Summary sent to an HTML report which is created in the default location. 
    The collection Window is only a single day, so this would be intended for daily reporting and possibly following by a weekly summary.
.LINK
    http://infrastructureanonymous.com/2015/08/03/advanced-group-policy-for-security-applocker/
.LINK
    http://infrastructureanonymous.com/
#>
param (
[Parameter(Mandatory=$false)][string] $collectionHost,
[Parameter(Mandatory=$false)][int] $collectionWindow=1,
[Parameter(Mandatory=$false)][switch] $html,
[Parameter(Mandatory=$false)][string] $htmlPath="$env:SYSTEMROOT\debug",
[Parameter(Mandatory=$false)][switch] $verboseOutput,
[Parameter(Mandatory=$false)][switch] $suppressEvents
)

#########################BEGIN FUNCTIONS#########################

#Verify Powershell is 2 or greater
Function Verify-PSVersion(){
    If (-NOT ($PSMajorVersion -ge 2)){
        Write-VerboseLogs "[ERROR]|Operation failed! `n`tPowerShell must be Version 2.0 or above to run this script!`nUpdate PowerShell to continue."
        $false
    }
    else{
        Write-VerboseLogs "[INFO]|PowerShell version was detected as $PSMajorVersion"
        $true
    }
} 

#Verified Run As Administrator
Function Verify-Elevation(){
    If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")){
        Write-VerboseLogs "[ERROR]|Operation failed! `n`tYou do not have sufficient Administrative rights to run this script!`n`tPlease re-run this script as an Administrator!"
        $false
    }
    else{$true}
} 

#Configure Event logs
Function Configure-EventLogs($argSource, $argLog){
    if (-not([System.Diagnostics.EventLog]::SourceExists($argSource)) -or -not([System.Diagnostics.EventLog]::Exists($argLog)))
    {
        try{
            Write-VerboseLogs "[INFO]|Event log source is missing. `n Attempting to create source $argSource for log $argLog."
            New-EventLog -LogName $argLog -Source $argSource
            $script:EventSourceReady=$true
        }
        catch{Write-VerboseLogs "[WARNING]|Failed to create Event Source $argSource for Event Log $argLog. `n Exiting script"}
    }
    else{
        Write-VerboseLogs "[INFO]|Event log source and log already exist."
        $script:EventSourceReady=$true
    }
}

Function Fix-Path($path){
    if(-not $path.EndsWith("\")){"$path\"}
    else{$path}
}

Function Configure-HtmlPath(){
    $script:htmlPath=fix-path $script:htmlPath
    if (-not(test-path $htmlPath)){    
        Write-VerboseLogs "[ERROR]|Path must exist or ForceLog must be set for script to continue. `n`nVerification failed for path: $htmlPath"
    }
    else{
        $script:htmlReady=$true 
   
        $script:htmlPathAuditExe=$script:htmlPath+"AppLocker_$(get-Date -Format yyyy-MM-dd)_Audit_Exe.html"
        $script:htmlPathEnforceExe=$script:htmlPath+"AppLocker_$(get-Date -Format yyyy-MM-dd)_Enforce_Exe.html"

        $script:htmlPathAuditScript=$script:htmlPath+"AppLocker_$(get-Date -Format yyyy-MM-dd)_Audit_Script.html"
        $script:htmlPathEnforceScript=$script:htmlPath+"AppLocker_$(get-Date -Format yyyy-MM-dd)_Enforce_Script.html"

        $script:htmlPathAuditAppDeploy=$script:htmlPath+"AppLocker_$(get-Date -Format yyyy-MM-dd)_Audit_AppDeploy.html"
        $script:htmlPathEnforceAppDeploy=$script:htmlPath+"AppLocker_$(get-Date -Format yyyy-MM-dd)_Enforce_AppDeploy.html"

        $script:htmlPathAuditAppExecute=$script:htmlPath+"AppLocker_$(get-Date -Format yyyy-MM-dd)_Audit_AppExecute.html"
        $script:htmlPathEnforceAppExecute=$script:htmlPath+"AppLocker_$(get-Date -Format yyyy-MM-dd)_Enforce_AppExecute.html"

        Write-VerboseLogs "[INFO]|Verification of log path successful: $htmlPath"
    }  
}

#Write Event logs
Function Write-VerboseLogs ($argText){
    $currentTimeStamp=(Get-Date).ToString()
    $messageType=$argText.Split("|")[0]
    $messageText=$argText.Split("|")[1]   
    $outputText="$currentTimeStamp $messageType $messageText"

    switch ($messageType)
    {
        "[ERROR]" {
            Write-Host $outputText -ForegroundColor Red
            if($EventSourceReady){Write-eventlog -logname $EventLog -Source $EventSource -Message $messageText -EventId (7800+$eventIDBase) -EntryType Error}
            if($logToFile -and $logReady){Write-Output $outputText | Out-File $script:logFileFull -Append}}
        "[WARNING]" {
            Write-Host $outputText -ForegroundColor Yellow
            if($EventSourceReady){Write-eventlog -logname $EventLog -Source $EventSource -Message $messageText -EventId (6800+$eventIDBase) -EntryType Warning}
            if($logToFile -and $logReady){Write-Output $outputText | Out-File $script:logFileFull -Append}}
        "[SUMMARY]" {
            Write-Host $outputText -ForegroundColor Green
            if($EventSourceReady){Write-eventlog -logname $EventLog -Source $EventSource -Message $messageText -EventId (4800+$eventIDBase) -EntryType Information}
            if($logToFile -and $logReady){Write-Output $outputText | Out-File $script:logFileFull -Append}}
        "[INFO]" {
            if($verboseOutput){Write-Host $outputText -ForegroundColor White
                if($logToFile -and $logReady){Write-Output $outputText | Out-File $script:logFileFull -Append}}}
        Default {Write-Host "Invalid output sent to write-VerboseLogs:`n $outputText" -ForegroundColor Magenta}
    }
}


Function Audit-ExeAndDll(){
    #--------------------
    #Executables and Dlls
    #--------------------
    Try{
        $ExeAuditHeader="<strong>Executables Allowed, but would be blocked</strong><br><br>Event Viewer > Applications and Services Logs > Microsoft > Windows > AppLocker > EXE and DLL <BR><BR>"
        $ExeAudit = Get-WinEvent -ComputerName $collectionHost -FilterHashTable @{LogName="Microsoft-Windows-AppLocker/EXE and DLL"; level=3; id=8003; StartTime=$EventStartDate ; EndTime=$EventEndDate} -ErrorAction Stop | Select Message,Id,Level,LogName,MachineName,UserId,TimeCreated
        $ExeAuditHTML= $ExeAudit | ConvertTo-HTML -Fragment 
        $ExeAuditSummary=$ExeAudit | Group Message | Select @{Name="Name";Expression={(($_.Name).Split("was"))[0]}},Count
        $ExeAuditSummaryHTML=$ExeAuditSummary | ConvertTo-HTML -Fragment 
        Write-VerboseLogs "[WARNING]|Executable Audit Summary  $($ExeAuditSummary | FL | Out-String)"
        if($htmlReady){ConvertTo-HTML -Body "$ExeAuditHeader $ExeAuditSummaryHTML $ExeAuditHTML" -Title "AppLocker - EXE Audit Report" | Out-File $htmlPathAuditExe}
    }
    Catch{
        $ErrorMessage=$_.Exception.Message
        if($errorMessage -like "*No events were found that match the specified selection criteria*"){
            $script:noIssuesFoundList+="`n`tExecutable and Dll Audit"
        }
        elseif($errorMessage -like "*There is not an event log on the*"){
            $script:notFoundEventLogs+="`n`tEXE and Dll"
        }
        else{Write-VerboseLogs "[ERROR]|Failed to get Executable and Dll Enforcement Events.`n`tError message: `n`t$($_.Exception.Message)`n"}
    }

    Try{
        $ExeEnforceHeader="<br><strong>Executables Blocked</strong><br><br>Event Viewer > Applications and Services Logs > Microsoft > Windows > AppLocker > EXE and DLL <BR><BR>"
        $ExeEnforce = Get-WinEvent -ComputerName $collectionHost -FilterHashTable @{LogName="Microsoft-Windows-AppLocker/EXE and DLL"; level=2; id=8004 ; StartTime=$EventStartDate ; EndTime=$EventEndDate} -ErrorAction Stop | Select Message,Id,Level,LogName,MachineName,UserId,TimeCreated 
        $ExeEnforceHTML= $ExeEnforce | ConvertTo-HTML -Fragment 
        $ExeEnforceSummary=$ExeEnforce | Group Message | Select @{Name="Name";Expression={(($_.Name).Split("was"))[0]}},Count
        $ExeEnforceSummaryHTML=$ExeEnforceSummary | ConvertTo-HTML -Fragment 
        Write-VerboseLogs "[ERROR]|Executable Enforce Summary  $($ExeEnforceSummary | FL | Out-String)"
        if($htmlReady){ConvertTo-HTML -Body "$ExeEnforceHeader $ExeEnforceSummaryHTML $ExeEnforceHTML" -Title "AppLocker - EXE Enforce Report" | Out-File $htmlPathEnforceExe}
    }
    Catch{
        $ErrorMessage=$_.Exception.Message
        if($errorMessage -like "*No events were found that match the specified selection criteria*"){
            $script:noIssuesFoundList+="`n`tExecutable and Dll Enforcement"
        }
        elseif($errorMessage -like "*There is not an event log on the*"){
            $script:notFoundEventLogs+="`n`tEXE and Dll"
        }
        else{Write-VerboseLogs "[ERROR]|Failed to get Executable and Dll Enforcement Events.`n`tError message: `n`t$($_.Exception.Message)`n"}
    }
}

Function Audit-ScriptAndInstaller(){
    #----------------------
    #Scripts and Installers
    #----------------------
    Try{
        $ScriptAuditHeader="<br><strong>Scripts Allowed, but would be blocked</strong><br><br>Event Viewer > Applications and Services Logs > Microsoft > Windows > AppLocker > MSI and Script <BR><BR>"
        $ScriptAudit = Get-WinEvent -ComputerName $collectionHost -FilterHashTable @{LogName="Microsoft-Windows-AppLocker/MSI and Script"; level=3; id=8006 ; StartTime=$EventStartDate ; EndTime=$EventEndDate} -ErrorAction Stop | Select Message,Id,Level,LogName,MachineName,UserId,TimeCreated 
        $ScriptAuditHTML= $ScriptAudit | ConvertTo-HTML -Fragment 
        $ScriptAuditSummary=$ScriptAudit | Group Message | Select @{Name="Name";Expression={(($_.Name).Split("was"))[0]}},Count
        $ScriptAuditSummaryHTML=$ScriptAuditSummary | ConvertTo-HTML -Fragment 
        Write-VerboseLogs "[WARNING]|Script Audit Summary  $($ScriptAuditSummary | FL | Out-String)"
        if($htmlReady){ConvertTo-HTML -Body "$ScriptAuditHeader $ScriptAuditSummaryHTML $ScriptAuditHTML" -Title "AppLocker - Script Audit Report" | Out-File $htmlPathAuditScript}
    }
    Catch{
        $ErrorMessage=$_.Exception.Message
        if($errorMessage -like "*No events were found that match the specified selection criteria*"){
            $script:noIssuesFoundList+="`n`tMSI and Script Audit"
        }
        elseif($errorMessage -like "*There is not an event log on the*"){
            $script:notFoundEventLogs+="`n`tMSI and Script"
        }
        else{Write-VerboseLogs "[ERROR]|Failed to get MSI and Script Enforcement Events.`n`tError message: `n`t$($_.Exception.Message)`n"}
    }

    Try{
        $ScriptEnforceHeader="<br><strong>Scripts Blocked</strong><br><br>Event Viewer > Applications and Services Logs > Microsoft > Windows > AppLocker > MSI and Script <BR><BR>"
        $ScriptEnforce = Get-WinEvent -ComputerName $collectionHost -FilterHashTable @{LogName="Microsoft-Windows-AppLocker/MSI and Script"; level=2; id=8007 ; StartTime=$EventStartDate ; EndTime=$EventEndDate} -ErrorAction Stop | Select Message,Id,Level,LogName,MachineName,UserId,TimeCreated
        $ScriptEnforceHTML= $ScriptEnforce | ConvertTo-HTML -Fragment 
        $ScriptEnforceSummary=$ScriptEnforce | Group Message | Select @{Name="Name";Expression={(($_.Name).Split("was"))[0]}},Count
        $ScriptEnforceSummaryHTML=$ScriptEnforceSummary | ConvertTo-HTML -Fragment 
        Write-VerboseLogs "[ERROR]|Script Enforce Summary  $($ScriptEnforceSummary | FL | Out-String)"
        if($htmlReady){ConvertTo-HTML -Body "$ScriptEnforceHeader $ScriptEnforceSummaryHTML $ScriptEnforceHTML" -Title "AppLocker - Script Enforce Report" | Out-File $htmlPathEnforceScript}
    }
    Catch{
        $ErrorMessage=$_.Exception.Message
        if($errorMessage -like "*No events were found that match the specified selection criteria*"){
            $script:noIssuesFoundList+="`n`tMSI and Script Enforcement"
        }
        elseif($errorMessage -like "*There is not an event log on the*"){
            $script:notFoundEventLogs+="`n`tMSI and Script"
        }
        else{Write-VerboseLogs "[ERROR]|Failed to get MSI and Script Audit Events.`n`tError message: `n`t$($_.Exception.Message)`n"}
    }
}

Function Audit-PackagedAppDeployment(){
    #-----------------------
    #Packaged App Deployment
    #----------------------- 
    Try{
	    $AppDeployAuditHeader="<br><strong>Packed App Deployment Allowed, but would be blocked</strong><br><br>Event Viewer > Applications and Services Logs > Microsoft > Windows > AppLocker > Packaged apps-Deployment <BR><BR>"
        $AppDeployAudit = Get-WinEvent -ComputerName $collectionHost -FilterHashTable @{LogName="Microsoft-Windows-AppLocker/Packaged app-Deployment"; id=8024; StartTime=$EventStartDate ; EndTime=$EventEndDate} -ErrorAction Stop | Select Message,Id,Level,LogName,MachineName,UserId,TimeCreated
        $AppDeployAuditHTML= $AppDeployAudit | ConvertTo-HTML -Fragment 
        $AppDeployAuditSummary=$AppDeployAudit | Group Message | Select @{Name="Name";Expression={(($_.Name).Split("was"))[0]}},Count
        $AppDeployAuditSummaryHTML=$AppDeployAuditSummary | ConvertTo-HTML -Fragment 
        Write-VerboseLogs "[WARNING]|Packed App Deployment Audit Summary  $($AppDeployAuditSummary | FL | Out-String)"
        if($htmlReady){ConvertTo-HTML -Body "$AppDeployAuditHeader $AppDeployAuditSummaryHTML $AppDeployAuditHTML" -Title "AppLocker - Packaged App Deployment Audit Report" | Out-File $htmlPathAuditAppDeploy}
    }
    Catch{
        $ErrorMessage=$_.Exception.Message
        if($errorMessage -like "*No events were found that match the specified selection criteria*"){
            $script:noIssuesFoundList+="`n`tPackaged App Deployment Audit"
        }
        elseif($errorMessage -like "*There is not an event log on the*"){
            $script:notFoundEventLogs+="`n`tPackaged app-Deployment"
        }
        else{Write-VerboseLogs "[ERROR]|Failed to get Packaged App Deployment Audit Events.`n`tError message: `n`t$($_.Exception.Message)`n"}
    }

    Try{
        $AppDeployEnforceHeader="<br><strong>Packed App Deployment Blocked</strong><br><br>Event Viewer > Applications and Services Logs > Microsoft > Windows > AppLocker > Packaged apps-Deployment <BR><BR>"
        $AppDeployEnforce = Get-WinEvent -ComputerName $collectionHost -FilterHashTable @{LogName="Microsoft-Windows-AppLocker/Packaged app-Deployment"; id=8025; StartTime=$EventStartDate ; EndTime=$EventEndDate} -ErrorAction Stop | Select Message,Id,Level,LogName,MachineName,UserId,TimeCreated
        $AppDeployEnforceHTML= $AppDeployEnforce | ConvertTo-HTML -Fragment 
        $AppDeployEnforceSummary=$AppDeployEnforce | Group Message | Select @{Name="Name";Expression={(($_.Name).Split("was"))[0]}},Count
        $AppDeployEnforceSummaryHTML=$AppDeployEnforceSummary | ConvertTo-HTML -Fragment 
        Write-VerboseLogs "[ERROR]|Packed App Deployment Enforcement Summary  $($AppDeployEnforceSummary | FL | Out-String)"
        if($htmlReady){ConvertTo-HTML -Body "$AppDeployEnforceHeader $AppDeployEnforceSummaryHTML $AppDeployEnforceHTML" -Title "AppLocker - Packaged App Deployment Enforce Report" | Out-File $htmlPathEnforceAppDeploy}
    }
    Catch{
        $ErrorMessage=$_.Exception.Message
        if($errorMessage -like "*No events were found that match the specified selection criteria*"){
            $script:noIssuesFoundList+="`n`tPackaged App Deployment Enforcement"
        }
        elseif($errorMessage -like "*There is not an event log on the*"){
            $script:notFoundEventLogs+="`n`tPackaged app-Deployment"
        }
        else{Write-VerboseLogs "[ERROR]|Failed to get Packaged App Deployment Enforcement Events.`n`tError message: `n`t$($_.Exception.Message)`n"}
    }
}

Function Audit-PackagedAppExecution(){
    #----------------------
    #$Packaged App Execution
    #----------------------
    Try{
        $AppExecuteAuditHeader="<br><strong>Packed App Execution Allowed, but would be blocked</strong><br><br>Event Viewer > Applications and Services Logs > Microsoft > Windows > AppLocker > Packaged apps-Execution <BR><BR>"
        $AppExecuteAudit = Get-WinEvent -ComputerName $collectionHost -FilterHashTable @{LogName="Microsoft-Windows-AppLocker/Packaged app-Execution"; id=8021; StartTime=$EventStartDate ; EndTime=$EventEndDate} -ErrorAction Stop | Select Message,Id,Level,LogName,MachineName,UserId,TimeCreated
        $AppExecuteAuditHTML= $AppExecuteAudit | ConvertTo-HTML -Fragment 
        $AppExecuteAuditSummary=$AppExecuteAudit | Group Message | Select @{Name="Name";Expression={(($_.Name).Split("was"))[0]}},Count
        $AppExecuteAuditSummaryHTML=$AppExecuteAuditSummary | ConvertTo-HTML -Fragment 
        Write-VerboseLogs "[WARNING]|Packed App Execution Audit Summary  $($AppExecuteAuditSummary | FL | Out-String)"
        if($htmlReady){ConvertTo-HTML -Body "$AppExecuteAuditHeader $AppExecuteAuditSummaryHTML $AppExecuteAuditHTML" -Title "AppLocker - Packaged App Execution Audit Report" | Out-File $htmlPathAuditAppExecute}
    }
    Catch{
        $ErrorMessage=$_.Exception.Message
        if($errorMessage -like "*No events were found that match the specified selection criteria*"){
            $script:noIssuesFoundList+="`n`tPackaged App Execution Auditing"
        }
        elseif($errorMessage -like "*There is not an event log on the*"){
            $script:notFoundEventLogs+="`n`tPackaged app-Execution"
        }
        else{Write-VerboseLogs "[ERROR]|Failed to get Packaged App Execution Auditing Events.`n`tError message: `n`t$($_.Exception.Message)`n"}
    }

    Try{
        $AppExecuteEnforceHeader="<br><strong>Packed App Execution Blocked</strong><br><br>Event Viewer > Applications and Services Logs > Microsoft > Windows > AppLocker > Packaged apps-Execution <BR><BR>"
        $AppExecuteEnforce = Get-WinEvent -ComputerName $collectionHost -FilterHashTable @{LogName="Microsoft-Windows-AppLocker/Packaged app-Execution"; id=8022; StartTime=$EventStartDate ; EndTime=$EventEndDate} -ErrorAction Stop | Select Message,Id,Level,LogName,MachineName,UserId,TimeCreated
        $AppExecuteEnforceHTML= $AppExecuteEnforce | ConvertTo-HTML -Fragment 
        $AppExecuteEnforceSummary=$AppExecuteEnforce | Group Message | Select @{Name="Name";Expression={(($_.Name).Split("was"))[0]}},Count
        $AppExecuteEnforceSummaryHTML=$AppExecuteEnforceSummary | ConvertTo-HTML -Fragment 
        Write-VerboseLogs "[ERROR]|Packed App Execution Enforce Summary  $($AppExecuteEnforceSummary | FL | Out-String)"
        if($htmlReady){ConvertTo-HTML -Body "$AppExecuteEnforceHeader $AppExecuteEnforceSummaryHTML $AppExecuteEnforceHTML" -Title "AppLocker - Packaged App Execution Enforce Report" | Out-File $htmlPathEnforceAppExecute}
    }
    Catch{
        $ErrorMessage=$_.Exception.Message
        if($errorMessage -like "*No events were found that match the specified selection criteria*"){
            $script:noIssuesFoundList+="`n`tPackaged App Execution Enforcement"
        }
        elseif($errorMessage -like "*There is not an event log on the*"){
            $script:notFoundEventLogs+="`n`tPackaged app-Execution"
        }
        else{
            Write-VerboseLogs "[ERROR]|Failed to get Packaged App Execution Enforcement Events.`n`tError message: `n`t$($_.Exception.Message)`n"
        }
        
    }
}
#########################END FUNCTIONS#########################

#Script version should be updated with every release
$scriptVersion="1.3"
$PSMajorVersion=$PSVersionTable.PSVersion.Major

if((Verify-PSVersion) -and (Verify-Elevation)){
    
    if(-not($suppressEvents)){
        $EventSource="Audit AppLocker Logs - DA"
        $EventLog="Distributed Automation"
        $EventIdBase=18 
        Configure-EventLogs $eventSource $eventLog
    }
    if(-not($collectionHost)){$collectionHost=hostname}
    if($html){Configure-HtmlPath}

    $EventStartDate = (((Get-Date).addDays(-($collectionWindow))).date)
    $EventEndDate = (Get-Date)
   
    Write-VerboseLogs "[SUMMARY]|Audit AppLocker Logs operation started.`n`tScript Version:`t$scriptVersion `n`tPS Version:`t$PSMajorVersion `n`n`tHost OU:`t$collectionHost `n`tWindow:`t$collectionWindow `n`tHTML Out:`t$html `n`tHTML Path:`t$htmlPath `n`tVerbose Out:`t$verboseOutput`n`tSuppress Events:`t$suppressEvents"

    Audit-ExeAndDll
    Audit-ScriptAndInstaller
    Audit-PackagedAppDeployment
    Audit-PackagedAppExecution

    if($noIssuesFoundList){Write-VerboseLogs "[SUMMARY]|Audit AppLocker Logs operation Completed.`n`tNo issues were identified in the following event types:`n $noIssuesFoundList"}
    if($notFoundEventLogs){Write-VerboseLogs "[WARNING]|Audit AppLocker Logs warnings found.`n`tThe following Event Logs were not found on the $($collectionHost):`n $notFoundEventLogs"}
}