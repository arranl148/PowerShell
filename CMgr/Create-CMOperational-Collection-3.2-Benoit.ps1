#############################################################################
# Author  : Benoit Lecours 
# Website : www.SystemCenterDudes.com
# Twitter : @scdudes
#
# Version : 3.2
# Created : 2014/07/17
# Modified : 
# 2019/04/04 - Add Collection 89-91
#            
# Purpose : This script create a set of ConfigMgr collections and move it in an "Operational" folder
# Special Thanks to Joshua Barnette for V3.0
#
#############################################################################

#Load Configuration Manager PowerShell Module
Import-module ($Env:SMS_ADMIN_UI_PATH.Substring(0,$Env:SMS_ADMIN_UI_PATH.Length-5)+ '\ConfigurationManager.psd1')

#Get SiteCode
$SiteCode = Get-PSDrive -PSProvider CMSITE
Set-location $SiteCode":"

#Error Handling and output
Clear-Host
$ErrorActionPreference= 'SilentlyContinue'

#Create Default Folder 
$CollectionFolder = @{Name ="Example"; ObjectType =5000; ParentContainerNodeId =0}
Set-WmiInstance -Namespace "root\sms\site_$($SiteCode.Name)" -Class "SMS_ObjectContainerNode" -Arguments $CollectionFolder -ComputerName $SiteCode.Root
$FolderPath =($SiteCode.Name +":\DeviceCollection\" + $CollectionFolder.Name)

#Set Default limiting collections
#$LimitingCollection ="All Systems"
$LimitingCollection = "All Desktop and Server Clients"
$LimitingCollectionAS = "All Systems"
$LimitingCollectionSvr = "All Server Clients"
$LimitingCollectionCli = "All Desktop Clients"
$LimitingCollectionW10 = "All Windows 10 Devices"

#Refresh Schedule
$Schedule =New-CMSchedule –RecurInterval Days –RecurCount 7


#Find Existing Collections
$ExistingCollections = Get-CMDeviceCollection -Name "* | *" | Select-Object CollectionID, Name

#List of Collections Query
$DummyObject = New-Object -TypeName PSObject 
$Collections = @()

<#$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Clients - All"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 where SMS_R_System.Client = 1"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"All devices detected by ConfigMgr"}} #>

#------------
# Clients
#------------
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Clients - Computers without a ConfigMgr client"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 where SMS_R_System.Client = 0 OR SMS_R_System.Client is NULL"}},@{L="LimitingCollection"
; E={$LimitingCollectionAS}},@{L="Comment"
; E={"All devices without ConfigMgr client installed"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Clients - Version Not Latest (1806)"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 where SMS_R_System.ClientVersion not like '5.00.8692.10%'"}},@{L="LimitingCollection"
; E={"Clients - All"}},@{L="Comment"
; E={"All devices without ConfigMgr client version 1806"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Clients - Version SCCM 2012R2"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 where SMS_R_System.ClientVersion like '5.00.7958.%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"All systems with ConfigMgr client version R2 CU1 installed"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Clients - Version SCCM 2012R2 SP1"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 where SMS_R_System.ClientVersion like '5.00.8239%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"All systems with ConfigMgr client version R2 SP1 installed"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Clients - Version 1511"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 where SMS_R_System.ClientVersion = '5.00.8325.1000'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"All systems with ConfigMgr client version 1511 installed"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Clients - Version 1602"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 where SMS_R_System.ClientVersion = '5.00.8355.1000'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"All systems with ConfigMgr client version 1602 installed"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Clients - Version 1606"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 where SMS_R_System.ClientVersion like '5.00.8412.100%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"All systems with ConfigMgr client version 1606 installed"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Clients - Version 1610"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 where SMS_R_System.ClientVersion like '5.00.8458.100%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"All systems with ConfigMgr client version 1610 installed"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Clients - Version 1702"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 where SMS_R_System.ClientVersion like '5.00.8498.100%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"All systems with ConfigMgr client version 1702 installed"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Clients - Version 1706"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 where SMS_R_System.ClientVersion like '5.00.8540.100%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"All systems with ConfigMgr client version 1706 installed"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Clients - Version 1710"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 where SMS_R_System.ClientVersion like '5.00.8577.100%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"All systems with ConfigMgr client version 1710 installed"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"All x86 Clients"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceID = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM.SystemType = 'X86-based PC'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"All systems with 32-bit system type"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"All x64 Clients"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceID = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM.SystemType = 'X64-based PC'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"All systems with 64-bit system type"}}

##Collection 77
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Clients - Version 1802"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion like '5.00.8634.10%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"All systems with ConfigMgr client version 1802 installed"}}

##Collection 88
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Clients - Version 1806"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion like '5.00.8692.10%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"All systems with ConfigMgr client version 1806 installed"}}

##Collection 89
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Clients - Version 1810"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion like '5.00.8740.10%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"; E={"All systems with ConfigMgr client version 1810 installed"}}

##Collection 90
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Clients - Version 1902"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion like '5.00.8790.10%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"; E={"All systems with ConfigMgr client version 1902 installed"}}

