#AoVPN Check - LRH
If (Get-WmiObject -Query "Select * from Win32_IP4RouteTable where Name like '10.157.24%' and not name like '10.157.24.%'")
        {Write-host "VPN-Active"}
    ElseIf (Get-WmiObject -Query "Select * from Win32_IP4RouteTable where Name like '10.157.25%' and not name like '10.157.25.%'")
        {Write-host "VPN-Active"}
#AoVPN Check - FLC
    ElseIf (Get-WmiObject -Query "Select * from Win32_IP4RouteTable where Name like '10.121.10%' and not name like '10.121.10.%'")
        {Write-host "VPN-Active"}
    ElseIf (Get-WmiObject -Query "Select * from Win32_IP4RouteTable where Name like '10.121.111.%' or  Name like '10.121.112.%'")
        {Write-host "VPN-Active"}
    ElseIf (Get-WmiObject -Query "Select * from Win32_IP4RouteTable where Name like '10.121.96.%'")
        {Write-host "VPN-Active"}
    ElseIf (Get-WmiObject -Query "Select * from Win32_IP4RouteTable where Name like '10.121.97.%'")
        {Write-host "VPN-Active"}
    ElseIf (Get-WmiObject -Query "Select * from Win32_IP4RouteTable where Name like '10.121.98.%'")
        {Write-host "VPN-Active"}
    ElseIf (Get-WmiObject -Query "Select * from Win32_IP4RouteTable where Name like '10.121.99.%'")
        {Write-host "VPN-Active"}
    Else {Write-host "VPN-InActive"}