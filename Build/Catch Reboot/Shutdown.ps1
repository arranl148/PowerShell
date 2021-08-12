$end =$true
write-output "start"
 
DO
{
start-sleep 2
Get-date
#Remove-Variable -name tsenv -Force -ErrorAction SilentlyContinue
if (!$tsenv) {
try  {
$tsenv = New-Object -COMObject Microsoft.SMS.TSEnvironment
}
catch {
write-output "No TS started yet"
}
}
try  {
$bootpath = $tsenv.Value("_SMSTSBootStagePath") -split ":"
$tsenv.Value("_SMSTSBootStagePath")
if ($bootpath[0].length -gt 1) {
write-output "SMSTSBootStagePath prepped for reboot"
$end = $false
}
}
catch {
write-output "variable not set"
}
 
} While ($end -eq $true)
 
start-sleep 5
 
wpeutil shutdown