#------------
# ConfigMgr
#------------
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"ConfigMgr - Console"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 inner join SMS_G_System_ADD_REMOVE_PROGRAMS on SMS_G_System_ADD_REMOVE_PROGRAMS.ResourceID = SMS_R_System.ResourceId where SMS_G_System_ADD_REMOVE_PROGRAMS.DisplayName like '%Configuration Manager Console%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"All systems with ConfigMgr console installed"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"ConfigMgr - Site Servers"}},@{L="Query"
; E={"select SMS_R_System.ResourceId, SMS_R_System.ResourceType, SMS_R_System.Name, SMS_R_System.SMSUniqueIdentifier, SMS_R_System.ResourceDomainORWorkgroup, SMS_R_System.Client from SMS_R_System
 where SMS_R_System.SystemRoles = 'SMS Site Server'"}},@{L="LimitingCollection"
; E={"All Server Clients"}},@{L="Comment"
; E={"All systems that is ConfigMgr site server"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"ConfigMgr - Site Systems"}},@{L="Query"
; E={"select SMS_R_System.ResourceId, SMS_R_System.ResourceType, SMS_R_System.Name, SMS_R_System.SMSUniqueIdentifier, SMS_R_System.ResourceDomainORWorkgroup, SMS_R_System.Client from SMS_R_System
 where SMS_R_System.SystemRoles = 'SMS Site System' or SMS_R_System.ResourceNames in (Select ServerName FROM SMS_DistributionPointInfo)"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"All systems that is ConfigMgr site system"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"ConfigMgr - Distribution Points"}},@{L="Query"
; E={"select SMS_R_System.ResourceId, SMS_R_System.ResourceType, SMS_R_System.Name, SMS_R_System.SMSUniqueIdentifier, SMS_R_System.ResourceDomainORWorkgroup, SMS_R_System.Client from SMS_R_System
 where SMS_R_System.ResourceNames in (Select ServerName FROM SMS_DistributionPointInfo)"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"All systems that is ConfigMgr distribution point"}}


$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Systems - Created Since 24h"}},@{L="Query"
; E={"select SMS_R_System.Name, SMS_R_System.CreationDate FROM SMS_R_System WHERE DateDiff(dd,SMS_R_System.CreationDate, GetDate()) <= 1"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"All systems created in the last 24 hours"}}

#------------
# Hardware
#------------
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"All Laptops"}},@{L="Query"
; E={"select SMS_R_System.ResourceId, SMS_R_System.ResourceType, SMS_R_System.Name, SMS_R_System.SMSUniqueIdentifier, SMS_R_System.ResourceDomainORWorkgroup, SMS_R_System.Client from SMS_R_System
 inner join SMS_G_System_SYSTEM_ENCLOSURE on SMS_G_System_SYSTEM_ENCLOSURE.ResourceID = SMS_R_System.ResourceId where SMS_G_System_SYSTEM_ENCLOSURE.ChassisTypes in ('8', '9', '10', '11', '12', '14', '18', '21')"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"All laptops"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Laptops - Dell"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM.Manufacturer like '%Dell%'"}},@{L="LimitingCollection"
; E={"All Laptops"}},@{L="Comment"
; E={"All laptops with Dell manufacturer"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Laptops - HP"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM.Manufacturer like '%HP%' or SMS_G_System_COMPUTER_SYSTEM.Manufacturer like '%Hewlett-Packard%'"}},@{L="LimitingCollection"
; E={"All Laptops"}},@{L="Comment"
; E={"All laptops with HP manufacturer"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Laptops - Lenovo"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM.Manufacturer like '%Lenovo%'"}},@{L="LimitingCollection"
; E={"All Laptops"}},@{L="Comment"
; E={"All laptops with Lenovo manufacturer"}}

#-----------
# Mobile OS
#-----------
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Mobile Devices - All"}},@{L="Query"
; E={"select * from SMS_R_System where SMS_R_System.ClientType = 3"}},@{L="LimitingCollection"
; E={$LimitingCollectionAS}},@{L="Comment"
; E={"All Mobile Devices"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Mobile Devices - Android"}},@{L="Query"
; E={"SELECT SMS_R_System.ResourceId, SMS_R_System.ResourceType, SMS_R_System.Name, SMS_R_System.SMSUniqueIdentifier, SMS_R_System.ResourceDomainORWorkgroup, SMS_R_System.Client FROM SMS_R_System
 INNER JOIN SMS_G_System_DEVICE_OSINFORMATION ON SMS_G_System_DEVICE_OSINFORMATION.ResourceID = SMS_R_System.ResourceId WHERE SMS_G_System_DEVICE_OSINFORMATION.Platform like 'Android%'"}},@{L="LimitingCollection"
; E={$LimitingCollectionAS}},@{L="Comment"
; E={"All Android mobile devices"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Mobile Devices - iPhone"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 inner join SMS_G_System_DEVICE_COMPUTERSYSTEM on SMS_G_System_DEVICE_COMPUTERSYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_G_System_DEVICE_COMPUTERSYSTEM.DeviceModel like '%Iphone%'"}},@{L="LimitingCollection"
; E={$LimitingCollectionAS}},@{L="Comment"
; E={"All iPhone mobile devices"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Mobile Devices - iPad"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 inner join SMS_G_System_DEVICE_COMPUTERSYSTEM on SMS_G_System_DEVICE_COMPUTERSYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_G_System_DEVICE_COMPUTERSYSTEM.DeviceModel like '%Ipad%'"}},@{L="LimitingCollection"
; E={$LimitingCollectionAS}},@{L="Comment"
; E={"All iPad mobile devices"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Mobile Devices - Windows Phone 8"}},@{L="Query"
; E={"select SMS_R_System.ResourceId, SMS_R_System.ResourceType, SMS_R_System.Name, SMS_R_System.SMSUniqueIdentifier, SMS_R_System.ResourceDomainORWorkgroup, SMS_R_System.Client from SMS_R_System
 inner join SMS_G_System_DEVICE_OSINFORMATION on SMS_G_System_DEVICE_OSINFORMATION.ResourceID = SMS_R_System.ResourceId where SMS_G_System_DEVICE_OSINFORMATION.Platform = 'Windows Phone' and SMS_G_System_DEVICE_OSINFORMATION.Version like '8.0%'"}},@{L="LimitingCollection"
; E={$LimitingCollectionAS}},@{L="Comment"
; E={"All Windows 8 mobile devices"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Mobile Devices - Windows Phone 8.1"}},@{L="Query"
; E={"select SMS_R_System.ResourceId, SMS_R_System.ResourceType, SMS_R_System.Name, SMS_R_System.SMSUniqueIdentifier, SMS_R_System.ResourceDomainORWorkgroup, SMS_R_System.Client from SMS_R_System
 inner join SMS_G_System_DEVICE_OSINFORMATION on SMS_G_System_DEVICE_OSINFORMATION.ResourceID = SMS_R_System.ResourceId where SMS_G_System_DEVICE_OSINFORMATION.Platform = 'Windows Phone' and SMS_G_System_DEVICE_OSINFORMATION.Version like '8.1%'"}},@{L="LimitingCollection"
; E={$LimitingCollectionAS}},@{L="Comment"
; E={"All Windows 8.1 mobile devices"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Mobile Devices - Windows Phone 10"}},@{L="Query"
; E={"select SMS_R_System.ResourceId, SMS_R_System.ResourceType, SMS_R_System.Name, SMS_R_System.SMSUniqueIdentifier, SMS_R_System.ResourceDomainORWorkgroup, SMS_R_System.Client from SMS_R_System
 inner join SMS_G_System_DEVICE_OSINFORMATION on SMS_G_System_DEVICE_OSINFORMATION.ResourceID = SMS_R_System.ResourceId where SMS_G_System_DEVICE_OSINFORMATION.Platform = 'Windows Phone' and SMS_G_System_DEVICE_OSINFORMATION.Version like '10%'"}},@{L="LimitingCollection"
; E={$LimitingCollectionAS}},@{L="Comment"
; E={"All Windows Phone 10"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Mobile Devices - Microsoft Surface"}},@{L="Query"
; E={"select SMS_R_System.ResourceId, SMS_R_System.ResourceType, SMS_R_System.Name, SMS_R_System.SMSUniqueIdentifier, SMS_R_System.ResourceDomainORWorkgroup, SMS_R_System.Client from SMS_R_System
 inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM.Model like '%Surface%'"}},@{L="LimitingCollection"
; E={$LimitingCollectionAS}},@{L="Comment"
; E={"All Windows RT mobile devices"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Mobile Devices - Microsoft Surface 3"}},@{L="Query"
; E={"select SMS_R_System.ResourceId, SMS_R_System.ResourceType, SMS_R_System.Name, SMS_R_System.SMSUniqueIdentifier, SMS_R_System.ResourceDomainORWorkgroup, SMS_R_System.Client from SMS_R_System
 inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM.Model = 'Surface Pro 3' OR SMS_G_System_COMPUTER_SYSTEM.Model = 'Surface 3'"}},@{L="LimitingCollection"
; E={$LimitingCollectionAS}},@{L="Comment"
; E={"All Microsoft Surface 3"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Mobile Devices - Microsoft Surface 4"}},@{L="Query"
; E={"select SMS_R_System.ResourceId, SMS_R_System.ResourceType, SMS_R_System.Name, SMS_R_System.SMSUniqueIdentifier, SMS_R_System.ResourceDomainORWorkgroup, SMS_R_System.Client from SMS_R_System
 inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM.Model = 'Surface Pro 4'"}},@{L="LimitingCollection"
; E={$LimitingCollectionAS}},@{L="Comment"
; E={"All Microsoft Surface 4"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Others - Linux Devices"}},@{L="Query"
; E={"select * from SMS_R_System where SMS_R_System.ClientEdition = 13"}},@{L="LimitingCollection"
; E={$LimitingCollectionAS}},@{L="Comment"
; E={"All systems with Linux"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Others - MAC OSX Devices"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 WHERE OperatingSystemNameandVersion LIKE 'Apple Mac OS X%'"}},@{L="LimitingCollection"
; E={$LimitingCollectionAS}},@{L="Comment"
; E={"All workstations with MAC OSX"}}


#------------
# OS
#------------
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"All Desktop Clients"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 where OperatingSystemNameandVersion like '%Workstation%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"All workstations"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Workstations - Active"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 inner join SMS_G_System_CH_ClientSummary on SMS_G_System_CH_ClientSummary.ResourceId = SMS_R_System.ResourceId where (SMS_R_System.OperatingSystemNameandVersion like 'Microsoft Windows NT%Workstation%' or SMS_R_System.OperatingSystemNameandVersion = 'Windows 7 Entreprise 6.1') and SMS_G_System_CH_ClientSummary.ClientActiveStatus = 1 and SMS_R_System.Client = 1 and SMS_R_System.Obsolete = 0"}},@{L="LimitingCollection"
; E={"All Desktop Clients"}},@{L="Comment"
; E={"All workstations with active state"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Workstations - Windows 7"}},@{L="Query"
; E={"select SMS_R_System.ResourceID,SMS_R_System.ResourceType,SMS_R_System.Name,SMS_R_System.SMSUniqueIdentifier,SMS_R_System.ResourceDomainORWorkgroup,SMS_R_System.Client from SMS_R_System
 where OperatingSystemNameandVersion like '%Workstation 6.1%'"}},@{L="LimitingCollection"
; E={"All Desktop Clients"}},@{L="Comment"
; E={"All workstations with Windows 7 operating system"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Workstations - Windows 8"}},@{L="Query"
; E={"select SMS_R_System.ResourceID,SMS_R_System.ResourceType,SMS_R_System.Name,SMS_R_System.SMSUniqueIdentifier,SMS_R_System.ResourceDomainORWorkgroup,SMS_R_System.Client from SMS_R_System
 where OperatingSystemNameandVersion like '%Workstation 6.2%'"}},@{L="LimitingCollection"
; E={"All Desktop Clients"}},@{L="Comment"
; E={"All workstations with Windows 8 operating system"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Workstations - Windows 8.1"}},@{L="Query"
; E={"select SMS_R_System.ResourceID,SMS_R_System.ResourceType,SMS_R_System.Name,SMS_R_System.SMSUniqueIdentifier,SMS_R_System.ResourceDomainORWorkgroup,SMS_R_System.Client from SMS_R_System
 where OperatingSystemNameandVersion like '%Workstation 6.3%'"}},@{L="LimitingCollection"
; E={"All Desktop Clients"}},@{L="Comment"
; E={"All workstations with Windows 8.1 operating system"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Workstations - Windows XP"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 where OperatingSystemNameandVersion like '%Workstation 5.1%' or OperatingSystemNameandVersion like '%Workstation 5.2%'"}},@{L="LimitingCollection"
; E={"All Desktop Clients"}},@{L="Comment"
; E={"All workstations with Windows XP operating system"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Workstations - Windows 10"}},@{L="Query"
; E={"select SMS_R_System.ResourceID,SMS_R_System.ResourceType,SMS_R_System.Name,SMS_R_System.SMSUniqueIdentifier,SMS_R_System.ResourceDomainORWorkgroup,SMS_R_System.Client from SMS_R_System
 where OperatingSystemNameandVersion like '%Workstation 10.0%'"}},@{L="LimitingCollection"
; E={"All Desktop Clients"}},@{L="Comment"
; E={"All workstations with Windows 10 operating system"}}


#------------
# Server
#------------
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"All Server Clients"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 where OperatingSystemNameandVersion like '%Server%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"All servers"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Servers - Active"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 inner join SMS_G_System_CH_ClientSummary on SMS_G_System_CH_ClientSummary.ResourceId = SMS_R_System.ResourceId where SMS_G_System_CH_ClientSummary.ClientActiveStatus = 1 and SMS_R_System.Client = 1 and SMS_R_System.Obsolete = 0"}},@{L="LimitingCollection"
; E={"All Server Clients"}},@{L="Comment"
; E={"All servers with active state"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Servers - Physical"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 where SMS_R_System.ResourceId not in (select SMS_R_SYSTEM.ResourceID from SMS_R_System inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_R_System.IsVirtualMachine = 'True') and SMS_R_System.OperatingSystemNameandVersion
 like 'Microsoft Windows NT%Server%'"}},@{L="LimitingCollection"
; E={"All Server Clients"}},@{L="Comment"
; E={"All physical servers"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Servers - Virtual"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 where SMS_R_System.IsVirtualMachine = 'True' and SMS_R_System.OperatingSystemNameandVersion like 'Microsoft Windows NT%Server%'"}},@{L="LimitingCollection"
; E={"All Server Clients"}},@{L="Comment"
; E={"All virtual servers"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Servers - Windows 2003 and 2003 R2"}},@{L="Query"
; E={"select SMS_R_System.ResourceID,SMS_R_System.ResourceType,SMS_R_System.Name,SMS_R_System.SMSUniqueIdentifier,SMS_R_System.ResourceDomainORWorkgroup,SMS_R_System.Client from SMS_R_System
 where OperatingSystemNameandVersion like '%Server 5.2%'"}},@{L="LimitingCollection"
; E={"All Server Clients"}},@{L="Comment"
; E={"All servers with Windows 2003 or 2003 R2 operating system"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Servers - Windows 2008 and 2008 R2"}},@{L="Query"
; E={"select SMS_R_System.ResourceID,SMS_R_System.ResourceType,SMS_R_System.Name,SMS_R_System.SMSUniqueIdentifier,SMS_R_System.ResourceDomainORWorkgroup,SMS_R_System.Client from SMS_R_System
 where OperatingSystemNameandVersion like '%Server 6.0%' or OperatingSystemNameandVersion like '%Server 6.1%'"}},@{L="LimitingCollection"
; E={"All Server Clients"}},@{L="Comment"
; E={"All servers with Windows 2008 or 2008 R2 operating system"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Servers - Windows 2012 and 2012 R2"}},@{L="Query"
; E={"select SMS_R_System.ResourceID,SMS_R_System.ResourceType,SMS_R_System.Name,SMS_R_System.SMSUniqueIdentifier,SMS_R_System.ResourceDomainORWorkgroup,SMS_R_System.Client from SMS_R_System
 where OperatingSystemNameandVersion like '%Server 6.2%' or OperatingSystemNameandVersion like '%Server 6.3%'"}},@{L="LimitingCollection"
; E={"All Server Clients"}},@{L="Comment"
; E={"All servers with Windows 2012 or 2012 R2 operating system"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Servers - Windows 2016"}},@{L="Query"
; E={"select SMS_R_System.ResourceID,SMS_R_System.ResourceType,SMS_R_System.Name,SMS_R_System.SMSUniqueIdentifier,SMS_R_System.ResourceDomainORWorkgroup,SMS_R_System.Client from SMS_R_System
 where OperatingSystemNameandVersion like '%Server 10%'"}},@{L="LimitingCollection"
; E={"All Server Clients"}},@{L="Comment"
; E={"All Servers with Windows 2016"}}


#------------
# Software
#------------
##Collection 84
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Office 365 Channel - Monthly"}},@{L="Query"
; E={"select SMS_R_System.ResourceId, SMS_R_System.ResourceType, SMS_R_System.Name, SMS_R_System.SMSUniqueIdentifier, SMS_R_System.ResourceDomainORWorkgroup, SMS_R_System.Client from  SMS_R_System inner join SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS on SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.ResourceID = SMS_R_System.ResourceId where SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.cfgUpdateChannel = 'http://officecdn.microsoft.com/pr/492350f6-3a01-4f97-b9c0-c7c6ddf67d60'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"Office 365 Channel - Monthly"}}

##Collection 85
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Office 365 Channel - Monthly (Targeted)"}},@{L="Query"
; E={"select SMS_R_System.ResourceId, SMS_R_System.ResourceType, SMS_R_System.Name, SMS_R_System.SMSUniqueIdentifier, SMS_R_System.ResourceDomainORWorkgroup, SMS_R_System.Client from  SMS_R_System inner join SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS on SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.ResourceID = SMS_R_System.ResourceId where SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.cfgUpdateChannel = 'http://officecdn.microsoft.com/pr/64256afe-f5d9-4f86-8936-8840a6a4f5be'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"Office 365 Channel - Monthly (Targeted)"}}

##Collection 86
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Office 365 Channel - Semi-Annual (Targeted)"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS on SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.ResourceID = SMS_R_System.ResourceId where SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.cfgUpdateChannel = 'http://officecdn.microsoft.com/pr/b8f9b850-328d-4355-9145-c59439a0c4cf'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"Office 365 Channel - Semi-Annual (Targeted)"}}

##Collection 87
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Office 365 Channel - Semi-Annual"}},@{L="Query"
; E={"select SMS_R_System.ResourceId, SMS_R_System.ResourceType, SMS_R_System.Name, SMS_R_System.SMSUniqueIdentifier, SMS_R_System.ResourceDomainORWorkgroup, SMS_R_System.Client from  SMS_R_System inner join SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS on SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.ResourceID = SMS_R_System.ResourceId where SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.cfgUpdateChannel = 'http://officecdn.microsoft.com/pr/7ffbc6bf-bc32-4f92-8982-f9dd17fd3114'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"Office 365 Channel - Semi-Annual"}}

##Collection 78
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Office 365 Build - Version 1802"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS on SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.ResourceId = SMS_R_System.ResourceId where SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.VersionToReport like '16.0.9029.%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"Office 365 Build - Version 1802"}}

##Collection 79
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Office 365 Build - Version 1803"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS on SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.ResourceId = SMS_R_System.ResourceId where SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.VersionToReport like '16.0.9126.%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"Office 365 Build - Version 1803"}}

##Collection 80
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Office 365 Build - Version 1708"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS on SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.ResourceId = SMS_R_System.ResourceId where SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.VersionToReport like '16.0.8431.%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"Office 365 Build - Version 1708"}}

##Collection 81
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Office 365 Build - Version 1705"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS on SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.ResourceId = SMS_R_System.ResourceId where SMS_G_System_OFFICE365PROPLUSCONFIGURATIONS.VersionToReport like '16.0.8201.%'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"Office 365 Build - Version 1705"}}

#------------
# System Health
#------------
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Client Health - Hardware Inventory over 14 Days old"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 where ResourceId in (select SMS_R_System.ResourceID from SMS_R_System inner join SMS_G_System_WORKSTATION_STATUS on SMS_G_System_WORKSTATION_STATUS.ResourceID = SMS_R_System.ResourceId where DATEDIFF(dd,SMS_G_System_WORKSTATION_STATUS.LastHardwareScan,GetDate())
 > 14)"}},@{L="LimitingCollection" 
; E={"Clients - All"}},@{L="Comment"
; E={"All devices with ConfigMgr client that have not communicated with hardware inventory over 14 days"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"System Health - Software Inventory - Clients Not Reporting since 30 Days"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 where ResourceId in (select SMS_R_System.ResourceID from SMS_R_System inner join SMS_G_System_LastSoftwareScan on SMS_G_System_LastSoftwareScan.ResourceId = SMS_R_System.ResourceId where DATEDIFF(dd,SMS_G_System_LastSoftwareScan.LastScanDate,GetDate()) > 30)"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"All devices with ConfigMgr client that have not communicated with software inventory over 30 days"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"System Health - Clients Active"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 inner join SMS_G_System_CH_ClientSummary on SMS_G_System_CH_ClientSummary.ResourceId = SMS_R_System.ResourceId where SMS_G_System_CH_ClientSummary.ClientActiveStatus = 1 and SMS_R_System.Client = 1 and SMS_R_System.Obsolete = 0"}},@{L="LimitingCollection"
; E={"Clients - All"}},@{L="Comment"
; E={"All devices with ConfigMgr client state active"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"System Health - Clients Inactive"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 inner join SMS_G_System_CH_ClientSummary on SMS_G_System_CH_ClientSummary.ResourceId = SMS_R_System.ResourceId where SMS_G_System_CH_ClientSummary.ClientActiveStatus = 0 and SMS_R_System.Client = 1 and SMS_R_System.Obsolete = 0"}},@{L="LimitingCollection"
; E={"Clients - All"}},@{L="Comment"
; E={"All devices with ConfigMgr client state inactive"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"System Health - Disabled"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 where SMS_R_System.UserAccountControl ='4098'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"All systems with client state disabled"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"System Health - Obsolete"}},@{L="Query"
; E={"select * from SMS_R_System where SMS_R_System.Obsolete = 1"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"All devices with ConfigMgr client state obsolete"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Windows Update Agent - Outdated Version Win7 RTM and Lower"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 inner join SMS_G_System_WINDOWSUPDATEAGENTVERSION on SMS_G_System_WINDOWSUPDATEAGENTVERSION.ResourceID = SMS_R_System.ResourceId inner join SMS_G_System_OPERATING_SYSTEM on SMS_G_System_OPERATING_SYSTEM.ResourceID = SMS_R_System.ResourceId where SMS_G_System_WINDOWSUPDATEAGENTVERSION.Version
 < '7.6.7600.256' and SMS_G_System_OPERATING_SYSTEM.Version <= '6.1.7600'"}},@{L="LimitingCollection"
; E={"All Desktop Clients"}},@{L="Comment"
; E={"All systems with windows update agent with outdated version Win7 RTM and lower"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Windows Update Agent - Outdated Version Win7 SP1 and Higher"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 inner join SMS_G_System_WINDOWSUPDATEAGENTVERSION on SMS_G_System_WINDOWSUPDATEAGENTVERSION.ResourceID = SMS_R_System.ResourceId inner join SMS_G_System_OPERATING_SYSTEM on SMS_G_System_OPERATING_SYSTEM.ResourceID = SMS_R_System.ResourceId where SMS_G_System_WINDOWSUPDATEAGENTVERSION.Version
 < '7.6.7600.320' and SMS_G_System_OPERATING_SYSTEM.Version >= '6.1.7601'"}},@{L="LimitingCollection"
; E={"All Desktop Clients"}},@{L="Comment"
; E={"All systems with windows update agent with outdated version Win7 SP1 and higher"}}

##Collection 82
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"System Health - Clients Online"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ResourceId in (select resourceid from SMS_CollectionMemberClientBaselineStatus where SMS_CollectionMemberClientBaselineStatus.CNIsOnline = 1)"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"System Health - Clients Online"}}

##Collection 91
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"System Health - Duplicate Device Name"}},@{L="Query"
; E={"select R.ResourceID,R.ResourceType,R.Name,R.SMSUniqueIdentifier,R.ResourceDomainORWorkgroup,R.Client from SMS_R_System as r   full join SMS_R_System as s1 on s1.ResourceId = r.ResourceId   full join SMS_R_System as s2 on s2.Name = s1.Name   where s1.Name = s2.Name and s1.ResourceId != s2.ResourceId"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"; E={"All systems having a duplicate device record"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Workstations - Windows 10 Support State - Current"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 LEFT OUTER JOIN SMS_WindowsServicingStates ON SMS_WindowsServicingStates.Build = SMS_R_System.build01 AND SMS_WindowsServicingStates.branch = SMS_R_System.osbranch01 where SMS_WindowsServicingStates.State = '2'"}},@{L="LimitingCollection"
; E={"All Desktop Clients"}},@{L="Comment"
; E={"Windows 10 Support State - Current"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Workstations - Windows 10 Support State - Expired Soon"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 LEFT OUTER JOIN SMS_WindowsServicingStates ON SMS_WindowsServicingStates.Build = SMS_R_System.build01 AND SMS_WindowsServicingStates.branch = SMS_R_System.osbranch01 where SMS_WindowsServicingStates.State = '3'"}},@{L="LimitingCollection"
; E={"All Desktop Clients"}},@{L="Comment"
; E={"Windows 10 Support State - Expired Soon"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Workstations - Windows 10 Support State - Expired"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 LEFT OUTER JOIN SMS_WindowsServicingStates ON SMS_WindowsServicingStates.Build = SMS_R_System.build01 AND SMS_WindowsServicingStates.branch = SMS_R_System.osbranch01 where SMS_WindowsServicingStates.State = '4'"}},@{L="LimitingCollection"
; E={"All Desktop Clients"}},@{L="Comment"
; E={"Windows 10 Support State - Expired"}}

##------------
# Win10
#------------

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Workstations - Windows 10 v1507"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 where SMS_R_System.Build = '10.0.10240'"}},@{L="LimitingCollection"
; E={"Workstations - Windows 10"}},@{L="Comment"
; E={"All workstations with Windows 10 operating system v1507"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Workstations - Windows 10 v1511"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 where SMS_R_System.Build = '10.0.10586'"}},@{L="LimitingCollection"
; E={"Workstations - Windows 10"}},@{L="Comment"
; E={"All workstations with Windows 10 operating system v1511"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Workstations - Windows 10 v1607"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 where SMS_R_System.Build = '10.0.14393'"}},@{L="LimitingCollection"
; E={"Workstations - Windows 10"}},@{L="Comment"
; E={"All workstations with Windows 10 operating system v1607"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Workstations - Windows 10 v1703"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 where SMS_R_System.Build = '10.0.15063'"}},@{L="LimitingCollection"
; E={"Workstations - Windows 10"}},@{L="Comment"
; E={"All workstations with Windows 10 operating system v1703"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Workstations - Windows 10 v1709"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 where SMS_R_System.Build = '10.0.16299'"}},@{L="LimitingCollection"
; E={"Workstations - Windows 10"}},@{L="Comment"
; E={"All workstations with Windows 10 operating system v1709"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Workstations - Windows 10 Current Branch (CB)"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 where SMS_R_System.OSBranch = '0'"}},@{L="LimitingCollection"
; E={"Workstations - Windows 10"}},@{L="Comment"
; E={"All workstations with Windows 10 CB"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Workstations - Windows 10 Current Branch for Business (CBB)"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 where SMS_R_System.OSBranch = '1'"}},@{L="LimitingCollection"
; E={"Workstations - Windows 10"}},@{L="Comment"
; E={"All workstations with Windows 10 CBB"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Workstations - Windows 10 Long Term Servicing Branch (LTSB)"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System
 where SMS_R_System.OSBranch = '2'"}},@{L="LimitingCollection"
; E={"Workstations - Windows 10"}},@{L="Comment"
; E={"All workstations with Windows 10 LTSB"}}

#Collection 83
$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Workstations - Windows 10 v1803"}},@{L="Query"
; E={"select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.Build = '10.0.17134'"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"Workstations - Windows 10 v1803"}}





#Check Existing Collections
$Overwrite = 1
$ErrorCount = 0
$ErrorHeader = "The script has already been run. The following collections already exist in your environment:`n`r"
$ErrorCollections = @()
$ErrorFooter = "Would you like to delete and recreate the collections above? (Default : No) "
$ExistingCollections | Sort-Object Name | ForEach-Object {If($Collections.Name -Contains $_.Name) {$ErrorCount +=1 ; $ErrorCollections += $_.Name}}

#Error
If ($ErrorCount -ge1) 
    {
    Write-Host $ErrorHeader $($ErrorCollections | ForEach-Object {(" " + $_ + "`n`r")}) $ErrorFooter -ForegroundColor Yellow -NoNewline
    $ConfirmOverwrite = Read-Host "[Y/N]"
    If ($ConfirmOverwrite -ne "Y") {$Overwrite =0}
    }

#Create Collection And Move the collection to the right folder
If ($Overwrite -eq1) {
$ErrorCount =0

ForEach ($Collection
In $($Collections | Sort-Object LimitingCollection -Descending))

{
If ($ErrorCollections -Contains $Collection.Name)
    {
    Get-CMDeviceCollection -Name $Collection.Name | Remove-CMDeviceCollection -Force
    Write-host *** Collection $Collection.Name removed and will be recreated ***
    }
}

ForEach ($Collection In $($Collections | Sort-Object LimitingCollection))
{

Try 
    {
    New-CMDeviceCollection -Name $Collection.Name -Comment $Collection.Comment -LimitingCollectionName $Collection.LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
    Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection.Name -QueryExpression $Collection.Query -RuleName $Collection.Name
    Write-host *** Collection $Collection.Name created ***
    }

Catch {
        Write-host "-----------------"
        Write-host -ForegroundColor Red ("There was an error creating the: " + $Collection.Name + " collection.")
        Write-host "-----------------"
        $ErrorCount += 1
        Pause
}

Try {
        Move-CMObject -FolderPath $FolderPath -InputObject $(Get-CMDeviceCollection -Name $Collection.Name)
        Write-host *** Collection $Collection.Name moved to $CollectionFolder.Name folder***
    }

Catch {
        Write-host "-----------------"
        Write-host -ForegroundColor Red ("There was an error moving the: " + $Collection.Name +" collection to " + $CollectionFolder.Name +".")
        Write-host "-----------------"
        $ErrorCount += 1
        Pause
      }

}

If ($ErrorCount -ge1) {

        Write-host "-----------------"
        Write-Host -ForegroundColor Red "The script execution completed, but with errors."
        Write-host "-----------------"
        Pause
}

Else{
        Write-host "-----------------"
        Write-Host -ForegroundColor Green "Script execution completed without error. Operational Collections created sucessfully."
        Write-host "-----------------"
        Pause
    }
}

Else {
        Write-host "-----------------"
        Write-host -ForegroundColor Red ("The following collections already exist in your environment:`n`r" + $($ErrorCollections | ForEach-Object {(" " +$_ + "`n`r")}) + "Please delete all collections manually or rename them before re-executing the script! You can also select Y to do it automaticaly")
        Write-host "-----------------"
        Pause
}
