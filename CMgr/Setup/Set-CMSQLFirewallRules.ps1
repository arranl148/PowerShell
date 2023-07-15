write-host "Enabling SQLServer default instance port 1433"
New-NetFirewallRule -DisplayName "SQL Server" -Direction Inbound –Protocol TCP –LocalPort 1433 -Action allow
#Enabling Dedicated Admin Connection port 1434
New-NetFirewallRule -DisplayName "SQL Admin Connection" -Direction Inbound –Protocol TCP –LocalPort 1434 -Action allow
#
New-NetFirewallRule -DisplayName "SQL Database Management" -Direction Inbound –Protocol UDP –LocalPort 1434 -Action allow
#Enabling conventional SQL Server Service Broker port 4022
New-NetFirewallRule -DisplayName "SQL Service Broker" -Direction Inbound –Protocol TCP –LocalPort 4022 -Action allow
#Enabling Transact-SQL Debugger/RPC port 135
New-NetFirewallRule -DisplayName "SQL Debugger/RPC" -Direction Inbound –Protocol TCP –LocalPort 135 -Action allow


<#
#========= Analysis Services Ports ==============
# Enabling SSAS Default Instance port 2383
New-NetFirewallRule -DisplayName "SQL Analysis Services" -Direction Inbound -Action allow  -Profile Domain -Protocol TCP localport=2383
# Enabling SQL Server Browser Service port 2382
New-NetFirewallRule -DisplayName "SQL Browser" -Direction Inbound -Action allow  -Profile Domain -Protocol TCP localport=2382
#>

<# # ========= Misc Applications ==============
# Enabling HTTP port 80
New-NetFirewallRule -DisplayName "HTTP" -Direction Inbound -Action allow  -Profile Domain -Protocol TCP localport=80
# Enabling SSL port 443
New-NetFirewallRule -DisplayName "SSL" -Direction Inbound -Action allow  -Profile Domain -Protocol TCP localport=443
# Enabling port for SQL Server Browser Service's 'Browse' Button
New-NetFirewallRule -DisplayName "SQL Browser" -Direction Inbound -Action allow  -Profile Domain -Protocol TCP localport=1434
# Allowing Ping command
New-NetFirewallRule -DisplayName "ICMP Allow incoming V4 echo request" -Profile Domain -Protocol icmpv4:8,any -Direction Inbound -Action allow 
#>

<#
## DP's -Profile Domain
# Enabling Server Message Block 445
New-NetFirewallRule -DisplayName "Server Message Block (SMB)" -Direction Inbound –Protocol TCP –LocalPort 445 -Action allow -Profile Domain
#Enabling Transact-SQL Debugger/RPC port 135
New-NetFirewallRule -DisplayName "RPC Endpoint Mapper" -Direction Inbound –Protocol TCP –LocalPort 135 -Action allow -Profile Domain
New-NetFirewallRule -DisplayName "RPC Endpoint Mapper (UDP)" -Direction Inbound –Protocol UDP –LocalPort 135 -Action allow -Profile Domain
#>