# Set deleteUnattachedDisks=1 if you want to delete unattached Managed Disks
# Set deleteUnattachedDisks=0 if you want to see the Id of the unattached Managed Disks
$deleteUnattachedDisks=0
$managedDisks = Get-AzDisk
foreach ($md in $managedDisks) {
    # ManagedBy property stores the Id of the VM to which Managed Disk is attached to
    # If ManagedBy property is $null then it means that the Managed Disk is not attached to a VM
    if($md.ManagedBy -eq $null){
        if($deleteUnattachedDisks -eq 1){
            Write-Host "Deleting unattached Managed Disk with Id: $($md.Id)"
            $md | Remove-AzDisk -Force
            Write-Host "Deleted unattached Managed Disk with Id: $($md.Id) "
        }else{
            $md.Id
        }
    }
 }
 
$deleteUnattachedNics=0
$nics = Get-AzNetworkInterface | Where-Object { 
	($_.VirtualMachine -eq $null) -And (($_.PrivateEndpointText -eq $null) -Or ($_.PrivateEndpointText -eq 'null'))
	}

########### garbage below
<#
foreach ($nic in $nics)	{
	 if($deleteUnattachedNics -eq 1){
		    Write-Host "Deleting unattached NIC with Id: $nic.Name "
            Remove-AzNetworkInterface -Name $nic.Name -ResourceGroupName $nic.resourcegroupname -Force
			Write-Host "Removing Orphaned NIC $($nic.Name) $($nic.resourcegroupname)"
			}else{
				Write-Host "Name $nic.Name ResourceGroupName $nic.resourcegroupname"
			}
#>