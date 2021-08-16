<#    
    .NOTES 
    =========================================================================== 
     Created on:    4/10/2017  
     Modified on:   4/21/2017  
     Created by:    Timmy Andersson 
     Twitter:       @TimmyITdotcom 
     Blog:          www.timmyit.com 
    =========================================================================== 
    .DESCRIPTION 
        Export Subnet an IPRange Boundaries to CSV files. This script needs to run on the siteserver to work.  
        Specify Destination path with the parameter $DestinationPath 
#> 
[CmdletBinding(DefaultParameterSetName = 'DestinationPath')] 
param 
( 
[Parameter(Mandatory = $true, 
Position = 1)] 
$DestinationPath 
) 
BEGIN 
{ 
  
$SiteCodeObjs = Get-WmiObject -Namespace "root\SMS" -Class SMS_ProviderLocation -ComputerName $env:COMPUTERNAME -ErrorAction Stop 
    foreach ($SiteCodeObj in $SiteCodeObjs) 
    { 
        if ($SiteCodeObj.ProviderForLocalSite -eq $true) 
        { 
        $SiteCode = $SiteCodeObj.SiteCode 
        } 
    } 
 
$SitePath = $SiteCode + ":" 
  
Import-module ($Env:SMS_ADMIN_UI_PATH.Substring(0, $Env:SMS_ADMIN_UI_PATH.Length - 5) + '\ConfigurationManager.psd1') 
  
} 
PROCESS 
{ 
      
    Set-Location $SitePath 
    $BoundariesSubnet = (Get-CMBoundary -BoundaryName * | Where-Object {$_.BoundaryType -like "0"}) 
    $BoundariesRange = (Get-CMBoundary -BoundaryName * | Where-Object {$_.BoundaryType -like "3"}) 
    $ErrorActionPreference = 'Continue' 
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
         
} 
END 
{ 
    Invoke-Item $DestinationPath 
} 