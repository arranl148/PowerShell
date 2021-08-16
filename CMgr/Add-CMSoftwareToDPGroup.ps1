Param (
    [Parameter(Mandatory=$True)]
    $Scope = 16777219
    )
$Apps = Get-CMApplication -Fast | Where-Object SecuredScopeNames -contains $Scope
ForEach ($App in $Apps) {
    Write-Output "Working on [$($App.LocalizedDisplayName)]"
    Try {
        $App | Start-CMContentDistribution -DistributionPointGroupName 'DMS Content Distribution Group'
    }
    catch {
        Write-Output "Error distributing, probably already on the DP Group"
    }
}
$Packages = Get-CMPackage -Fast | Where-Object SecuredScopeNames -contains $Scope 
ForEach ($Package in $Packages) {
    Write-Output "Working on [$($Package.Name)]"
    Try {
        $Package | Start-CMContentDistribution -DistributionPointGroupName 'DMS Content Distribution Group'
    }
    catch {
        Write-Output "Error distributing, probably already on the DP Group"
    }
}