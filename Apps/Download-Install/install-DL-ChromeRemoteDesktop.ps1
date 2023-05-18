# Source URL
$url = "https://dl.google.com/edgedl/chrome-remote-desktop/chromeremotedesktophost.msi"

# Destation file
$dest = "c:\apps\chromeremotedesktophost.msi"

# Download the file
Invoke-WebRequest -Uri $url -OutFile $dest

try{
$return = Start-Process -FilePath $dest -ArgumentList "/qb /norestart" 
}
Catch{return "Download failed"}