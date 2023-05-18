$Java8341x64 = "C:\Program Files\Java\jre1.8.0_341\bin\javaw.exe"
$Java8341x86 = "C:\Program Files (x86)\Java\jre1.8.0_341\bin\javaw.exe"
$Testx64 = (Test-Path $Java8341x64)
$Testx86 = (Test-Path $Java8341x86)

$GATickets = "C:\Program Files (x86)\Java\jre1.8.0_341\lib\ext\GATickets.jar"
$TestGATickets = (Test-Path $GATickets)

$JavaUpdatePolicyx64 = "HKLM:SOFTWARE\JavaSoft\Java Update\Policy"
$JavaUpdatePolicyWow6432 = "HKLM:SOFTWARE\Wow6432Node\JavaSoft\Java Update\Policy"

#Checking for
# $EnableJavaUpdate = "HKLM:SOFTWARE\Wow6432Node\JavaSoft\Java Update\Policy" -Name "EnableJavaUpdate" -Value '0' -Type 'Dword'
# $EnableAutoUpdateCheck = "HKLM:SOFTWARE\Wow6432Node\JavaSoft\Java Update\Policy" -Name "EnableAutoUpdateCheck" -Value '0' -Type 'Dword'

# Functions
# This function just gets $true or $false
function Test-RegistryValue($path, $name)
{
    $key = Get-Item -LiteralPath $path -ErrorAction SilentlyContinue
    $key -and $null -ne $key.GetValue($name, $null)
}

# Gets the specified registry value or $null if it is missing
function Get-RegistryValue($path, $name)
{
    $key = Get-Item -LiteralPath $path -ErrorAction SilentlyContinue
    if ($key) {
        $key.GetValue($name, $null)
    }
}

<#
# Test existing value
Test-RegistryValue $JavaUpdatePolicyx64 EnableJavaUpdate
$val = Get-RegistryValue $JavaUpdatePolicyx64 EnableJavaUpdate
if ($val -eq $null) { 'missing value' } else { $val }

# Test missing value
Test-RegistryValue HKCU:\Console missing
$val = Get-RegistryValue HKCU:\Console missing
if ($val -eq $null) { 'missing value' } else { $val }
#>

# return true if value = 0
$TestEnableJavaUpdate64 = if (Test-RegistryValue -Path $JavaUpdatePolicyx64 -Name 'EnableJavaUpdate') {
    $val = Get-RegistryValue $JavaUpdatePolicyx64 EnableJavaUpdate
    if ($val -eq 0) {$true} 
        else { $false }
    } else { $false }

# return true if value = 0
$TestEnableJavaUpdate32 = if (Test-RegistryValue -Path $JavaUpdatePolicyWow6432 -Name 'EnableJavaUpdate') {
    $val = Get-RegistryValue $JavaUpdatePolicyWow6432 EnableJavaUpdate
    if ($val -eq 0) {$true} 
        else { $false }
    } else { $false }

# return true if value = 0
$TestEnableAutoUpdateCheck64 = if (Test-RegistryValue -Path $JavaUpdatePolicyx64 -Name 'EnableAutoUpdateCheck') {
    $val = Get-RegistryValue $JavaUpdatePolicyx64 EnableAutoUpdateCheck
    if ($val -eq 0) {$true} 
        else { $false }
    } else { $false }

# return true if value = 0, return falseif not present, null or other value
$TestEnableAutoUpdateCheck32 = if (Test-RegistryValue -Path $JavaUpdatePolicyWow6432 -Name 'EnableAutoUpdateCheck') {
    $val = Get-RegistryValue $JavaUpdatePolicyWow6432 'EnableAutoUpdateCheck'
    if ($val -eq 0) {$true} 
        else { $false }
    } else { $false }


If ($Testx64 -and $Testx86 -and $TestGATickets -eq $true){
    "Both versions of Java are installed"
    If ($TestEnableAutoUpdateCheck32 -and $TestEnableAutoUpdateCheck64 -and $TestEnableJavaUpdate32 -and $TestEnableJavaUpdate64 -eq $true){
        #"All update checks set to 0" 
        $True
        }

    #$True
}

If ($Testx64 -eq $True -and $Testx86 -ne $True){
    "Java 8 341 x64 is installed, but x86 isn't"
}

If ($Testx64 -ne $True -and $Testx86 -eq $True){
    "Java 8 341 x86 is installed, but x64 isn't"
}


##########
# Write-Host "TestEnableJavaUpdate64 is $TestEnableJavaUpdate64"
# Write-Host "TestEnableJavaUpdate32 is $TestEnableJavaUpdate32"
 
# Write-Host "TestEnableAutoUpdateCheck64 is $TestEnableAutoUpdateCheck64"
# Write-Host "TestEnableAutoUpdateCheck32 is $TestEnableAutoUpdateCheck32"

<#
        Start-Process "$DirFiles\jre-8u341-windows-x64.exe" -ArgumentList "/s /l $env:SystemRoot\Temp\Javax64Install.log AUTO_UPDATE=Disable INSTALL_SILENT=Enable" -Wait
        "x86"
        Start-Process "$DirFiles\jre-8u341-windows-i586.exe" -ArgumentList "/s /l $env:SystemRoot\Temp\Javax86Install.log AUTO_UPDATE=Disable INSTALL_SILENT=Enable"" -Wait
#>