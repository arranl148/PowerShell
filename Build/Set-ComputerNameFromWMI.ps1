$tsenv = New-Object -ComObject Microsoft.SMS.TSEnvironment
$TSComputerName = $tsenv.value("OSDComputerName")

#Set the Prefered Prefix for The different Chassis Types Add More Prefixes in as required, and add them to the Chassis Switch Below
$PrefixDesktop = "DT"
$PrefixLaptop = "LT"
$PrefixTablet = "TB"
$PrefixUndefined = "UN"

#if you need a postfix.
$PostFixVM = "VM"

$ChassisType = $(Get-WmiObject CIM_Chassis).ChassisTypes
$SerialNumber = $(Get-WmiObject win32_bios).SerialNumber
$Platform = $(Get-WmiObject Win32_ComputerSystem).model

#PostFix IF.
if ($Platform -match "Vmware" -or $Platform -match "Virtual" -or $Platform -match "VirtualBox")
{
	$DevicePostFix = $PostFixVM
}
else
{
	$DevicePostFix = ""
}

#region Chassis Type
#A Unknown Chassis Type will default to CU (Chassis Unknown)
#Doesnt happen often but this will catch them
# For example the MSDN Article has not been updated with types 25-36
# https://msdn.microsoft.com/en-us/library/aa394474(v=vs.85).aspx
# https://blogs.technet.microsoft.com/brandonlinton/2017/09/15/updated-win32_systemenclosure-chassis-types/
#Define Which Chassis Type Gets which Prifix

switch ($ChassisType)
{
	1{ $DevicePrefix = $PrefixUndefined } #Other
	2{ $DevicePrefix = $PrefixUndefined } #Unknown
	3{ $DevicePrefix = $PrefixDesktop } #Desktop
	4{ $DevicePrefix = $PrefixDesktop } #Low-profile Desktop
	5{ $DevicePrefix = $PrefixUndefined } #Pizza Box
	6{ $DevicePrefix = $PrefixDesktop } #Mini Tower
	7{ $DevicePrefix = $PrefixDesktop } #Tower
	8{ $DevicePrefix = $PrefixTablet } #Portable
	9{ $DevicePrefix = $PrefixLaptop } #Laptop
	10{ $DevicePrefix = $PrefixLaptop } #Notebook
	11{ $DevicePrefix = $PrefixUndefined } #Handheld
	12{ $DevicePrefix = $PrefixUndefined } #DockingStation
	13{ $DevicePrefix = $PrefixDesktop } #All in One
	14{ $DevicePrefix = $PrefixUndefined } #SubNoteBook
	15{ $DevicePrefix = $PrefixDesktop } #Space Saving
	16{ $DevicePrefix = $PrefixUndefined } #Lunch Box
	17{ $DevicePrefix = $PrefixUndefined } #Main system chassis 
	18{ $DevicePrefix = $PrefixUndefined } #Expansion chassis
	19{ $DevicePrefix = $PrefixUndefined } #Subchassis
	20{ $DevicePrefix = $PrefixUndefined } #Bus-expansion chassis
	21{ $DevicePrefix = $PrefixUndefined } #Peripheral chassis
	22{ $DevicePrefix = $PrefixUndefined } #Storage chassis
	23{ $DevicePrefix = $PrefixUndefined } #Rack-mount chassis
	24{ $DevicePrefix = $PrefixUndefined } #Sealed-case computer
	25{ $DevicePrefix = $PrefixLaptop } #Multi-system chassis
	26{ $DevicePrefix = $PrefixLaptop } #Compact PCI 
	27{ $DevicePrefix = $PrefixLaptop } #Advanced TCA 
	28{ $DevicePrefix = $PrefixLaptop } #Blade 
	29{ $DevicePrefix = $PrefixLaptop } #Blade Enclosure 
	30{ $DevicePrefix = $PrefixLaptop } #Tablet 
	31{ $DevicePrefix = $PrefixLaptop } #Convertible 
	32{ $DevicePrefix = $PrefixLaptop } #Detachable 
	33{ $DevicePrefix = $PrefixLaptop } #IoT Gateway 
	34{ $DevicePrefix = $PrefixLaptop } #Embedded PC 
	35{ $DevicePrefix = $PrefixLaptop } #Mini PC  
	36{ $DevicePrefix = $PrefixLaptop } #Stick PC 	
	default { $DevicePrefix = "CU" }
}
#region Chassis Type

#region Build the Computer Name
#Normalise the Serial Number
if ($SerialNumber.Contains("-")) { $SerialNumber = $SerialNumber -replace "-", "" }

#region Name Length Check
#Ensure that the Prefix, Serial & Postfix is not too long

$Length = $DevicePrefix.Length + $SerialNumber.Length + $DevicePostFix.Length
$MaxLength = 15
if ($Length -gt $MaxLength)
{
	$OverLength = $Length - $MaxLength
	#For the First Part of the Serial
	$SerialNumber = $SerialNumber.SubString(0, $SerialNumber.Length - $OverLength)
	#or For the last part of the serial
	#$SerialNumber = $SerialNumber.SubString($OverLength, $SerialNumber.Length - $OverLength)
}
#endregion Name Length Check

$ComputerName = "$($DevicePrefix)$($SerialNumber)$($DevicePostFix)"
#endregion Build the Computer Name

#Set the OSDComputerName back to the TaskSequence.
$TSComputerName = $ComputerName
$tsenv.value("OSDComputerName") = $TSComputerName