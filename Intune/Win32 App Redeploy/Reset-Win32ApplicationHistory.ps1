# Sample to delete a single app
# Thanks to Johan Arwidmark / https://www.deploymentresearch.com/force-application-reinstall-in-microsoft-intune-win32-apps/
# Thanks to Ondrej Sebala https://doitpsway.com/force-redeploy-of-intune-applications-using-powershell 
# Note: Don't got forget to delete any files/installs that the detection method uses on your machine
# Deleting specific application based on its object id
$Path = "HKLM:SOFTWARE\Microsoft\IntuneManagementExtension\Win32Apps"
$UserObjectID = "18ba2977-ea61-4547-8e8b-e9cbbced8719"
$AppID = "8ea44431-bb08-460c-b881-52bdff6a7128"

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
}

(Get-ChildItem -Path $Path\$UserObjectID) -match $AppID | Remove-Item -Recurse -Force
$GRSHash = _getAppGRSHash -appId $AppID
(Get-ChildItem -Path $Path\$UserObjectID\GRS) -match $GRSHash | Remove-Item -Recurse -Force

# Restart the IME Service
Get-Service -DisplayName "Microsoft Intune Management Extension" | Restart-Service 