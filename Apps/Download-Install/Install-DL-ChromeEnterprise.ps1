#Copyright PowerON Platforms 2021 / Leo Darcy
#All rights reserved
#Email: leo.darcy@poweronplatforms.com

#Version 1.0

#Description
#Installs the Latest version of Google Chrome

$TempDir = "D:\buildArtifacts"
$LogPath = "D:\Image.log"
$AppName = "GoogleChrome"

$ErrorActionPreference = 'stop'

try
{
    Start-Transcript -Path (Join-Path -Path $TempDir -ChildPath "$AppName.log")

    $DownloadPath = Join-Path -Path $TempDir -ChildPath "$AppName.msi"

    Write-Output "Downloading $AppName"

    #Download file as built in downloader is awful for large files
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile('https://dl.google.com/edgedl/chrome/install/GoogleChromeStandaloneEnterprise64.msi', $DownloadPath) #Don't use Invoke-WebRequest due to poor performance in PS5.1

    Write-Output "Installing $DownloadPath"

    Start-Process -FilePath msiexec.exe -ArgumentList  "/i `"$DownloadPath`" /log `"$(Join-Path -Path $TempDir -ChildPath "$AppName-Install.log")`" /qn" -Wait

    Out-File -InputObject "Installed $AppName" -FilePath $LogPath -Append
}
catch
{
    Out-File -InputObject "!Install $AppName Failed" -FilePath $LogPath -Append
    Out-File -InputObject $_.Exception.Message -FilePath $LogPath -Append
    Write-Output "ERROR: $AppName Failed - $($_.Exception.Message)"
    throw "Install $AppName Failed: $($_.Exception.Message)"
}
finally
{
    Stop-Transcript
}