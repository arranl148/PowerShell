
#Apps + Components
Get-AppxPackage -allusers | Sort Name | Format-Table Name, PackageFullName

Get-WindowsCapability -Online | where {$_.State -eq "Installed"} | Format-Table Name, State


## 
## Azure
Get-AzContext -ListAvailable
Get-AzContext

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



##
## TLS
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

##
## Unblock-File
dir * -Recurse | Unblock-File

##Only unblock the blocked
Get-Item * -Stream "Zone.Identifier" -ErrorAction SilentlyContinue | ForEach {Unblock-File $_.FileName})

From <https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/unblock-file?view=powershell-7> 

dir * -Recurse | Get-Item -Stream "Zone.Identifier" -ErrorAction SilentlyContinue | ForEach {Unblock-File $_.FileName}
