<# Ref https://learn.microsoft.com/en-gb/mem/configmgr/osd/get-started/prepare-site-system-roles-for-operating-system-deployments
 v0.1 19 May 23 Arran
 
To customize the RamDisk TFTP window size. The default value is 1 (one data block fills the window).
Also to customize the RamDisk TFTP window size. The default value is 4096.

Location: HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\SMS\DP
Name: RamDiskTFTPWindowSize
Type: REG_DWORD
Value: (customized window size) 

Location: HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\SMS\DP
Name: RamDiskTFTPBlockSize
Type: REG_DWORD
Value: (customized block size) .#>
# TODO Add log file

# TODO Add where these suggested values came from
$TFTPWindowSize = 16
$TFTPBlockSize = 8192

$SMSDPRegkey = HKLM:SOFTWARE\Microsoft\SMS\DP

Set-ItemProperty -Path "$SMSDPRegkey" -Name "RamDiskTFTPWindowSize" -Value $TFTPWindowSize
Set-ItemProperty -Path "$SMSDPRegkey" -Name "RamDiskTFTPWindowSize" -Value $TFTPBlockSize

