Function Convert-CMAppToIntuneWin {
# Credit to https://www.joseespitia.com/2022/11/03/convert-cmapptointunewin-function/
    param (
        [parameter(Mandatory=$True)]
        [string]$AppName,
        [parameter(Mandatory=$False)]
        [string]$OutputFolder
    )

    Try {

        # Download IntuneWinAppUtil.exe from Microsoft's GitHub repository
        Invoke-WebRequest -Uri "https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool/raw/master/IntuneWinAppUtil.exe" -OutFile "$env:TEMP\IntuneWinAppUtil.exe"

    }
    Catch {
        
        Write-Host "Failed to download the Win32App Migration Tool!" -Foreground Red
        Pause
        Exit

    }
    $Application = Get-CMApplication -Name $AppName

    If($null -ne $Application) {

        If([string]::IsNullOrEmpty($OutputFolder)) {

            $StagingFolder = "$env:TEMP\$AppName"

        }
        Else {

            $StagingFolder = ($OutputFolder -replace '\\$','') + '\' + $AppName

        }

        [xml]$XML = $Application.SDMPackageXML

        ForEach($DeploymentType in $XML.AppMgmtDigest.DeploymentType) {
        
            If($DeploymentType.Installer.InstallAction.Provider -ne "Windows8App") {

                # Query required information
                $DeploymentTypeTitle = $DeploymentType.Title.'#text'
                $WorkingDir = ($DeploymentType.Installer.InstallAction.Args.Arg | Where-Object {$_.Name -eq "WorkingDirectory"}).'#Text'
                $SetupFile = ($DeploymentType.Installer.InstallAction.Args.Arg | Where-Object {$_.Name -eq "InstallCommandLine"}).'#Text' -replace '\s.*',''

                If($null -eq $WorkingDir) {

                    $ContentSource = $DeploymentType.Installer.Contents.Content.Location -replace '\\$',''

                }
                Else{

                    $ContentSource = ($DeploymentType.Installer.Contents.Content.Location -replace '\\$','') + '\' + $WorkingDir

                }
                If([System.IO.File]::Exists("$ContentSource\$SetupFile")) {

                    # Create subdirectory for the deployment type
                    New-Item "$StagingFolder\$DeploymentTypeTitle" -ItemType Directory -Force | Out-Null

                    # Convert application to .intunewin
                    Start-Process "$env:TEMP\IntuneWinAppUtil.exe" -ArgumentList "-c `"$ContentSource`" -s `"$SetupFile`" -o `"$StagingFolder\$DeploymentTypeTitle`" -q" -Wait

                }
                Else{

                    Write-Host "$ContentSource\$SetupFile does not exist! IntuneWinAppUtil.exe requires the setup file to be in the content source." -ForegroundColor Red
                    Pause
                    Exit

                }

            }
            Else {

                Write-Host "This script does not support Microsoft Store apps!" -ForegroundColor Red
                Pause
                Exit

            }

        }
        If([System.IO.Directory]::Exists("$StagingFolder")) {

            Start-Process "$StagingFolder"

        }

    }
    Else {

        Write-Host "Could not locate $AppName in the ConfigMgr console!" -ForegroundColor Red
        Pause
        Exit

    }

}