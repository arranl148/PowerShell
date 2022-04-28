#Create Default limiting collections
$LimitingCollection = "All Desktop and Server Clients"
$LimitingCollectionAS = "All Systems"
$LimitingCollectionServer = "All Server Clients"
$LimitingCollectionDesktop = "All Desktop Clients"
$LimitingCollectionW10 = "All Windows 10 Devices"

#Refresh Schedule
$Schedule = New-CMSchedule –RecurInterval Days –RecurCount 7
$ScheduleDaily = New-CMSchedule –RecurInterval Days –RecurCount 1
<#
#Folders - need Check for SiteCode !!
$CollectionFolders = @(
    @{Name = "Clients"; ObjectType = 5000; ParentContainerNodeId = 0}
)
$Folder_Clients = @{Name = "Clients"; ObjectType = 5000; ParentContainerNodeId = 0}
#ForEach
Set-WmiInstance -Namespace "root\sms\site_$($SiteCode.Name)" -Class "SMS_ObjectContainerNode" -Arguments $Folder_Clients
$Folder_OS = "Operating Systems"
$Folder_Updates = "Patch Management"
$Folder_Servicing = "Windows Servicing"
 #>

## Building the Hash Table of List of Collections ##
$Collections = @(
# Limiting
	@{Name = "All Desktop Clients"; LimitingCollection = $LimitingCollection ; RefreshSchedule = $Schedule ; Query = "select * from SMS_R_System where SMS_R_System.OperatingSystemNameandVersion like '%Workstation%'"}
	@{Name = "All Server Clients"; LimitingCollection = $LimitingCollection ; RefreshSchedule = $Schedule ; Query = "select * from SMS_R_System where SMS_R_System.OperatingSystemNameandVersion like '%Server%'"}
#CoManaged
    @{Name = "CoManagement - Pilot Devices"; LimitingCollection = $LimitingCollectionDesktop ; RefreshSchedule = $Schedule }
    @{Name = "CoManagement - Compliance Policy Workload"; LimitingCollection = $LimitingCollectionDesktop ; RefreshSchedule = $Schedule }
    @{Name = "CoManagement - Device Configuration Workload"; LimitingCollection = $LimitingCollectionDesktop ; RefreshSchedule = $Schedule }
    @{Name = "CoManagement - Endpoint Protection Workload"; LimitingCollection = $LimitingCollectionDesktop ; RefreshSchedule = $Schedule }
    @{Name = "CoManagement - Resource Acces Policy Workload"; LimitingCollection = $LimitingCollectionDesktop ; RefreshSchedule = $Schedule }
    @{Name = "CoManagement - Client Apps Workload"; LimitingCollection = $LimitingCollectionDesktop ; RefreshSchedule = $Schedule }
    @{Name = "CoManagement - Office Click-to-Run apps Workload"; LimitingCollection = $LimitingCollectionDesktop ; RefreshSchedule = $Schedule }
    @{Name = "CoManagement - Windows Update Policies Workload"; LimitingCollection = $LimitingCollectionDesktop ; RefreshSchedule = $Schedule }
	# Win10
    @{Name = "All Windows 10 Enterprise"; LimitingCollection = $LimitingCollection ; RefreshSchedule = $Schedule ; Query = "select * from SMS_R_System inner join SMS_G_System_OPERATING_SYSTEM on SMS_G_System_OPERATING_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_G_System_OPERATING_SYSTEM.Caption = 'Microsoft Windows 10 Enterprise'"}
    @{Name = "All Windows 10 Enterprise N"; LimitingCollection = $LimitingCollection ; RefreshSchedule = $Schedule ; Query = "select * from SMS_R_System inner join SMS_G_System_OPERATING_SYSTEM on SMS_G_System_OPERATING_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_G_System_OPERATING_SYSTEM.Caption = 'Microsoft Windows 10 Enterprise N'"}
    @{Name = "All Windows 10 Pro N"; LimitingCollection = $LimitingCollection ; RefreshSchedule = $Schedule ; Query = "select * from SMS_R_System inner join SMS_G_System_OPERATING_SYSTEM on SMS_G_System_OPERATING_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_G_System_OPERATING_SYSTEM.Caption = 'Microsoft Windows 10 Pro N'"}
    @{Name = "All Windows 10 Pro N for Workstations"; LimitingCollection = $LimitingCollection ; RefreshSchedule = $Schedule ; Query = "select * 	from  SMS_R_System inner join SMS_G_System_OPERATING_SYSTEM on SMS_G_System_OPERATING_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_G_System_OPERATING_SYSTEM.Caption = 'Microsoft Windows 10 Pro N for Workstations'"}
    @{Name = "All Windows 10 Pro"; LimitingCollection = $LimitingCollection ; RefreshSchedule = $Schedule ; Query = "select * from SMS_R_System where OperatingSystemNameandVersion like '%Windows 10 Pro%'"}
    @{Name = "All Windows 10 Home - to check"; LimitingCollection = $LimitingCollection ; RefreshSchedule = $Schedule ; Query = "select * from SMS_R_System where OperatingSystemNameandVersion like '%Windows 10 Home%'"}

# @{Name = "All Autopilot Devices"; ; LimitingCollection = $LimitingCollection ; RefreshSchedule = $Schedule ; Query = "select * from SMS_R_System inner join SMS_Client_ComanagementState on SMS_Client_ComanagementState.ResourceID = SMS_R_System.ResourceId where SMS_Client_ComanagementState.MDMEnrolled = 1"}

#    @{Name = "Windows 10 Edu Ent Extended Support"; LimitingCollection = $LimitingCollection ; RefreshSchedule = $Schedule ; Query = "select * from SMS_R_System where OperatingSystemNameandVersion like '%Workstation 10.0%'"}
	@{Name = "Windows 10 Release 1507 Expired May 9 2017"; LimitingCollection = $LimitingCollectionW10 ; RefreshSchedule = $Schedule ; Query = "select * from SMS_R_System inner join SMS_G_System_OPERATING_SYSTEM on SMS_G_System_OPERATING_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_R_System.OSBranch != 2 and SMS_G_System_OPERATING_SYSTEM.BuildNumber = '10240'"}
	@{Name = "Windows 10 Release 1507 LTSB"; LimitingCollection = $LimitingCollectionW10 ; RefreshSchedule = $Schedule ; Query = "select * from SMS_R_System inner join SMS_G_System_OPERATING_SYSTEM on SMS_G_System_OPERATING_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_R_System.OSBranch = 2 and SMS_G_System_OPERATING_SYSTEM.BuildNumber = '10240'"}
	@{Name = "Windows 10 Release 1511 Expired Oct 10 2017"; LimitingCollection = $LimitingCollectionW10 ; RefreshSchedule = $Schedule ; Query = "select * from SMS_R_System inner join SMS_G_System_OPERATING_SYSTEM on SMS_G_System_OPERATING_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_G_System_OPERATING_SYSTEM.BuildNumber = '10586'"}
	@{Name = "Windows 10 Release 1607 RS1 Expired Apr 10 2018"; LimitingCollection = $LimitingCollectionW10 ; RefreshSchedule = $Schedule ; Query = "select * from  SMS_R_System inner join SMS_G_System_OPERATING_SYSTEM on SMS_G_System_OPERATING_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_R_System.OSBranch != 2 and SMS_G_System_OPERATING_SYSTEM.BuildNumber = '14393'"}
	@{Name = "Windows 10 Release 1607 RS1 LTSB"; LimitingCollection = $LimitingCollectionW10 ; RefreshSchedule = $Schedule ; Query = "select * from  SMS_R_System inner join SMS_G_System_OPERATING_SYSTEM on SMS_G_System_OPERATING_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_R_System.OSBranch = 2 and SMS_G_System_OPERATING_SYSTEM.BuildNumber = '14393'"}
	@{Name = "Windows 10 Release 1703 RS2 Expired Oct 9 2018"; LimitingCollection = $LimitingCollectionW10 ; RefreshSchedule = $Schedule ; Query = "select * from SMS_R_System inner join SMS_G_System_OPERATING_SYSTEM on SMS_G_System_OPERATING_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_G_System_OPERATING_SYSTEM.BuildNumber = '15063'"}
	@{Name = "Windows 10 Release 1709 RS3 Expires Apr 9 2019"; LimitingCollection = $LimitingCollectionW10 ; RefreshSchedule = $Schedule ; Query = "select * from SMS_R_System inner join SMS_G_System_OPERATING_SYSTEM on SMS_G_System_OPERATING_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_G_System_OPERATING_SYSTEM.BuildNumber = '16299'"}
	@{Name = "Windows 10 Release 1803 RS4 Expires Pro Nov 12 2019 - Ent Nov 10 2020"; LimitingCollection = $LimitingCollectionW10 ; RefreshSchedule = $Schedule ; Query = "select * from SMS_R_System inner join SMS_G_System_OPERATING_SYSTEM on SMS_G_System_OPERATING_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_G_System_OPERATING_SYSTEM.BuildNumber = '17134'"}
	@{Name = "Windows 10 Release 1809 RS5 Expires Pro May 12 2020 - Ent May 11 2021"; LimitingCollection = $LimitingCollectionW10 ; RefreshSchedule = $Schedule ; Query = "select * from SMS_R_System inner join SMS_G_System_OPERATING_SYSTEM on SMS_G_System_OPERATING_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_R_System.OSBranch != 2 and SMS_G_System_OPERATING_SYSTEM.BuildNumber = '17763'"}
	@{Name = "Windows 10 Release 1809 RS5 LTSC"; LimitingCollection = $LimitingCollectionW10 ; RefreshSchedule = $Schedule ; Query = "select * from SMS_R_System inner join SMS_G_System_OPERATING_SYSTEM on SMS_G_System_OPERATING_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_R_System.OSBranch = 2 and SMS_G_System_OPERATING_SYSTEM.BuildNumber = '17763'"}
	@{Name = "Windows 10 Release 1903 19H1 Expires Dec 8 2020"; LimitingCollection = $LimitingCollectionw10 ; RefreshSchedule = $Schedule ; Query = "select * from SMS_R_System inner join SMS_G_System_OPERATING_SYSTEM on SMS_G_System_OPERATING_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_G_System_OPERATING_SYSTEM.BuildNumber = '18362'"}
	@{Name = "Windows 10 Release 1909 19H2 Expires Pro May 2021 - Ent May 2022"; LimitingCollection = $LimitingCollectionw10 ; RefreshSchedule = $Schedule ; Query = "select * from SMS_R_System inner join SMS_G_System_OPERATING_SYSTEM on SMS_G_System_OPERATING_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_G_System_OPERATING_SYSTEM.BuildNumber = '18363'"}
	@{Name = "Windows 10 Release 20H1 2004 19041"; LimitingCollection = $LimitingCollectionw10 ; RefreshSchedule = $Schedule ; Query = "select * from SMS_R_System inner join SMS_G_System_OPERATING_SYSTEM on SMS_G_System_OPERATING_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_G_System_OPERATING_SYSTEM.BuildNumber = '19041'"}
	@{Name = "Windows 10 Release 20H2 19042"; LimitingCollection = $LimitingCollectionw10 ; RefreshSchedule = $Schedule ; Query = "select * from SMS_R_System inner join SMS_G_System_OPERATING_SYSTEM on SMS_G_System_OPERATING_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_G_System_OPERATING_SYSTEM.BuildNumber = '19042'"}
	@{Name = "Windows 10 Release 21H1 19043"; LimitingCollection = $LimitingCollectionw10 ; RefreshSchedule = $Schedule ; Query = "select * from SMS_R_System inner join SMS_G_System_OPERATING_SYSTEM on SMS_G_System_OPERATING_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_G_System_OPERATING_SYSTEM.BuildNumber = '19043'"}
# 	@{Name = "Windows 10 SAC-T CB Consumer release OSBranch 0 = CB (do not defer upgrades)"; LimitingCollection = $LimitingCollectionW10 ; RefreshSchedule = $Schedule ; Query = "select * from SMS_R_System where SMS_R_System.OSBranch = '0'"}
#	@{Name = "Windows 10 SAC CB Business release OSBranch  1 = CBB (defer upgrades)"; LimitingCollection = $LimitingCollectionW10 ; RefreshSchedule = $Schedule ; Query = "select * from SMS_R_System where SMS_R_System.OSBranch = '1'"}
	@{Name = "Windows 10 Long Term Servicing 2 = Long Term Servicing Branch"; LimitingCollection = $LimitingCollectionW10 ; RefreshSchedule = $Schedule ; Query = "select * from SMS_R_System where SMS_R_System.OSBranch = '2'"} 
# Clients
	@{Name = "All Clients Pending Reboot"; LimitingCollection = $LimitingCollection ; RefreshSchedule = $Schedule ; Query = "select * from sms_r_system inner join SMS_UpdateComplianceStatus ON SMS_UpdateComplianceStatus.machineid=sms_r_system.resourceid WHERE SMS_UpdateComplianceStatus.LastEnforcementMessageID = 9"}
	@{Name = "All x64 Clients"; LimitingCollection = $LimitingCollection ; RefreshSchedule = $Schedule ; Query = "select * from SMS_R_System inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM.SystemType like '%x64%'"}
	@{Name = "All x86 Clients"; LimitingCollection = $LimitingCollection ; RefreshSchedule = $Schedule ; Query = "select * from SMS_R_System inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM.SystemType like '%x86%'"}
    @{Name = "Default-First-Site-Name Clients"; LimitingCollection = $LimitingCollection; RefreshSchedule = $Schedule; Query = "select * from SMS_R_System where SMS_R_System.ADSiteName = 'Default-First-Site-Name'"}
    @{Name = "Default-First-Site-Name Count"; LimitingCollection = $LimitingCollectionAS; RefreshSchedule = $Schedule; Query = "select * from SMS_R_System where SMS_R_System.ADSiteName = 'Default-First-Site-Name'"}
	@{Name = "Inactive Clients 45 days LastLogonTimestamp"; LimitingCollection = $LimitingCollection ; RefreshSchedule = $Schedule ; Query = "select * from SMS_R_System where DATEDIFF(dd,SMS_R_System.LastLogonTimestamp,GetDate()) > 45"}
	@{Name = "All Active Clients daily update"; LimitingCollection = $LimitingCollection ; RefreshSchedule = $Schedule ; Query = "select * from SMS_R_System inner join SMS_G_System_CH_ClientSummary on SMS_G_System_CH_ClientSummary.ResourceId = SMS_R_System.ResourceId where SMS_G_System_CH_ClientSummary.ClientActiveStatus = 1"}
# 	@{Name = "All computers without a ConfigMgr client"; LimitingCollection = $LimitingCollectionAS; RefreshSchedule = $Schedule; Query = "select * from SMS_R_System where SMS_R_System.Client is null"}
# 	@{Name = "Clients with disks about to fail"; LimitingCollection = $LimitingCollection ; RefreshSchedule = $Schedule ; Query = "select *from SMS_R_System inner join SMS_G_System_DISK on SMS_G_System_DISK.ResourceId = SMS_R_System.ResourceId where SMS_G_System_DISK.Status = 'Pred Fail'"}
# Server
	@{Name = "All Domain Controllers"; LimitingCollection = $LimitingCollectionServer ; RefreshSchedule = $Schedule ; Query = "select * from SMS_R_System inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM.Roles like '%Domain_Controller%'"}
	@{Name = "All Exchange Servers"; LimitingCollection = $LimitingCollectionServer ; RefreshSchedule = $Schedule ; Query = "select * from SMS_R_System inner join SMS_G_System_ADD_REMOVE_PROGRAMS_64 on SMS_G_System_ADD_REMOVE_PROGRAMS_64.ResourceId = SMS_R_System.ResourceId inner join SMS_G_System_SERVICE on SMS_G_System_SERVICE.ResourceId = SMS_R_System.ResourceId where SMS_G_System_ADD_REMOVE_PROGRAMS_64.DisplayName like 'Microsoft Exchange Server%' and SMS_G_System_SERVICE.DisplayName like 'Microsoft Exchange%'"}
	@{Name = "All Hyper-V Servers"; LimitingCollection = $LimitingCollectionServer ; RefreshSchedule = $Schedule ; Query = "select * from SMS_R_System inner join SMS_G_System_SERVICE on SMS_G_System_SERVICE.ResourceId = SMS_R_System.ResourceId where SMS_G_System_SERVICE.DisplayName = 'Hyper-V Virtual Machine Management'"}
	@{Name = "All Lync Servers"; LimitingCollection = $LimitingCollectionServer ; RefreshSchedule = $Schedule ; Query = "select * from SMS_R_System inner join SMS_G_System_ADD_REMOVE_PROGRAMS on SMS_G_System_ADD_REMOVE_PROGRAMS.ResourceId = SMS_R_System.ResourceId inner join SMS_G_System_ADD_REMOVE_PROGRAMS_64 on SMS_G_System_ADD_REMOVE_PROGRAMS_64.ResourceId = SMS_R_System.ResourceId where SMS_G_System_ADD_REMOVE_PROGRAMS.DisplayName like '%Lync Server%' or SMS_G_System_ADD_REMOVE_PROGRAMS_64.DisplayName like '%Lync Server%'"}
	@{Name = "All SQL Servers"; LimitingCollection = $LimitingCollectionServer ; RefreshSchedule = $Schedule ; Query = "select * from SMS_R_System inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM.Roles like '%SQLServer%'"}
#   @{Name = "All FailOverCluster Servers"; LimitingCollection = $LimitingCollectionServer ; RefreshSchedule = $Schedule ; Query = "select * from SMS_R_System inner join SMS_G_System_SERVICE on SMS_G_System_SERVICE.ResourceID = SMS_R_System.ResourceId where SMS_G_System_SERVICE.DisplayName = "Cluster Service" and SMS_G_System_SERVICE.StartMode = "Auto""}
# OS
	@{Name = "All Windows 10 Devices"; LimitingCollection = $LimitingCollectionDesktop ; RefreshSchedule = $Schedule ; Query = "select * from SMS_R_System where SMS_R_System.OperatingSystemNameandVersion like 'Microsoft Windows NT Workstation 10.0%'"}
	@{Name = "All Windows 7 Devices"; LimitingCollection = $LimitingCollectionDesktop ; RefreshSchedule = $Schedule ; Query = "select * from SMS_R_System where SMS_R_System.OperatingSystemNameandVersion like '%Workstation 6.1%'"}
	@{Name = "All Windows 8 Devices"; LimitingCollection = $LimitingCollectionDesktop ; RefreshSchedule = $Schedule ; Query = "select * from SMS_R_System where SMS_R_System.OperatingSystemNameandVersion like '%Workstation 6.2%'"}
	@{Name = "All Windows 8.1 Devices"; LimitingCollection = $LimitingCollectionDesktop ; RefreshSchedule = $Schedule ; Query = "select * from SMS_R_System where SMS_R_System.OperatingSystemNameandVersion like '%Workstation 6.3%'"}
	@{Name = "All Windows Server 2003 Devices"; LimitingCollection = $LimitingCollectionServer ; RefreshSchedule = $Schedule ; Query = "select * from SMS_R_System where SMS_R_System.OperatingSystemNameandVersion like '%Windows NT Server 5.2%'"}
	@{Name = "All Windows Server 2008 Devices"; LimitingCollection = $LimitingCollectionServer ; RefreshSchedule = $Schedule ; Query = "select * from SMS_R_System where SMS_R_System.OperatingSystemNameandVersion like '%Windows NT Server 6.0%'"}
	@{Name = "All Windows Server 2008 R2 Datacenter Devices"; LimitingCollection = $LimitingCollectionServer ; RefreshSchedule = $Schedule ; Query = "select * from SMS_R_System where SMS_R_System.OperatingSystemNameandVersion like '%Windows NT Advanced Server 6.1%'"}
	@{Name = "All Windows Server 2008 R2 Devices"; LimitingCollection = $LimitingCollectionServer ; RefreshSchedule = $Schedule ; Query = "select * from SMS_R_System where SMS_R_System.OperatingSystemNameandVersion like '%Windows NT Server 6.1%'"}
	@{Name = "All Windows Server 2012 Devices"; LimitingCollection = $LimitingCollectionServer ; RefreshSchedule = $Schedule ; Query = "select * from SMS_R_System where SMS_R_System.OperatingSystemNameandVersion like '%Windows NT Server 6.2%'"}
	@{Name = "All Windows Server 2012 R2 Devices"; LimitingCollection = $LimitingCollectionServer ; RefreshSchedule = $Schedule ; Query = "select * from SMS_R_System where SMS_R_System.OperatingSystemNameandVersion like '%Windows NT Server 6.3%'"}
	@{Name = "All Windows Server 2016 Devices"; LimitingCollection = $LimitingCollectionServer ; RefreshSchedule = $Schedule ; Query = "select * from SMS_R_System where SMS_R_System.OperatingSystemNameandVersion like '%Windows NT Server 10.0%'"}
#	@{Name = "All Windows Server 2019 Devices"; LimitingCollection = $LimitingCollectionServer ; RefreshSchedule = $Schedule ; Query = "select * from SMS_R_System where SMS_R_System.OperatingSystemNameandVersion like '%Windows NT Server 10.0%'"}
	@{Name = "All Windows XP Devices"; LimitingCollection = $LimitingCollectionDesktop ; RefreshSchedule = $Schedule ; Query = "select * from SMS_R_System where SMS_R_System.OperatingSystemNameandVersion like '%Workstation 5.1%'"}
#Mobile OS
    @{Name = "Mobile Devices - All Android Devices"; LimitingCollection = $LimitingCollectionAS; RefreshSchedule = $Schedule; Query = "SELECT * FROM SMS_R_System INNER JOIN SMS_G_System_DEVICE_OSINFORMATION ON SMS_G_System_DEVICE_OSINFORMATION.ResourceID = SMS_R_System.ResourceId WHERE SMS_G_System_DEVICE_OSINFORMATION.Platform like 'Android%'"}
    @{Name = "Mobile Devices - All iPads"; LimitingCollection = $LimitingCollectionAS; RefreshSchedule = $Schedule; Query = "select * from SMS_R_System inner join SMS_G_System_DEVICE_COMPUTERSYSTEM on SMS_G_System_DEVICE_COMPUTERSYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_G_System_DEVICE_COMPUTERSYSTEM.DeviceModel like '%ipad%'"}
    @{Name = "Mobile Devices - All iPhones"; LimitingCollection = $LimitingCollectionAS; RefreshSchedule = $Schedule; Query = "select * from SMS_R_System inner join SMS_G_System_DEVICE_COMPUTERSYSTEM on SMS_G_System_DEVICE_COMPUTERSYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_G_System_DEVICE_COMPUTERSYSTEM.DeviceModel like '%iPhone%'"}
    @{Name = "Mobile Devices - All Microsoft Surface RT Devices"; LimitingCollection = $LimitingCollectionAS; RefreshSchedule = $Schedule; Query = "select * from SMS_R_System inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM.Model like 'Surface%'"}
    @{Name = "Mobile Devices - All Windows 8 Phones"; LimitingCollection = $LimitingCollectionAS; RefreshSchedule = $Schedule; Query = "select * from SMS_R_System inner join SMS_G_System_DEVICE_OSINFORMATION on SMS_G_System_DEVICE_OSINFORMATION.ResourceID = SMS_R_System.ResourceId where SMS_G_System_DEVICE_OSINFORMATION.Platform like 'Windows Phone' and SMS_G_System_DEVICE_OSINFORMATION.Version like '8.0%'"}
    @{Name = "Mobile Devices - All Windows 8.1 Phones"; LimitingCollection = $LimitingCollectionAS; RefreshSchedule = $Schedule; Query = "select * from SMS_R_System inner join SMS_G_System_DEVICE_OSINFORMATION on SMS_G_System_DEVICE_OSINFORMATION.ResourceID = SMS_R_System.ResourceId where SMS_G_System_DEVICE_OSINFORMATION.Platform like 'Windows Phone' and SMS_G_System_DEVICE_OSINFORMATION.Version like '8.1%'"}
#PatchManagement
	@{Name = "Patch Management - Blank for Staging"; LimitingCollection = $LimitingCollection ; RefreshSchedule = $Schedule }
	@{Name = "Patch Management - EndPoint Protection"; LimitingCollection = $LimitingCollection ; RefreshSchedule = $Schedule }
	@{Name = "Patch Management - Desktops Phase 1"; LimitingCollection = $LimitingCollectionDesktop ; RefreshSchedule = $Schedule }
	@{Name = "Patch Management - Desktops Phase 2"; LimitingCollection = $LimitingCollectionDesktop ; RefreshSchedule = $Schedule }
	@{Name = "Patch Management - Desktops Phase 3"; LimitingCollection = $LimitingCollectionDesktop ; RefreshSchedule = $Schedule }
	@{Name = "Patch Management - Servers Phase 1"; LimitingCollection = $LimitingCollectionServer ; RefreshSchedule = $Schedule }
	@{Name = "Patch Management - Servers Phase 2"; LimitingCollection = $LimitingCollectionServer ; RefreshSchedule = $Schedule }
	@{Name = "Patch Management - Servers Phase 3"; LimitingCollection = $LimitingCollectionServer ; RefreshSchedule = $Schedule }
)
<#
# Office Versions
#    @{Name = "XXX";LimitingCollection=$LimitingCollection;RefreshSchedule=$Schedule;Query="XXXX"}
    @{Name = "Office 365 Channel - Monthly";LimitingCollection=$LimitingCollection;RefreshSchedule=$Schedule;Query="select * from  SMS_R_System inner join SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS on SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.ResourceID = SMS_R_System.ResourceId where SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.cfgUpdateChannel = 'http://officecdn.microsoft.com/pr/492350f6-3a01-4f97-b9c0-c7c6ddf67d60'"}
    @{Name = "Office 365 Channel/ - Monthly (Targeted)";LimitingCollection=$LimitingCollection;RefreshSchedule=$Schedule;Query="select * from SMS_R_System inner join SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS on SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.ResourceID = SMS_R_System.ResourceId where SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.cfgUpdateChannel = 'http://officecdn.microsoft.com/pr/64256afe-f5d9-4f86-8936-8840a6a4f5be'"}
    @{Name = "Office 365 Channel - Semi-Annual (Targeted)";LimitingCollection=$LimitingCollection;RefreshSchedule=$Schedule;Query="select * from  SMS_R_System inner join SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS on SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.ResourceID = SMS_R_System.ResourceId where SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.cfgUpdateChannel = 'http://officecdn.microsoft.com/pr/b8f9b850-328d-4355-9145-c59439a0c4cf'"}
    @{Name = "Office 365 Channel - Semi-Annual";LimitingCollection=$LimitingCollection;RefreshSchedule=$Schedule;Query="select * from  SMS_R_System inner join SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS on SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.ResourceID = SMS_R_System.ResourceId where SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.cfgUpdateChannel = 'http://officecdn.microsoft.com/pr/7ffbc6bf-bc32-4f92-8982-f9dd17fd3114'"}
 #>

#Create Collection
Foreach ($Collection in $Collections) {
New-CMDeviceCollection -Name $Collection.Name -LimitingCollectionName $Collection.LimitingCollection -RefreshSchedule $Collection.RefreshSchedule -RefreshType 2
if ($Collection.Query -ne $null) {Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection.Name -QueryExpression $Collection.Query -RuleName $Collection.Name}
#Move the collection to the right folder
#$FolderPath = $SiteCode.Name + ":\DeviceCollection\" + $CollectionFolder.FolderName
#Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $Collection.Name)
}
