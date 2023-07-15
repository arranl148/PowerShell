<#
    .SYNOPSIS
    Installs either the most recent stable, or the latest release version of the Windows Package Manager (Winget).

    .NOTES
    Version:        1.0
    Author:         James Robinson
    Creation Date:  18/08/2022

    .EXAMPLE
        Install-Winget.ps1 -Stable
    
    .EXAMPLE
        Install-Winget.ps1 -Latest
#>


[CmdletBinding()]
Param (
    [Parameter(Mandatory=$False)] [Switch] $Stable = $False,
    [Parameter(Mandatory=$False)] [Switch] $Latest = $False
)


<# VARIABLES #>
#Permalink URL for Stable and GitHub URL to get latest release
$Script:WingetURL = 'https://aka.ms/getwinget'
$Script:WingetGit = 'https://api.github.com/repos/microsoft/winget-cli/releases'

# Logging Settings
$Script:LogFile = "InstallWinget-$env:COMPUTERNAME.log"
$Script:LogsFolder = New-Item -ItemType "Directory" -Path "$env:ProgramData\Intune Deployment\Logs" -Force -ErrorAction SilentlyContinue


<# FUNCTIONS #>
function Start-Logging {
    # Start log transcription
    Start-Transcript -Path $LogsFolder\$LogFile -Append
    Write-Host "Current script timestamp: $(Get-Date -f yyyy-MM-dd_HH-mm)"
}

function Install-WingetStable {
    #Download Stable Winget MSIXBundle
    Write-Host "Downloading Winget from: $($WingetURL)"
    $WebClient = New-Object System.Net.WebClient
    $WebClient.DownloadFile($WingetURL, "$env:Temp\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle")
    
    #Install WinGet MSIXBundle
    Try {
        Write-Host "Installing MSIXBundle for App Installer..."
        Add-AppxProvisionedPackage -Online -PackagePath "$env:Temp\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -SkipLicense | Out-Null
    }
    Catch {
        Write-Host "FAILURE: Failed to install MSIXBundle for Winget Installer!" -ForegroundColor Red
        Write-Error $_
        Start-Sleep 3
    } 
}

function Install-WingetLatest {
    #Get latest release from GitHub
    $LatestWingetVer = ((Invoke-WebRequest $WingetGit -UseBasicParsing | ConvertFrom-Json)[0].tag_name)
    #Form download URL
    $WingetGitURL = "https://github.com/microsoft/winget-cli/releases/download/$($LatestWingetVer)/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
    #Set file output
    $DLOut = "$env:Temp\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
    
    #Download Latest Winget MSIXBundle
    Write-Host "Downloading Winget from: $($WingetGitURL)"
    Invoke-RestMethod -Uri $WingetGitURL -OutFile $DLOut
    
    #Install WinGet MSIXBundle
    Try {
        Write-Host "Installing MSIXBundle for App Installer..."
        Add-AppxProvisionedPackage -Online -PackagePath "$env:Temp\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -SkipLicense | Out-Null
    }
    Catch {
        Write-Host "FAILURE: Failed to install MSIXBundle for Winget Installer!" -ForegroundColor Red
        Write-Error $_
        Start-Sleep 3
    } 
}

function Test-WingetInstall {
    Write-Host "Testing Winget Install"
        $TestWinget = Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like "Microsoft.DesktopAppInstaller" }
        $WingetVer = $TestWinget.Version

        If ($TestWinget) {
            Write-Host "Winget found. Version $WingetVer"
            Write-Host "SUCCESS: Installed MSIXBundle for App Installer" -ForegroundColor Green
            #Remove WinGet MSIXBundle
            Remove-Item -Path "$env:Temp\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -Force -ErrorAction Continue
            Start-Sleep 3
            Exit 0 #Success
            
        }
        Else {
            Write-Host "FAILURE: Failed to verify Winget Install!" -ForegroundColor Red
            Write-Error $_
            Start-Sleep 3
            Exit 1618 #Retry
        }  
}


<# MAIN #>
Start-Logging

Write-Host "###################################"
Write-Host "#                                 #"
Write-Host "#        Winget Installer         #"
Write-Host "#                                 #"
Write-Host "###################################`n"

Try {
    If ($Stable.IsPresent) {
        Install-WingetStable
    }
    If ($Latest.IsPresent) {
        Install-WingetLatest
    }
}

Catch {
    Write-Error $_
    Exit 1618 #Retry
}

Finally {
    Test-WingetInstall
}

Stop-Transcript