# Hide 3D Objects for user
$registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag"
$Name = "ThisPCPolicy"
# Hide = Hidden, Show or remove key(default)= Show 3d Objects for machine
$value = "Hide"
$DataType = 'String'

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