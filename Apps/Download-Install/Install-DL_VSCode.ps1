#
# Install-VSCode.ps1
#

#Description
#Installs Latest Visual Studio Code

$AppName = "VSCode"
$LogPath = "c:\buildArtifacts"
$MasterLogName = Join-Path -Path $LogPath -ChildPath "ImageLog.log"
$DestinationPath = Join-Path -Path $env:SystemDrive -ChildPath "buildArtifacts\$AppNAme" #Do Not Change
$AppEXEPath = Join-Path -Path $LogPath -ChildPath "VSCode.exe"

##Start Logging
Start-Transcript -Path (Join-Path -Path $LogPath -ChildPath "Install $AppName.log")

## Download / Copy EXE files
Invoke-WebRequest -Uri 'https://go.microsoft.com/fwlink/?Linkid=852157' -OutFile $AppEXEPath

## Install App
Invoke-Expression -Command "$AppEXEPath /verysilent"

## Additional Config

## Complete Logging
Out-File -InputObject "Installed $AppName" -FilePath $MasterLogName -Append

Stop-Transcript
