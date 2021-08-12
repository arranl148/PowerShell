<# v1.0 2021-Feb-01
#
# Customise Autopilot JSON file:
#   add Current Computername to JSON
#   save in correct location
#
# Original lifted from https://docs.microsoft.com/en-us/archive/blogs/mniehaus/speeding-up-windows-autopilot-for-existing-devices
#>

# Read the current config
$config = Get-Content .\AutoPilotConfigurationFile.json | ConvertFrom-Json

# Get the computer name
$tsenv = New-Object -COMObject Microsoft.SMS.TSEnvironment
$computerName = $tsenv.Value("_SMSTSMachineName")

# Add the computer name
$config | Add-Member "CloudAssignedDeviceName" $computerName

# Write the updated file
$targetDrive = $tsenv.Value("OSDTargetSystemDrive")
$null = MkDir "$targetDrive\Windows\Provisioning\Autopilot" -Force
$destConfig = "$targetDrive\Windows\Provisioning\Autopilot\AutoPilotConfigurationFile.json"
$config | ConvertTo-JSON | Set-Content -Path $destConfig -Force
