function Get-OSDetails {
    Try {
        $Script:ComputerInfo = Get-ComputerInfo | Select-Object CsManufacturer,CsModel,OsName,OsArchitecture,OsBuildNumber
        #OS Architecture
        If ($ComputerInfo.OsArchitecture -eq "64-Bit") {
            $Script:OSArch = "x64"
            $Script:OSBits = "64-bit"
        }
        Else {
            $Script:OSArch = "x86"
            $Script:OSBits = "32-bit"
        }
        #OS Version
        If ($ComputerInfo.OsBuildNumber -notlike "19*") {
            $Script:WinVer = "Win11"
        }
        Else {
            $Script:WinVer = "Win10"
        }
    }
    Catch {
        Write-Host "FAILURE: Unable to get OS Details" -ForegroundColor Red
        Start-Sleep 3
        Exit 1603
    }
    Write-Host "Computer Identified as:" -ForegroundColor Yellow
    Write-Host "$($ComputerInfo.CsManufacturer) $($ComputerInfo.CsModel)" -ForegroundColor Blue
    Write-Host "OS Identified as:" -ForegroundColor Yellow
    Write-Host "$($WinVer) $($OSBits)" -ForegroundColor Blue
}
function Set-StartMenu {
    If ($WinVer -eq "Win11") {
        Write-Host "Importing Win 11 Start Menu binary"
        $Win11StartDir = "C:\Users\Default\AppData\Local\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState"
        New-Item -ItemType Directory -Path $Win11StartDir -Force
        #mkdir "C:\Users\Default\AppData\Local\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState"
        Copy-Item "$PSScriptRoot\start.bin" $Win11StartDir -Force
        #xcopy.exe "$PSScriptRoot\start.bin" $Win11StartDir /i /v /y
        Write-Host "Importing Win 11 Taskbar layout"
        $Win11TaskbarDir = "C:\Users\Default\AppData\Local\Microsoft\Windows\Shell\"
        Copy-Item "$PSScriptRoot\Win11Layout.xml" "$($Win11TaskbarDir)LayoutModification.xml" -Force
        Write-Host "Modifying Default Windows 11 Taskbar Options"
        REG LOAD HKLM\Default C:\Users\Default\NTUSER.DAT
        # Removes Task View from the Taskbar
        New-ItemProperty "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value "0" -PropertyType Dword -Force -ErrorAction Continue
        # Removes Widgets from the Taskbar
        New-ItemProperty "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Value "0" -PropertyType Dword -Force -ErrorAction Continue
        # Removes Chat from the Taskbar
        New-ItemProperty "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarMn" -Value "0" -PropertyType Dword -Force -ErrorAction Continue
        # Default StartMenu alignment 0=Left
        New-ItemProperty "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Value "0" -PropertyType Dword -Force -ErrorAction Continue
        # Removes search from the Taskbar
        reg.exe add "HKLM\Default\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v SearchboxTaskbarMode /t REG_DWORD /d 0 /f
        REG UNLOAD HKLM\Default
        #Kill Consumer Teams Chat
        reg.exe add "HKLM\Software\Policies\Microsoft\Windows\Windows Chat" /v ChatIcon /t REG_DWORD /d 3 /f
    }
    Else {
        Write-Host "Importing Win 10 layout"
        Copy-Item "$PSScriptRoot\Win10Layout.xml" "C:\Users\Default\AppData\Local\Microsoft\Windows\Shell\LayoutModification.xml" -Force
    }
}