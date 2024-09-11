#Pause updates in AutoPilot
$Users = Get-CimInstance -ClassName Win32_LoggedOnUser -ErrorAction SilentlyContinue
$targetprocesses = @(Get-CimInstance -Query "Select * FROM Win32_Process WHERE Name='explorer.exe'" -ErrorAction SilentlyContinue)
if (($targetprocesses.Count -eq 0) -or ($Users.Antecedent.Name -match 'defaultuser0')) {
    
    $TMR = (Get-Date (Get-Date).AddDays(1) -Format yyyy-MM-ddTHH:MM:ss) + "Z"
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings' -Name 'PauseUpdatesExpiryTime' -Value $TMR
} ELSE {
    "A User is logged in, We are not in ESP"
}