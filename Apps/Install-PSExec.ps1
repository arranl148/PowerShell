Invoke-WebRequest -Uri 'https://download.sysinternals.com/files/PSTools.zip' -OutFile 'pstools.zip'
Expand-Archive -Path 'pstools.zip' -DestinationPath "$env:TEMP\pstools"
Move-Item -Path "$env:TEMP\pstools\psexec.exe" .
Move-Item -Path "$env:TEMP\pstools\psexec64.exe" .
Remove-Item -Path "$env:TEMP\pstools" -Recurse

#local
# Set-NetFirewallRule -DisplayGroup "File And Printer Sharing" -Enabled True -Profile Private
#or remote
# Invoke-Command -ComputerName PC1, PC2, PC3 -ScriptBlock { Set-NetFirewallRule -DisplayGroup "File And Printer Sharing" -Enabled True -Profile Private }
