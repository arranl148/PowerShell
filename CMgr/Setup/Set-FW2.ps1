# SCCM Firewall Rules
Invoke-Command -ComputerName $ServerName -ScriptBlock {
  If ((Get-NetFirewallRule -DisplayName 'SCCM Traffic*') -eq $null)
  {
    Write-Verbose -Message "Writing SCCM Firewall Rules for $ServerName"
    New-NetFirewallRule -DisplayName 'SCCM Traffic Inbound IP Rules (TCP)' -Enabled True -Direction Inbound -Action Allow -LocalPort 80, 443, 1723, 8530, 8531, 445, 135, 5985, 5986 -Protocol TCP -Profile Domain
    New-NetFirewallRule -DisplayName 'SCCM Traffic Outbound IP Rules (TCP)' -Enabled True -Direction Outbound -Action Allow -LocalPort 80, 443, 1723, 8530, 8531, 445, 135, 5985, 5986 -Protocol TCP -Profile Domain
    New-NetFirewallRule -DisplayName 'SCCM Traffic Inbound IP Rules (UDP)' -Enabled True -Direction Inbound -Action Allow -LocalPort 135 -Protocol UDP -Profile Domain  
    New-NetFirewallRule -DisplayName 'SCCM Traffic Outbound IP Rules (UDP)' -Enabled True -Direction Outbound -Action Allow -LocalPort 135 -Protocol UDP -Profile Domain
    New-NetFirewallRule -DisplayName 'SCCM Traffic Inbound IP Rules (TCP Ephemeral)' -Enabled True -Direction Inbound -Action Allow -LocalPort 49152-65535 -Protocol TCP -Profile Domain
    New-NetFirewallRule -DisplayName 'SCCM Traffic Outbound IP Rules (TCP Ephemeral)' -Enabled True -Direction Outbound -Action Allow -LocalPort 49152-65535 -Protocol TCP -Profile Domain
  }
  Else
  {
    Write-Verbose -Message "SCCM Firewall Rules exist on $ServerName. Continuing..."
  }
}