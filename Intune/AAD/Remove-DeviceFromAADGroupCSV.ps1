# Define the security group's display name or object ID
$groupName = "YourSecurityGroupName"

# Define the Tenant ID
$YourTenantID = "xxxxxxxxxxxxxxxxxxxxx"

#Get the Device List
$RemoveDeviceList = "C:\Path\to\devices.csv"

# Set the context to your Azure AD tenant
Connect-AzAccount
Set-AzContext -TenantId $YourTenantID

# Retrieve the security group
$group = Get-AzADGroup -DisplayName $groupName
$groupId = $group.Id

# Read the CSV file containing the list of devices
$devices = Import-Csv -Path $RemoveDeviceList

# Iterate through each device in the CSV
foreach ($device in $devices) {
    $computerName = $device.ComputerName

    # Check if the computer is a member of the security group
    $computer = Get-AzADDevice -Filter "displayName eq '$computerName'" -ErrorAction SilentlyContinue

    if ($computer) {
        $memberships = Get-AzADDeviceMemberOf -ObjectId $computer.Id

        if ($memberships.Id -contains $groupId) {
            # Remove the device from the security group
            Remove-AzADGroupMember -MemberObjectId $computer.Id -TargetGroupId $groupId
            Write-Output "The computer '$computerName' has been removed from the security group."
        } else {
            Write-Output "The computer '$computerName' is not a member of the security group."
        }
    } else {
        Write-Output "Computer '$computerName' not found."
    }
}
