# Scratchpad notes
These are random notes that I would previously have saved in OneNote before the security was fixed

## Windows multi-app kiosk
In Intune, with single-app kiosk, you get the option for different Edge options. So selecting 'Microsoft Edge Browser' applies latest Edge. All good.

With Multi-app kiosk, if you add the Edge browser (AUMID), this is Edge legacy which doesn't work. You have to add Edge as Win32 App and then d_ck around with deploying a PS script to run Edge in kiosk mode. Not sure why MS haven'’'t updated the Multi-app option in line with single-app. 

The script is here if you need it:

```WSH
{
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut(“$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Kiosk.lnk”)
    $Shortcut.TargetPath = ‘”C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe”’
    $Shortcut.Arguments = “—kiosk blog.mindcore.dk—edge-kiosk-type=public-browsing—no-first-run”$Shortcut.WorkingDirectory = ‘”C:\Program Files (x86)\Microsoft\Edge\Application”’
    $Shortcut.Save()
}
```

```PowerShell
{
    # Get a list of all available applications
    $availableApplications = Get-CMApplication | Where-Object { $_.IsExpired -eq $false }
}