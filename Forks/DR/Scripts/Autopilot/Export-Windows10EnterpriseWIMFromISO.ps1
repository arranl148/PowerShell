# Script to extract the Windows 10 Enterprise index from a Windows 10 media.
# Update line 5 - 8 to match your environment

# General parameteers
$dir = "D:\iso"
$latest = Get-ChildItem -Path $dir -Filter "en-gb_windows_10_business_editions_version_22h2*.iso" | Sort-Object LastAccessTime -Descending | Select-Object -First 1
$ISO = Join-Path -path $dir -ChildPath $latest.name # Path to Windows 11 media
#$ISO = "D:\iso\en-gb_windows_11_business_editions_version_22h2_updated_feb_2023_x64_dvd_e6541401.iso" 
$WIMPath = "D:\WIM" # Target folder for extracted WIM file containing Windows 11 Enterprise only
$WIMFile = "$WIMPath\REFW10-X64-22H2-Enterprise.wim" # Exported WIM File
$Edition = "Windows 10 Enterprise" # Edition to export. Note: If using Evaluation Media, use: Windows 11 Enterprise Evaluation 

# Goal is to have a single index WIM File, so checking if target WIM File exist, and abort if it does.
If (Test-path $WIMFile){
    Write-Warning "WIM File: $WimFile does already exist. Rename or delete the file, then try again. Aborting..."
    Break 
}

# ISO Validationc
If (-not (Test-path $ISO)){
    Write-Warning "ISO File: $ISO does not exist, aborting..."
    Break 
}

# Mount ISO
Mount-DiskImage -ImagePath $ISO | Out-Null
$ISOImage = Get-DiskImage -ImagePath $ISO | Get-Volume
$ISODrive = [string]$ISOImage.DriveLetter+":"

# Source WIM validation
$SourceWIMFile = "$ISODrive\sources\install.wim"
If (-not (Get-WindowsImage -ImagePath $SourceWIMFile | Where-Object {$_.ImageName -ilike "*$($Edition)"})){
    Write-Warning "WIM Edition: $Edition does not exist in WIM: $SourceWIMFile, aborting..."
    Dismount-DiskImage -ImagePath $ISO | Out-Null
    Break
}

# Export WIM
If (!(Test-path $WIMPath)){ New-Item -Path $WIMPath -ItemType Directory -Force | Out-Null } # Create folder if needed
Export-WindowsImage -SourceImagePath $SourceWIMFile -SourceName $Edition -DestinationImagePath $WIMFile

# Dismount ISO
Dismount-DiskImage -ImagePath $ISO | Out-Null

