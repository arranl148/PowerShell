$RegistryPath = 'HKCU:\Software\Microsoft\Office\16.0\Outlook\Security'
$RegValue = 'Level1Remove'
$RegType = 'STRING'
$RegData = '.cer;.pfx'
if( -not (Test-Path -Path $RegistryPath)) {
    New-Item -Path $RegistryPath -Force
    }
New-ItemProperty -Path $RegistryPath -Name $RegValue -PropertyType $RegType -Value $RegData -Force