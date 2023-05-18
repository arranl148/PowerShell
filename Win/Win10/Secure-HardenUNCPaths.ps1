#HardenUNCPaths
$Paths = @(
'\\*\NETLOGON',
'\\*\SYSVOL'
)

$Paths | % {
	$ItemPropertyParams = @{
		Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\NetworkProvider\HardenedPaths';
		Name = $_;
		PropertyType = 'String';
		Value = 'RequireMutualAuthentication=1, RequireIntegrity=1'
		}
	New-ItemProperty @ItemPropertyParams -Force
}