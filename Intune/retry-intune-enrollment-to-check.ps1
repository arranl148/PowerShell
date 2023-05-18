# Clean out MDM registration info from machine, in attempt to fix Intune enrollment problems with Windows 10
# after a user reboots, the enrollment process should kick off again.
# This special edition, also disables workplace join, as an attempt to mitigate issues with devices previously AAD Registered.
# This script has fixed Error codes 0x80180023 and 0x8018002b at some of my customers sites, even without reboot in some cases.
# By Michael Mardahl @ Apento.com - @michael_mardahl

# Should be run as system user

#Disable workplace join if that is happening beyond your control.
#Get-ScheduledTask -TaskName "Automatic-Device-Join" | Disable-ScheduledTask
#Get-ScheduledTask -TaskName "Recovery-Check" | Disable-ScheduledTask

#you can try either one of the two following actions afterwards, or both (test test test)....

#Remove AAD registration from Machine.
& $env:WINDIR\system32\dsregcmd.exe /leave

#Re-run deviceEnrollment
& $env:WINDIR\system32\deviceenroller.exe /c /AutoEnrollMDM