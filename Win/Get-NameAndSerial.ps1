# Get the FQDN of the computer
$fqdn = (Get-WmiObject -Class Win32_ComputerSystem).DNSHostName

# Get the serial number of the computer
$serial = (Get-WmiObject -Class Win32_BIOS).SerialNumber

# Output the results
Write-Output "FQDN: $fqdn"
Write-Output "Serial Number: $serial"
