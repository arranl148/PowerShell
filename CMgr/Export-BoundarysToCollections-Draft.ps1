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
    $ErrorActionPreference = 'Continue' 


     If ($BoundariesADSite.count -gt "0") 
    { 
         #Collection specific variables
		 $RefreshSchedule = New-CMSchedule –RecurInterval Days –RecurCount 7
		 $LimitingCollection = "All Desktop and Server Clients"
		 foreach ($Boundary in $BoundariesADSite) 
            { 
                #Split on /
				$DomainFQDN,$ADSiteName = $Boundary.DisplayName.split('/',2)
				$CollectionName = "ADSite Clients - $ADSiteName"
				If (Get-CMDeviceCollection -Name "$CollectionName") {
					Write-Host "Collection $CollectionName already exists, skipping"
					} 
					Else { 
						New-CMDeviceCollection -Name "ADSite Clients - $ADSiteName" -LimitingCollectionName $LimitingCollection -RefreshSchedule $RefreshSchedule -RefreshType 2
						Add-CMDeviceCollectionQueryMembershipRule -CollectionName "ADSite Clients - $ADSiteName" -QueryExpression "select * from SMS_R_System where SMS_R_System.ADSiteName = '$ADSiteName'" -RuleName $ADSiteName
						}
            } 
    } 

    $IPrange = $null 
    $IPrange = @{} 
    $IPSubnet = $null 
    $IPSubnet = @{}     
	If ($BoundariesSubnet.count -gt "0") 
    { 
        foreach ($Boundary in $BoundariesSubnet) 
            { 
                $IPrange.Add($($Boundary.DisplayName),$($Boundary.Value)) 
 
            } 
                $IPrange.GetEnumerator() | export-csv "$DestinationPath\BoundariesIPSubnet.csv" -NoTypeInformation -Encoding Unicode 
    } 

    If ($BoundariesRange.count -gt "0") 
    { 
        foreach ($Boundary in $BoundariesRange) 
            { 
                $IPSubnet.Add($($Boundry.DisplayName),$($Boundry.Value)) 
 
            } 
                $IPSubnet.GetEnumerator() | export-csv "$DestinationPath\BoundariesIPRange.csv" -NoTypeInformation -Encoding Unicode 
    } 
         
