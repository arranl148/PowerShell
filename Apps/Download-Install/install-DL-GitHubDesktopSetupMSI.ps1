# Source URL
$url = "https://central.github.com/deployments/desktop/desktop/latest/win32?format=msi"

# Destation file
$dest = "d:\apps\GitHubDesktopSetup-x64.msi"

# Download the file
Invoke-WebRequest -Uri $url -OutFile $dest

try{
$return = Start-Process -FilePath $dest -ArgumentList "/qb /norestart" 
}
Catch{return "Download failed"}