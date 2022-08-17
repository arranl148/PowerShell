#From https://mrshannon.wordpress.com/2022/06/12/remove-old-quick-assist-after-the-new-app-is-installed/
$ScriptName = 'Detect-QuickAssistCoExists-v0.05'
# Derermine if both the 'old' and the 'new' quick assist apps are installed

# Log to the ProgramData path for IME.  If Diagnostic data is collected, this .log should come along for the ride.
$logpath = "$env:ProgramData\Microsoft\IntuneManagementExtension\Logs"
Start-Transcript –Path "$('{0}\{1}-{2}.log' -f $logpath, $ScriptName, $(Get-Date).ToFileTimeUtc())" | Out-Null
# Delete log files that are more than 35 days old
Get-ChildItem –Path "$logpath\$ScriptName*.log" –File | Where-Object {$PSItem.CreationTime -lt (Get-Date).AddDays(-35)} | Remove-Item –Force | Out-Null
# Get-ChildItem -Path "$logpath\$ScriptName*.log" -File | Select-Object Name,CreationTime,@{n='AgeInDays';e={(New-TimeSpan -Start $PSItem.CreationTime).Days}}

Write-Host $ScriptName
Write-Host $PSCommandPath
whoami

$exitCode = 0
#NOTE: The Proactive Remediations portal only shows the LAST LINE of output in the summary
# So I'll use this to print a useful summary just before exiting.
$exitSummary = ''

# Start with the assumption that neither are installed
$oldQA = $false
$newQA = $false

### Check for the 'old' Quick Assist
$OldQuickAssist = Get-WindowsCapability –Online –Name 'App.Support.QuickAssist~~~~0.0.1.0'
if ($OldQuickAssist.State -eq 'Installed') {
    $oldQA = $true

    if (Test-Path ("${env:windir}\system32\quickassist.exe")) {
        $OldQuickAssist_Version = [string]$($(Get-Item "${env:windir}\system32\quickassist.exe").VersionInfo).ProductVersion
        $exitSummary = "Old Quick Assist $($OldQuickAssist_Version) is installed"
    } else {
        $exitSummary = "Old Quick Assist is installed but the exe was not found, version is unknown."
    }
} else {
    $exitSummary = "Old Quick Assist is NOT installed."
}

### Check for the 'new' Quick Assist
$NewQuickAssist = Get-AppxPackage –AllUsers –Name 'MicrosoftCorporationII.QuickAssist'
if ($NewQuickAssist) {
    $newQA = $true
    Write-Host "New Quick Assist $($NewQuickAssist.Version) is installed"
} else {
    Write-Host "New Quick Assist is NOT installed."
}

if ($oldQA -and $newQA) {
    $exitSummary = "The Old Quick Assist and the new App are BOTH installed.  Remediation IS needed!"
    $exitCode = 1
} elseif ($oldQA -and -not($newQA))  {
    $exitSummary = "The Old Quick Assist IS installed but the new App is not.  Remediation is NOT needed."
} elseif (-not($oldQA) -and $newQA)  {
    $exitSummary = "The Old Quick Assist is NOT installed but the new App is.  Remediation is NOT needed."
} elseif (-not($oldQA) -and -not($newQA))  {
    $exitSummary = "The Old Quick Assist is NOT installed, neither is the new App.  Remediation is NOT needed."
} else {
    $exitSummary = "This should never happen, something with detection has failed!  Do not perform Remediation."
}

Write-Host $exitSummary
Stop-Transcript | Out-Null
exit $exitCode