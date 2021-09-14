#Get Unlinked GPOs
$gpos = Get-Gpo -All
foreach ($gpo in $gpos) {
    [xml]$gpoReport = Get-GPOReport -Guid $gpo.ID -ReportType xml
}
foreach ($gpo in $gpos) {
    [xml]$gpoReport = Get-GPOReport -Guid $gpo.ID -ReportType xml
    if (-not $gpoReport.GPO.LinksTo) {
        $gpo.DisplayName
    }
}