#Scan the registry to get which SQL installed and what version 
$SQLInstances = (get-itemproperty 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server').InstalledInstances
foreach ($Instance in $SQLInstances)
{
   $p = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL').$Instance
   (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$p\Setup").Edition
   (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$p\Setup").PatchLevel
#   (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$p\Setup").Version
}