## Import devices in to AAD from CSV
## Thanks DB

#Import-Module AzureAD

#Connect-AzureAD -TenantId a123abc0-1234-abc1-12ab-1234567890ab
$csv = Import-Csv -Path "<Path to CSV File>" #Use DeviceName as column header
$group = Get-AzureADGroup -SearchString SmarT_Windows_DevicePatchingHitList
$group.ObjectId 


foreach ($device in $csv) {
    $adddevice = (Get-AzureADDevice -SearchString $device.devicename)
        if ($adddevice.Count -gt 1) {
            $device0 = (Get-AzureADDevice -SearchString $device.devicename | Select-Object displayName, ObjectID, ApproximateLastLogonTimeStamp | Sort-Object -Descending -Property ApproximateLastLogonTimeStamp)[0]
            Write-Host "Selecting the latest record for " $device0.DisplayName " is " $device0.ObjectId
            Add-AzureADGroupMember -ObjectId $group.ObjectId -RefObjectId $device0.ObjectId 
        } else {    
            $DeviceDisplayName = $adddevice.DisplayName
            $DeviceObjectID = $adddevice.ObjectId 
            write-host $DeviceDisplayName " is "  $DeviceObjectID
            Add-AzureADGroupMember -ObjectId $group.ObjectId -RefObjectId $adddevice.ObjectId 
            }
    }

<# #debugging
$devices = (Get-AzureADDevice -SearchString "PW01WHPN" | Select-Object displayName, ObjectID, ApproximateLastLogonTimeStamp | Sort-Object -Descending -Property ApproximateLastLogonTimeStamp)[0]
$devices #>