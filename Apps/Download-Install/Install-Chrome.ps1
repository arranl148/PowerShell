#
# Install-Chrome.ps1
#

#Description
#Installs Latest Chrome

$AppName = "Chrome"
$LogPath = "C:\Windows\TEMP"
$MasterLogName = Join-Path -Path $LogPath -ChildPath "ImageLog.log"
# $AppSourceFiles = "\\Server\Share\$AppName"
$DestinationPath = "D:\Apps\$appname"

##Start Logging
Start-Transcript -Path (Join-Path -Path $LogPath -ChildPath "Install $AppName.log")

if ( -Not (Test-Path -Path $DestinationPath ) ) {New-Item -ItemType directory -Path $DestinationPath} 
## Download / Copy EXE files
Invoke-WebRequest -Uri "https://dl.google.com/tag/s/appguid%3D%7B8A69D345-D564-463C-AFF1-A69D9E530F96%7D%26iid%3D%7BBB52ADDC-7274-FA8D-5342-00F648BD93A2%7D%26lang%3Den%26browser%3D4%26usagestats%3D0%26appname%3DGoogle%2520Chrome%26needsadmin%3Dprefers%26ap%3Dx64-stable-statsdef_1%26installdataindex%3Dempty/update2/installers/ChromeSetup.exe" -UseBasicParsing -OutFile $DestinationPath\ChromeSetup.exe

## Install App
Start-Process -FilePath "$DestinationPath\ChromeSetup.exe" -ArgumentList "/silent /install"


## Complete Logging
Out-File -InputObject "Installed $AppName" -FilePath $MasterLogName -Append

Stop-Transcript