# How many days since last reboot?

# Get the last boot up time
$lastBootUpTime = (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime

# Get the current date and time
$currentDate = Get-Date

# Calculate the time difference in days
$daysSinceLastReboot = ($currentDate - $lastBootUpTime).Days

# Check if the last reboot was more than 7 days ago
if ($daysSinceLastReboot -gt 7) 
# If yes, exit to remediation
{
   write-output "Restart needed - $dayssincelastreboot days and counting"
   #exit 1
}
else
{
    write-output "OK"
    #exit 0
}