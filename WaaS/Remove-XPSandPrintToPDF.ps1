# Set Temp & Log Location
$TempLocation = Join-Path $env:AllUsersProfile "Drivers"
[string]$LogDirectory = Join-Path $TempLocation "\Logs"
$FileName = "Remove-XPSorPrintToPDF.log"
$LogFilePath = Join-Path -Path $LogDirectory -ChildPath $FileName
#Start Log
Start-Transcript -Path $LogFilePath 

# PrintToPDFServices
try {
    Disable-WindowsOptionalFeature -Online -FeatureName Printing-PrintToPDFServices-Features
	Write-host "Printing-PrintToPDFServices-Features removed"
	}
	catch {
		Write-host "Failed to remove Printing-PrintToPDFServices $($_.Exception.Message)"
		}
# Print-XPS
try {
    Disable-WindowsOptionalFeature -Online -FeatureName Printing-XPSServices-Features
	Write-host "Printing-XPSServices-Features removed"
	}
	catch {
		Write-host "Failed to remove Printing-XPSServices $($_.Exception.Message)"
		}
Get-WindowsOptionalFeature -Online -FeatureName Printing-PrintToPDFServices-Features
Get-WindowsOptionalFeature -Online -FeatureName Printing-XPSServices-Features
Stop-Transcript