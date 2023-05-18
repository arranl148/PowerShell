# Sample to delete a single app
# Note: Don't got forget to delete any files/installs that the detection method uses on your machine
# Deleting specific application based on its object id
# Thanks to Johan Arwidmark / https://www.deploymentresearch.com/force-application-reinstall-in-microsoft-intune-win32-apps/
# Thanks to Ondrej Sebala https://doitpsway.com/force-redeploy-of-intune-applications-using-powershell 
#
# v0.2 - Add Search through users step
#
# Need to update appID

$Path = "HKLM:SOFTWARE\Microsoft\IntuneManagementExtension\Win32Apps"
#$UserObjectID = "18ba2977-ea61-4547-8e8b-e9cbbced8719"
$UserObjectIDs = Get-ChildItem -Path $Path | Where {$_.PSChildName -match '[A-Z0-9]{8}-([A-Z0-9]{4}-){3}[A-Z0-9]{12}$'}
$AppID = "fc7a5de2-cfb2-4b8d-9122-bd056960e0fd"

# _getAppGRSHash function from Andrew (@AndrewZtrhgf): https://gist.github.com/ztrhgf/18f1c32220764f79af3da52d9f47d266
function _getAppGRSHash {
    param (
        [Parameter(Mandatory = $true)]
        [string] $appId
    )

    $intuneLogList = Get-ChildItem -Path "$env:ProgramData\Microsoft\IntuneManagementExtension\Logs" -Filter "IntuneManagementExtension*.log" -File | sort LastWriteTime -Descending | select -ExpandProperty FullName

    if (!$intuneLogList) {
        Write-Error "Unable to find any Intune log files. Redeploy will probably not work as expected."
        return
    }

    foreach ($intuneLog in $intuneLogList) {
        $appMatch = Select-String -Path $intuneLog -Pattern "\[Win32App\] ExecManager: processing targeted app .+ id='$appId'" -Context 0, 2
        if ($appMatch) {
            foreach ($match in $appMatch) {
                $hash = ([regex]"\d+:Hash = ([^]]+)\]").Matches($match).captures.groups[1].value
                if ($hash) {
                    return $hash
                }
            }
        }
    }

    Write-Error "Unable to find App '$appId' GRS hash in any of the Intune log files. Redeploy will probably not work as expected"
} #End Function

foreach ($UserObjectID in $UserObjectIDs) {
        ## Need to add filter for 000000000  
         if ($UserObjectID.PSChildName -notin '00000000-0000-0000-0000-000000000000') {
            $ResolvedRegKey = Join-Path -Path $Path -ChildPath $UserObjectID.PSChildName
            #(Get-ChildItem -Path $Path\$UserObjectID) -match $AppID | Remove-Item -Recurse -Force
            $WouldDelete = (Get-ChildItem -Path $ResolvedRegKey) -match $AppID
            Write-Host "Would delete " $WouldDelete
            $GRSHash = _getAppGRSHash -appId $AppID
            #(Get-ChildItem -Path $Path\$UserObjectID\GRS) -match $GRSHash | Remove-Item -Recurse -Force
            #$WouldDelete = (Get-ChildItem -Path $ResolvedRegKey\GRS) -match $GRSHash
            #Write-Host "Would delete " $WouldDelete
        }
}

# Restart the IME Service
#Get-Service -DisplayName "Microsoft Intune Management Extension" | Restart-Service 

