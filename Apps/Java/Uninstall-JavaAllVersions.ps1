#you can get a list of installed Java versions from the registry and uninstall all of them by their product GUID generated when you install software via MSI.

#PowerShell script to uninstall all Java SE (JRE) versions on a computer
$uninstall32 = gci "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall" | foreach { gp $_.PSPath } | ? { $_ -like "*Java*" } | select UninstallString
$uninstall64 = gci "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" | foreach { gp $_.PSPath } | ? { $_ -like "*Java*" } | select UninstallString
# Uninstall 64-bit Java versions
if ($uninstall64) {
$uninstall64 = $uninstall64.UninstallString -Replace "msiexec.exe", "" -Replace "/I", "" -Replace "/X", ""
$uninstall64 = $uninstall64.Trim()
Write "Uninstalling Java ..."
start-process "msiexec.exe" -arg "/X $uninstall64 /qb" -Wait
}
# Uninstall 32-bit Java versions
if ($uninstall32) {
$uninstall32 = $uninstall32.UninstallString -Replace "msiexec.exe","" -Replace "/I","" -Replace "/X",""
$uninstall32 = $uninstall32.Trim()
Write "Uninstalling all Java SE versions..."
start-process "msiexec.exe" -arg "/X $uninstall32 /qb" -Wait
}