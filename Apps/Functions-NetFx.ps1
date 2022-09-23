#Functions
# Test-DotNet35  # Checks if .NET Framework 3.5 is installed
# Install-DotNet35 Downloads and installs .NET Framework 3.5
# Test-DotNet4x # Checks if .NET Framework 4.x is installed
# Install-DotNet4x # Downloads and installs .NET Framework 4.8 (newest as of 2019-11-19)

# Checks if .NET Framework 3.5 is installed
Function Test-DotNet35 {
    [cmdletbinding()]
    Param ()
    #End of parameters
    Process {
        If (Test-Path -Path ('HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v3.5')) {
            $dotNet45RegistryKey = (Get-RegistryKey -Key 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v3.5')
            If (($dotNet45RegistryKey.Install) -eq 1) {
                Write-Log -Message ('.NET Framework 3.5 found.')
                return ([bool]$true)
            }
        }
        Write-Log -Message ('.NET Framework 3.5 not found.')
        return ([bool]$false)
    }
}

# Downloads and installs .NET Framework 3.5
Function Install-DotNet35 {
    [cmdletbinding()]
    Param ()
    #End of parameters
    Process {
        Write-Log -Message ('Downloading .NET Framework 3.5')
        Execute-Process -Path 'DISM.exe' -Parameters ('/Online /Enable-Feature /FeatureName:NetFx3 /All')
        If ($?) {
            Write-Log -Message ('.NET Framework 3.5 installed')
        }
        else {
            Write-Log -Message ('Error installing .NET Framework 3.5')
        }
    }
}

# Test-DotNet4x # Checks if .NET Framework 4.x is installed
Function Test-DotNet4x {
    [cmdletbinding()]
    Param (
        [Parameter(Position=0,Mandatory=$true)]
        [string]$MinVersion
    )
    #End of parameters
    Process {
        Switch ($MinVersion) {
            [version]'4.5' {$minRelease = 378389}
            [version]'4.5.1' {$minRelease = 378675}
            [version]'4.5.2' {$minRelease = 379893}
            [version]'4.6' {$minRelease = 393295}
            [version]'4.6.1' {$minRelease = 394254}
            [version]'4.6.2' {$minRelease = 394802}
            [version]'4.7' {$minRelease = 460798}
            [version]'4.7.1' {$minRelease = 461308}
            [version]'4.7.2' {$minRelease = 461808}
            [version]'4.8' {$minRelease = 528040}
        }
        
        If (Test-Path -Path ('HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full')) {
            $dotNet45RegistryKey = (Get-RegistryKey -Key ('HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full'))
            If (($dotNet45RegistryKey.Release) -ge $minRelease) {
                Write-Log -Message ('.NET Framework ' + $Version + ' found.')
                return ([bool]$true)
            }
            else {
                Write-Log -Message ('.NET Framework ' + $Version + ' or higher not found')
                return ([bool]$false)
            }
        }
        else {
            Write-Log -Message ('.NET Framework ' + $Version + ' not installed')
            return ([bool]$false)
        }
    }
}

# Install-DotNet4x # Downloads and installs .NET Framework 4.8 (newest as of 2019-11-19)
# .NET 4.8 is backwards compatible so why install older versions?
Function Install-DotNet4x {
    [cmdletbinding()]
    Param ()
    Process {
        Write-Log -Message ('Downloading .NET Framework 4.8')
        $dotNetDownload = @{
            Uri = 'https://download.visualstudio.microsoft.com/download/pr/014120d7-d689-4305-befd-3cb711108212/0fd66638cde16859462a6243a4629a50/ndp48-x86-x64-allos-enu.exe';
            Destination = ($dirSupportFiles + '\' + 'NDP48-x86-x64-AllOS-ENU.exe');
            Sha256 = '9B1F71CD1B86BB6EE6303F7BE6FBBE71807A51BB913844C85FC235D5978F3A0F'
        }
        If (Get-FileFromUri @dotNetDownload) {
            Write-Log -Message ('Installing .NET Framework 4.8')
            If (Execute-Process -Path ($dirSupportFiles + '\' + 'NDP48-x86-x64-AllOS-ENU.exe') -Parameters ('/q /norestart')) {
                Write-Log -Message ('.NET Framework 4.8 installed')
                return ([bool]$true)
            }
            else {
                Write-Log -Message ('Error installing .NET Framework 4.8')
                return ([bool]$false)
            }
        }
        else {
            Write-Log -Message ('Error downloading .NET Framework 4.8')
            return ([bool]$false)
        }
    }
}

