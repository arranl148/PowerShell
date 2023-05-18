$RepoDriveLetter = "D:"
cd "$RepoDriveLetter\Repo\Win\Forks\Nerdile"
# Convert a Windows 10 WIM file to VHDX file using Convert-WindowsImage.ps1 fork from https://github.com/nerdile/convert-windowsimage 
$WimFile = "$RepoDriveLetter\WIM\REFW10-X64-22H2-Enterprise.wim"
$Edition = "Windows 10 Enterprise"
$OutPutVHDXFile = "$RepoDriveLetter\VHD\AP-W10-22H2.vhdx"

# Create UEFI-based VHDX file
& .\Convert-WindowsImage.ps1 -SourcePath $WimFile -Edition $Edition -VHDPath $OutPutVHDXFile -VHDFormat VHDX -VHDType Dynamic -VHDPartitionStyle GPT -SizeBytes 240GB


# Convert a Windows 11 21H2 WIM file to VHDX file using Convert-WindowsImage.ps1 fork from https://github.com/nerdile/convert-windowsimage 
$WimFile = "$DriveLetter\WIM\REFW11-X64-21H2-Enterprise.wim"
$Edition = "Windows 11 Enterprise"
$OutPutVHDXFile = "$DriveLetter\VHD\AP-W11-21H2.vhdx"

# Create UEFI-based VHDX file
$Nerdile\Convert-WindowsImage.ps1 -SourcePath $WimFile -Edition $Edition -VHDPath $OutPutVHDXFile -VHDFormat VHDX -VHDType Dynamic -VHDPartitionStyle GPT -SizeBytes 240GB


# Convert a Windows 11 22H2 WIM file to VHDX file using Convert-WindowsImage.ps1 fork from https://github.com/nerdile/convert-windowsimage 
$WimFile = "$RepoDriveLetter\WIM\REFW11-X64-22H2-Enterprise.wim"
$Edition = "Windows 11 Enterprise"
$OutPutVHDXFile = "$RepoDriveLetter\VHD\AP-W11-22H2.vhdx"

# Create UEFI-based VHDX file
d:\Repo\Win2\Forks\Nerdile\Convert-WindowsImage.ps1 -SourcePath $WimFile -Edition $Edition -VHDPath $OutPutVHDXFile -VHDFormat VHDX -VHDType Dynamic -VHDPartitionStyle GPT -SizeBytes 240GB

