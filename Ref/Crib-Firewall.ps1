#Cheat-Firewall
#local
# Set-NetFirewallRule -DisplayGroup "File And Printer Sharing" -Enabled True -Profile Private
#or remote
# Invoke-Command -ComputerName PC1, PC2, PC3 -ScriptBlock { Set-NetFirewallRule -DisplayGroup "File And Printer Sharing" -Enabled True -Profile Private }