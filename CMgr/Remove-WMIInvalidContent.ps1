    <#
    .Synopsis
       Repairs the "The package data in WMI is not consistent to PkgLib" errors after ConfigMgr2012R2 upgrade
    .DESCRIPTION
       This script repairs the "The package data in WMI is not consistent to PkgLib" errors after ConfigMgr2012R2 upgrade by
 searching for packages that appear to be in de Content Library according to WMI but are not there and do not exist anymore
 This cleanup will run against all distribution points and when invalid WMI instances are found, they will be removed.
 Detailed description of this issue: http://blogs.technet.com/b/configmgrteam/archive/2012/05/07/troubleshooting-content-mismatch-warnings-on-a-distribution-point-in-system-center-2012-configuration-manager.aspx?wa=wsignin1.0
 Script is to be used at own risk
    .EXAMPLE
       Remove-WMIInvalidContent.ps1 -Siteserver myserver.mydomain.com -Sitecode AAA
    .LINK
        http://gallery.technet.microsoft.com/Powershell-script-to-fix-81dc4e69
    .NOTES
        Written by Bart Serneels
        Assisted by Stijn Callebaut
    #>


param(
[parameter(Mandatory = $true)]
[string]$SiteServer,
[parameter(Mandatory = $true)]
[string]$SiteCode
)

$Namespace = "root\SMS\Site_" + $SiteCode
Write-Host "Getting all valid packages... " -NoNewline
$ValidPackages = Get-WMIObject -ComputerName $SiteServer -Namespace $Namespace -Query "Select * from SMS_ObjectContentExtraInfo"
Write-Host ([string]($ValidPackages.count) + " packages found.")

Write-Host "Getting all valid distribution points... " -NoNewline
$DistributionPoints = Get-WMIObject -ComputerName $SiteServer -Namespace $Namespace -Query "select * from SMS_DistributionPointInfo where ResourceType = 'Windows NT Server'"
Write-Host ([string]($DistributionPoints.count) + " distribution points found.")
Write-Host ""

foreach ($DistributionPoint in $DistributionPoints) {
    $InvalidPackages = @()
    $DistributionPointName = $DistributionPoint.ServerName
    if ( -not(Test-Connection $DistributionPointName -Quiet -Count 1)) {
        Write-error "Could not connect to DistributionPoint $DistributionPointName - Skipping this server..."
        }
    else {
        Write-Host "$DistributionPointName is online." -ForegroundColor Green
        Write-Host "Getting packages from $DistributionPointName ... " -NoNewline
        $CurrentPackageList = @(Get-WMIObject -ComputerName $DistributionPointName -Namespace "root\sccmdp" -Query "Select * from SMS_PackagesInContLib")
        Write-Host ([string]($CurrentPackageList.Count) + " packages found.")

        if (($CurrentPackageList.Count -eq 0) -or ($CurrentPackageList -eq $null)){
            Write-Host "Skipping this distribution point"
        }
        
        else{
            Write-Host "Validating packages on $DistributionPointName ..."
            $result = @(Compare-Object -ReferenceObject $CurrentPackageList -DifferenceObject $ValidPackages -Property PackageID -PassThru)
            $InvalidPackages = @($result |Where-Object {$_.sideindicator -eq '<='})
            if ($InvalidPackages.Count -eq 0){
                Write-Host "All packages on $DistributionPointName are valid" -ForegroundColor Green
                }
            Else {
                Write-Host "Invalid packages on $DistributionPointName :" -ForegroundColor Yellow
                $InvalidPackages.PackageID
                $InvalidPackages | foreach {
                    $InvalidPackageID = $_.PackageID
                    Write-Host "Removing invalid package $InvalidPackageID from WMI on $DistributionPointName " -NoNewline
                    Get-WMIObject -ComputerName $DistributionPointName -Namespace "root\sccmdp" -Query ("Select * from SMS_PackagesInContLib where PackageID = '" + ([string]($_.PackageID)) + "'") | Remove-WmiObject
                    Write-Host "-Done"
                    }
                }
            Write-Host ""
            }
        }
    }
