$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Servers - Windows 2016"}},@{L="Query"
; E={"select * from SMS_R_System inner join SMS_G_System_OPERATING_SYSTEM on SMS_G_System_OPERATING_SYSTEM.ResourceId = SMS_R_System.ResourceId where OperatingSystemNameandVersion like '%Server 10%' and SMS_G_System_OPERATING_SYSTEM.BuildNumber = '14393'"}},@{L="LimitingCollection"
; E={"Servers | All"}},@{L="Comment"
; E={"All Servers with Windows 2016"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Servers | Windows 2019"}},@{L="Query"
; E={"select * from SMS_R_System inner join SMS_G_System_OPERATING_SYSTEM on SMS_G_System_OPERATING_SYSTEM.ResourceId = SMS_R_System.ResourceId where OperatingSystemNameandVersion like '%Server 10%' and SMS_G_System_OPERATING_SYSTEM.BuildNumber = '17763'"}},@{L="LimitingCollection"
; E={"Servers | All"}},@{L="Comment"
; E={"All Servers with Windows 2019"}}

$Collections +=
$DummyObject |
Select-Object @{L="Name"
; E={"Server Clients Not Reporting in 14 Days"}},@{L="Query"
; E={"select * from SMS_R_System where ResourceId in (select SMS_R_System.ResourceID from SMS_R_System inner join SMS_G_System_LastSoftwareScan on SMS_G_System_LastSoftwareScan.ResourceId = SMS_R_System.ResourceId where DATEDIFF(dd,SMS_G_System_LastSoftwareScan.LastScanDate,GetDate()) > 14)"}},@{L="LimitingCollection"
; E={$LimitingCollection}},@{L="Comment"
; E={"All devices with SCCM client that have not communicated with software inventory over 30 days"}}