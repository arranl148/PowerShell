#
# Install-Download-AdobeReader.ps1
#

#Description
#Installs Latest Adobe Reader DC MUI

#Header
$AppName = "AdobeReaderDC"
$FolderName = "buildArtifacts"
$LogPath = -Path $env:SystemDrive -ChildPath $FolderName
if (-not (Test-Path -Path $LogPath)) {New-Item -Path $LogPath -ItemType Directory}
$MasterLogName = Join-Path -Path $LogPath -ChildPath "ImageLog.log"
$DestinationPath = Join-Path -Path $env:SystemDrive -ChildPath "buildArtifacts\$AppNAme" #Do Not Change

# determining the latest version of Reader
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$session.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.67 Safari/537.36"
$result = Invoke-RestMethod -Uri 'https://rdc.adobe.io/reader/products?lang=mui&site=enterprise&os=Windows%2011&country=US&nativeOs=Windows%2010&api_key=dc-get-adobereader-cdn' `
    -WebSession $session `
    -Headers @{
        "Accept"="*/*"
        "Accept-Encoding"="gzip, deflate, br"
        "Accept-Language"="en-US,en;q=0.9"
        "Origin"='https://get.adobe.com'
        "Referer"='https://get.adobe.com/'
        "Sec-Fetch-Dest"="empty"
        "Sec-Fetch-Mode"="cors"
        "Sec-Fetch-Site"="cross-site"
        "sec-ch-ua"="`" Not A;Brand`";v=`"99`", `"Chromium`";v=`"101`", `"Google Chrome`";v=`"101`""
        "sec-ch-ua-mobile"="?0"
        "sec-ch-ua-platform"="`"Windows`""
        "x-api-key"="dc-get-adobereader-cdn"
}

#massage version number
$version = $result.products.reader[0].version
$version = $version.replace('.','')

# downloading
$URI = "https://ardownload2.adobe.com/pub/adobe/acrobat/win/AcrobatDC/$Version/AcroRdrDCx64$($Version)_MUI.exe"
$InstallFile = Join-Path -Path $LogPath -ChildPath "AcroRdrDCx64$($version)_MUI.exe"

##Start Logging
Start-Transcript -Path (Join-Path -Path $LogPath -ChildPath "Install $AppName.log")

## Download / Copy EXE files
Write-Host "Downloading version $version from $URI to $InstallFile"
Invoke-WebRequest -Uri $URI -OutFile $InstallFile -Verbose


## Install App
# silent install
Start-Process -FilePath $OutFile -ArgumentList "/sAll /rs /rps /msi /norestart /quiet EULA_ACCEPT=YES" -WorkingDirectory $LogPath -Wait -LoadUserProfile

# cleanup
Remove-Item $OutFile

Write-Host "Normal completion"

## Additional Config

## Complete Logging
Out-File -InputObject "Installed $AppName" -FilePath $MasterLogName -Append

Stop-Transcript
