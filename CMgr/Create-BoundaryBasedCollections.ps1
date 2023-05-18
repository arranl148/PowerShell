<#
#This script is more of a suggestion of "where to start note" than a fully fledged script
#The problem:
# Our customer has multiple AD Sites and we want to create a collection for each

# The starting point
$server = "PSSiteServer.fqdn" 
$server1 = "MPDPSUPServer.fqdn"
 
$boundaryGroupID = (Get-CMBoundaryGroup).GroupID 
foreach ($boundary in $boundaryGroupID) {
    Set-CMBoundaryGroup -Id $boundary -AddSiteSystemServerName $server, $server1
    }

#	https://gallery.technet.microsoft.com/scriptcenter/Export-boundaries-from-7c4f850b

# I lifted the beautifully succinct split command from this import script 
#	https://www.sccmog.com/import-ip-boundaries-boundary-groups-powershell-sccm-configmgr/
#>

# If the site code has not been defined get it
if ($SiteCode -eq $null)
	{
	$LookForSiteCode = Get-WmiObject -Namespace "root\SMS" -Class SMS_ProviderLocation -ComputerName $env:COMPUTERNAME -ErrorAction Stop 
	foreach ($ObjSiteCode in $LookForSiteCode) 
		{ 
			if ($ObjSiteCode.ProviderForLocalSite -eq $true) 
			{ 
			$SiteCode = $ObjSiteCode.SiteCode 
			} 
		} 
	$SitePath = $SiteCode + ":" 
  
	#I have assumed we need to import the module if the site code as not been defined
	Import-module ($Env:SMS_ADMIN_UI_PATH.Substring(0, $Env:SMS_ADMIN_UI_PATH.Length - 5) + '\ConfigurationManager.psd1') 
	}
      
Set-Location $SitePath 

    $BoundariesSubnet = (Get-CMBoundary -BoundaryName * | Where-Object {$_.BoundaryType -like "0"}) 
    $BoundariesADSite = (Get-CMBoundary -BoundaryName * | Where-Object {$_.BoundaryType -like "1"}) 
    $BoundariesIPV6 = (Get-CMBoundary -BoundaryName * | Where-Object {$_.BoundaryType -like "2"}) 
    $BoundariesRange = (Get-CMBoundary -BoundaryName * | Where-Object {$_.BoundaryType -like "3"}) 
    $BoundariesVPN = (Get-CMBoundary -BoundaryName * | Where-Object {$_.BoundaryType -like "4"}) 
 
If ($BoundariesADSite.count -gt "0") 
    { 
         #Collection specific variables
		 $RefreshSchedule = New-CMSchedule -RecurInterval Days -RecurCount 7
		 $LimitingCollection = "All Desktop and Server Clients"
		 foreach ($Boundary in $BoundariesADSite) 
            { 
                #Split on / and use to create 2 variables (DisplayName was BoundaryName)
				$DomainFQDN,$ADSiteName = $_.DisplayName.split('/',2)
				if ([string]::IsNullOrWhiteSpace($ADSiteName)) {
					New-CMDeviceCollection -Name "ADSite Clients - $ADSiteName" -LimitingCollectionName $LimitingCollection -RefreshSchedule $RefreshSchedule -RefreshType 2
					Add-CMDeviceCollectionQueryMembershipRule -CollectionName "ADSite Clients - $ADSiteName" -QueryExpression "select * from SMS_R_System where SMS_R_System.ADSiteName = '$ADSiteName'" -RuleName $ADSiteName
				}
            } 
    } 



