$Location = "C:\Apps"
$AppName = "NotePad++"
# $AppDescription = "Notepad++ is a free source code editor and Notepad replacement that supports several languages. Running in the MS Windows environment, its use is governed by GPL License."
# $AppPublisher = "Don Ho"
# $AppUserDocumentation = "https://notepad-plus-plus.org/"
# $AppIcon = "Notepad++.ico"

# $PluginList = @("XMLTools", "ComparePlugin", "JSMinNPP", "mimeTools", "NppConverter")
$PluginList = @("XMLTools", "ComparePlugin")
$DefaultEditor = $false

$DestinationPath = "$Location\$AppName"
#Download App
if ( -Not (Test-Path -Path $DestinationPath ) ) {New-Item -ItemType directory -Path $DestinationPath} 
$LinkPath = ((Invoke-WebRequest https://github.com/notepad-plus-plus/notepad-plus-plus/releases/latest -UseBasicParsing)| Select-Object -ExpandProperty Links | Where-Object -Property href -Like "*npp.*.Installer.x64.exe").href
$URL = "https://github.com$LinkPath"
$DownloadFileName = "NotePadppInstallerx64.exe"
$Version = (Get-item $DestinationPath\$DownloadFileName).VersionInfo.FileVersion

## $DownloadFileNamex86 = "NotePadppInstallerx86.exe"
## $Versionx86 = (Get-item $TempDir\$DownloadFileName).VersionInfo.FileVersion

Invoke-WebRequest -uri $URL -Method Get -OutFile "$DestinationPath\$DownloadFileName"

#Install
#NotePad++ Silent Installer x64

& "$DestinationPath\$DownloadFileName" /noupdater /S


# OtherInfo
# UninstallCmd `"%ProgramFiles%\Notepad++\uninstall.exe`" /S

<#
Write-Output "Downloading plugin list"

$MasterPluginList = Invoke-RestMethod -Uri https://raw.githubusercontent.com/notepad-plus-plus/nppPluginList/master/src/pl.x64.json -UseBasicParsing

foreach ($Plugin in $PluginList)
{
    Write-Output "Locating Plugin $Plugin"

    $PluginData = $MasterPluginList.'npp-plugins' | Where-Object {$_.'folder-name' -eq $Plugin}

    if ($null -eq $PluginData)
    {
        Write-Warning "Unable to locate Plugin $Plugin"
        continue
    }

    $DownloadLocation = New-TemporaryFile
    $NewFileName = $DownloadLocation.FullName.Replace($DownloadLocation.Extension,'.zip')
    Rename-Item -Path $DownloadLocation.FullName -NewName $NewFileName -Force

    Write-Output "Downloading $($PluginData.repository)"

    Invoke-WebRequest -Uri $PluginData.repository -OutFile $NewFileName -UseBasicParsing

    $DestinationPath = Join-Path -Path (Join-Path -Path $env:ProgramFiles -ChildPath "Notepad++/plugins") -ChildPath $Plugin

    Expand-Archive -Path $NewFileName -DestinationPath $DestinationPath -Force
}#>

<#
if ($DefaultEditor)
{
    Write-Output "Setting Notepad Plus Plus as default text editor"

    #Update references to notepad to always run notepad++ https://npp-user-manual.org/docs/other-resources/#notepad-replacement
    New-Item -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe" -Force
    New-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe" -Name "Debugger" -Value "`"$($env:ProgramFiles)\Notepad++\notepad++.exe`" -notepadStyleCmdline -z"
}
#>