# Show Version info on desktop for user
$registryPath = "HKCU:\Control Panel\Desktop"
$Name = "PaintDesktopVersion"
# Show = 1 or Hide(default)= 0
$value = "1"
$DataType = 'DWORD'

IF(!(Test-Path $registryPath))
 {
    New-Item -Path $registryPath -Force | Out-Null
    New-ItemProperty -Path $registryPath -Name $name -Value $value `
    -PropertyType $DataType -Force 
  #| Out-Null
  }
 ELSE {
    New-ItemProperty -Path $registryPath -Name $name -Value $value `
    -PropertyType $DataType -Force 
  # | Out-Null
  }