#Use Scheduled tasks to list enrollment GUIDs and trigger a Sync for each (user / device)
$EnrollmentID = Get-ScheduledTask | Where-Object { $_.TaskPath -like "*Microsoft*Windows*EnterpriseMgmt\*" } `
    | Select-Object -ExpandProperty TaskPath `
    | Where-Object { $_ -like "*-*-*" } `
    | Split-Path -Leaf `
    | Select-Object -Unique
ForEach ($ID in $EnrollmentID) {
    Write-Output "Triggering Sync for $ID"
    Start-Process -FilePath "C:\Windows\system32\deviceenroller.exe" -Wait -ArgumentList "/o $ID /c /b"
}