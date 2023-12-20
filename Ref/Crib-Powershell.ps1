Exit 13

## Apps + Components
Get-AppxPackage -allusers | Sort Name | Format-Table Name, PackageFullName

Get-WindowsCapability -Online | where {$_.State -eq "Installed"} | Format-Table Name, State

## Apps
## MSIX Bundle Install DISM
$AppSourcePath = "C:\Apps\YourTestApp]\*"
$AppSourcePackage = "C:\Apps\YourTestApp\YourTestApp_x64.msixbundle"
$certName = Get-ChildItem -Path $AppSourcePath -Include *.cer

certutil.exe -addstore TrustedPeople $certName[0].FullName
DISM.EXE /Online /Add-ProvisionedAppxPackage /PackagePath:$AppSourcePackage /SkipLicense

## 
## Azure
Get-AzContext -ListAvailable
Get-AzContext

## BitLocker -get the recovery key. https://devblogs.microsoft.com/scripting/powertip-use-powershell-to-get-bitlocker-recovery-key/
(Get-BitLockerVolume -MountPoint C).KeyProtector


##Date
Get-ChildItem *.jpg | Rename-Item -newname {$_.CreationTime.toString("dd.MM.yyyy.HH.mm") + ".jpg"}
https://adamtheautomator.com/powershell-rename/

##
##Domain Join
$Credential=Get-Credential
#Enter domain admin account and pwd
Reset-ComputerMachinePassword -Credential $Credential
# Or 
Test-ComputerSecureChannel -Repair -Credential (Get-Credential)


##
## Find Text
$FindText = "mid-group-wvd"
Get-ChildItem -Path D:\repo\customer\Live -Include *.json, *.ps1 -Recurse | Select-String $FindText



##
## GIT
git remote remove origin

##
##Modules
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

$m = Get-Module -Name Microsoft.Graph.Intune -ListAvailable
if (-not $m)
{
    Install-Module NuGet -Force
    Install-Module Microsoft.Graph.Intune
}
Import-Module Microsoft.Graph.Intune -Global


## Run a file
%windir%\SysNative\WindowsPowershell\v1.0\powershell.exe -noprofile -executionpolicy bypass -file .\YourScript.ps1 -All


##
## Scheduled Tasks
## Each user
$Principal = New-ScheduledTaskPrincipal -GroupId "INTERACTIVE"
#.. TaskTrigger -AtLogon) -Principal $Principal -Settings (Ne..


###########
## Sort-Object
# Define an array of strings
$strings = "a", "b", "c" 
# Sort the strings in descending order
$sortedStrings = $strings | Sort-Object -Descending
# Display the sorted strings
Write-Output $sortedStrings

$numbers = 4, 2, 3, 3, 1, 5, 2
$sortedNumbers = $numbers | Sort-Object -Unique -Descending
Write-Output $sortedNumbers

$sortedNumbers = $numbers | Sort-Object
Write-Output $sortedNumbers

#################
## TLS
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

##
## Unblock-File
dir * -Recurse | Unblock-File

##Only unblock the blocked
Get-Item * -Stream "Zone.Identifier" -ErrorAction SilentlyContinue | ForEach {Unblock-File $_.FileName})

From <https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/unblock-file?view=powershell-7> 

dir * -Recurse | Get-Item -Stream "Zone.Identifier" -ErrorAction SilentlyContinue | ForEach {Unblock-File $_.FileName}


##
## App Check WMI
$partialName = "ODBC"  # Replace with the partial name of the software you're looking for

# Check if the software is installed
$installedSoftware = Get-WmiObject -Query "SELECT * FROM Win32_Product WHERE Name LIKE '%$partialName%'" -ErrorAction SilentlyContinue

if ($installedSoftware) {
    Write-Host "Software $partialName is installed."
} else {
    Write-Host "Software $partialName is not installed."
}

##
## 64 bit only
$partialName = "yourPartialName"  # Replace with the partial name of the software you're looking for

# Define registry paths for 32-bit and 64-bit systems
$registryPath32 = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
$registryPath64 = "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"

# Check if the software is installed in 32-bit registry
$installedSoftware32 = Get-ItemProperty -Path $registryPath32 | Where-Object { $_.DisplayName -like "*$partialName*" }

# Check if the software is installed in 64-bit registry
$installedSoftware64 = Get-ItemProperty -Path $registryPath64 | Where-Object { $_.DisplayName -like "*$partialName*" }

if ($installedSoftware32 -or $installedSoftware64) {
    Write-Host "Software $partialName is installed."
} else {
    Write-Host "Software $partialName is not installed."
}


@echo off  
Echo Install Powertoys and Terminal  
REM Powertoys  
winget install Microsoft.Powertoys  
if %ERRORLEVEL% EQU 0 Echo Powertoys installed successfully.  
REM Terminal  
winget install Microsoft.WindowsTerminal  
if %ERRORLEVEL% EQU 0 Echo Terminal installed successfully.   %ERRORLEVEL%

