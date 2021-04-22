# Hide Cortana for user
$registryPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
$Name = "SearchboxTaskBarMode"
# 0 = Hidden, 1 = Show search or Cortana icon, 2 = Show search box(Default)
$value = "0"

IF(!(Test-Path $registryPath))
 {
    New-Item -Path $registryPath -Force | Out-Null
    New-ItemProperty -Path $registryPath -Name $name -Value $value `
    -PropertyType DWORD -Force 
  #| Out-Null
  }
 ELSE {
    New-ItemProperty -Path $registryPath -Name $name -Value $value `
    -PropertyType DWORD -Force 
  # | Out-Null
  }