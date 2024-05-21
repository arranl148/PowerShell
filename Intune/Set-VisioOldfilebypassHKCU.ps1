<# 
Description: Bypass the Visio block for the user:
  This script checks if the registry key HKCU:Software\Policies\Microsoft\office\16.0\visio\security\fileblock exists and if the value is set to 0 
  (no restriction) or 2(open and Save blocked). If the value is set to 0 or 2, the script will set the value to 1. 
Author: Arran + CoPilot
v 0.1
 #>

# Check if registry key HKCU:Software\Policies\Microsoft\office\16.0\visio\security\fileblock" exists
if (Test-Path "HKCU:\Software\Policies\Microsoft\office\16.0\visio\security\fileblock") {
    # Registry key exists, check the value
    $value = Get-ItemPropertyValue "HKCU:\Software\Policies\Microsoft\office\16.0\visio\security\fileblock" "visio2003files"
    if ($value -eq 0 -or $value -eq 2) {
        # Set the value to 1
        Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\office\16.0\visio\security\fileblock" -Name "visio2003files" -Value 1
            } else {
                Write-Output "Visio 2003-2010 open is not blocked for this user."
                }

        } else {
            Write-Output "Visio 2003-2010 policy not applied for this user."
            }



