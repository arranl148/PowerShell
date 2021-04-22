$RegistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent'
$RegValue = 'DisableWindowsConsumerFeatures'
$RegType = 'DWORD'
$RegData = '1'
if( -not (Test-Path -Path $RegistryPath)) {
    New-Item -Path $RegistryPath -Force
    }
    New-ItemProperty -Path $RegistryPath -Name $RegValue -PropertyType $RegType -Value $RegData