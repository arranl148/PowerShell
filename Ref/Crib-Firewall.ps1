#Cheat-Firewall
#local
# Set-NetFirewallRule -DisplayGroup "File And Printer Sharing" -Enabled True -Profile Private
#or remote
# Invoke-Command -ComputerName PC1, PC2, PC3 -ScriptBlock { Set-NetFirewallRule -DisplayGroup "File And Printer Sharing" -Enabled True -Profile Private }


#####
# Firewall
#####

# Example PowerShell script for Intune - Printer sharing
New-NetFirewallRule -DisplayName "Printer Sharing Rule" -Direction Inbound -Protocol TCP -LocalPort 515 -Action Allow
New-NetFirewallRule -DisplayName "SNMP Rule" -Direction Inbound -Protocol UDP -LocalPort 161 -Action Allow
# Add more rules as needed