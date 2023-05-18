<#
.SYNOPSIS
    Remove built-in apps (modern apps) from Windows 10 for all users.

.DESCRIPTION
    This script will remove all built-in apps that are specified in the 'redlistedapps' variable.

    ##WARNING## 
    Use with caution, restoring deleted provisioning packages is not a simple process.
        
.NOTES
    Idea based on an original script for Windows 10 app removal / Credit to: Nickolaj Andersen @ MSEndpointMgr
    Modifications to original script to Remove/Black/Red list Appx instead of White/Keep/Green list
    Draws heavily from Remove-Appx-AllUsers-CloudSourceList.ps1 by Author:      Ben Whitmore     Contact:     @byteben  
         Article: msendpointmgr.com/2022/06/27/remove-built-in-windows-11-apps-leveraging-a-cloud-sourced-reference-file/

###### Windows 10 Apps###### with VB recommendation

Microsoft.549981C3F5F10 (Cortana Search) #Optional
Microsoft.BingWeather
Microsoft.DesktopAppInstaller #Keep 
Microsoft.GetHelp
Microsoft.Getstarted
Microsoft.HEIFImageExtension #Keep 
Microsoft.Microsoft3DViewer
Microsoft.MicrosoftOfficeHub
Microsoft.MicrosoftSolitaireCollection
Microsoft.MicrosoftStickyNotes
Microsoft.MixedReality.Portal
Microsoft.MSPaint #Optional
Microsoft.Office.OneNote #Optional
Microsoft.People
Microsoft.SkypeApp
Microsoft.ScreenSketch #Keep
Microsoft.VCLibs.140.00 #Keep
Microsoft.StorePurchaseApp #Keep
Microsoft.VP9VideoExtensions #Keep
Microsoft.Wallet
Microsoft.WebMediaExtensions #Keep
Microsoft.WebpImageExtension #Keep
Microsoft.Windows.Photos #Keep
Microsoft.WindowsAlarms #Keep
Microsoft.WindowsCalculator #Keep
Microsoft.WindowsCamera #Keep
microsoft.windowscommunicationsapps
Microsoft.WindowsFeedbackHub
Microsoft.WindowsMaps
Microsoft.WindowsSoundRecorder #Keep
Microsoft.WindowsStore #Keep
Microsoft.XboxApp
Microsoft.Xbox.TCUI
Microsoft.XboxGameOverlay
Microsoft.XboxGamingOverlay
Microsoft.XboxIdentityProvider
Microsoft.XboxSpeechToTextOverlay
Microsoft.YourPhone
Microsoft.ZuneMusic #Optional
Microsoft.ZuneVideo #Optional
#>

Begin {

    #Log Function
    function Write-LogEntry {
        param (
            [parameter(Mandatory = $true)]
            [ValidateNotNullOrEmpty()]
            [string]$Value,
            [parameter(Mandatory = $false)]
            [ValidateNotNullOrEmpty()]
            [string]$FileName = "AppXRemoval.log",
            [switch]$Stamp
        )
    
        #Build Log File appending System Date/Time to output
        $LogFile = Join-Path -Path $env:SystemRoot -ChildPath $("Temp\$FileName")
        $Time = -join @((Get-Date -Format "HH:mm:ss.fff"), " ", (Get-WmiObject -Class Win32_TimeZone | Select-Object -ExpandProperty Bias))
        $Date = (Get-Date -Format "MM-dd-yyyy")
    
        If ($Stamp) {
            $LogText = "<$($Value)> <time=""$($Time)"" date=""$($Date)"">"
        }
        else {
            $LogText = "$($Value)"   
        }
        
        Try {
            Out-File -InputObject $LogText -Append -NoClobber -Encoding Default -FilePath $LogFile -ErrorAction Stop
        }
        Catch [System.Exception] {
            Write-Warning -Message "Unable to add log entry to $LogFile.log file. Error message at line $($_.InvocationInfo.ScriptLineNumber): $($_.Exception.Message)"
        }
    }

    #Function to Remove AppxProvisionedPackage
    Function Remove-AppxProvisionedPackageCustom {

        # Attempt to remove AppxProvisioningPackage
        if (!([string]::IsNullOrEmpty($RedListedApp))) {
            try {
            
                # Get Package Name
                $AppProvisioningPackageName = Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like $RedListedApp } | Select-Object -ExpandProperty PackageName -First 1
                Write-Host "$($RedListedApp) found. Attempting removal ... " -NoNewline
                Write-LogEntry -Value "$($RedListedApp) found. Attempting removal ... "

                # Attempt removeal
                $RemoveAppx = Remove-AppxProvisionedPackage -PackageName $AppProvisioningPackageName -Online -AllUsers
                
                #Re-check existence
                $AppProvisioningPackageNameReCheck = Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like $RedListedApp } | Select-Object -ExpandProperty PackageName -First 1

                If ([string]::IsNullOrEmpty($AppProvisioningPackageNameReCheck) -and ($RemoveAppx.Online -eq $true)) {
                    Write-Host @CheckIcon
                    Write-Host " (Removed)"
                    Write-LogEntry -Value "$($RedListedApp) removed"
                }
            }
            catch [System.Exception] {
                Write-Host " (Failed)"
                Write-LogEntry -Value "Failed to remove $($RedListedApp)"
            }
        }
    }

    Write-LogEntry -Value "##################################"
    Write-LogEntry -Stamp -Value "Remove-Appx Started"
    Write-LogEntry -Value "##################################"

    #OS Check
    $OS = (Get-CimInstance -ClassName Win32_OperatingSystem).BuildNumber
    Switch -Wildcard ( $OS ) {
        '2*' {
            $OSVer = "Windows 11"
            Write-Warning "This script is intended for use on Windows 10 devices. $($OSVer) $OS was detected..."
            Write-LogEntry -Value "This script is intended for use on Windows 10 devices. $($OSVer) was detected..."
            Exit 1
        }
        '19*' {
            $OSVer = "Windows 10"
            #Write-Host "$($OSVer) $OS was detected. Continuing with removal"
            Write-LogEntry -Value "$($OSVer) $OS was detected. Continuing with removal"
        }
        '18*' {
            $OSVer = "Legacy Windows 10"
            Write-Warning "$($OSVer) $OS was detected. App list is not accurate for legacy versions"
            Write-LogEntry -Value "$($OSVer) $OS was detected. App list is not accurate for legacy versions"
            Exit 1
        }
    }
    # Red List of Appx Provisioned Packages to Remove for All Users
    $RedListedApps = $null
    $RedListedApps = New-Object -TypeName System.Collections.ArrayList
    $RedListedApps.AddRange(@(
            "Microsoft.GetHelp",
            "Microsoft.Getstarted",
            "Microsoft.Microsoft3DViewer",
            "Microsoft.MicrosoftOfficeHub",
            "Microsoft.MicrosoftSolitaireCollection",
            #"Microsoft.MicrosoftStickyNotes",
            "Microsoft.MixedReality.Portal",
            #"Microsoft.Office.OneNote",
            "Microsoft.People",
            "Microsoft.SkypeApp",
            "Microsoft.Wallet",
            "microsoft.windowscommunicationsapps",
            "Microsoft.WindowsFeedbackHub",
            #"Microsoft.WindowsMaps",
            "Microsoft.XboxApp",
            "Microsoft.Xbox.TCUI",
            "Microsoft.XboxGameOverlay",
            "Microsoft.XboxGamingOverlay",
            "Microsoft.XboxIdentityProvider",
            "Microsoft.XboxSpeechToTextOverlay",
            "Microsoft.YourPhone",
            "Microsoft.ZuneMusic",
            "Microsoft.ZuneVideo" #Last one so no comma
        ))
 
    #Define Icons
    $CheckIcon = @{
        Object          = [Char]8730
        ForegroundColor = 'Green'
        NoNewLine       = $true
    }
 
    #Define App Count
    [int]$AppCount = 0

}

Process {

    If ($($RedListedApps.Count) -ne 0) {

        Write-Output `n"The following $($RedListedApps.Count) apps were targeted for removal from the device:-"
        Write-LogEntry -Value "The following $($RedListedApps.Count) apps were targeted for removal from the device:-"
        Write-LogEntry -Value "Apps marked for removal:$($RedListedApps)"
        Write-Output ""
        $RedListedApps

        #Initialize list for apps not targeted
        $AppNotTargetedList = New-Object -TypeName System.Collections.ArrayList

        # Get Appx Provisioned Packages
        Write-Output `n"Gathering installed Appx Provisioned Packages..."
        Write-LogEntry -Value "Gathering installed Appx Provisioned Packages..."
        Write-Output ""
        $AppArray = Get-AppxProvisionedPackage -Online | Select-Object -ExpandProperty DisplayName

        # Loop through each Provisioned Package
        foreach ($RedListedApp in $RedListedApps) {

            # Function call to Remove Appx Provisioned Packages defined in the Black List
            if (($RedListedApp -in $AppArray)) {
                $AppCount ++
                Try {
                    Remove-AppxProvisionedPackageCustom -RedListedApp $RedListedApp
                }
                Catch {
                    Write-Warning `n"There was an error while attempting to remove $($RedListedApp)"
                    Write-LogEntry -Value "There was an error when attempting to remove $($RedListedApp)"
                }
            }
            else {
                $AppNotTargetedList.AddRange(@($RedListedApp))
            }
        }

        #Update Output Information
        If (!([string]::IsNullOrEmpty($AppNotTargetedList))) { 
            Write-Output `n"The following apps were not removed. Either they were already removed or the Package Name is invalid:-"
            Write-LogEntry -Value "The following apps were not removed. Either they were already removed or the Package Name is invalid:-"
            Write-LogEntry -Value "$($AppNotTargetedList)"
            Write-Output ""
            $AppNotTargetedList
        }
        If ($AppCount -eq 0) {
            Write-Output `n"No apps were removed. Most likely reason is they had been removed previously."
            Write-LogEntry -Value "No apps were removed. Most likely reason is they had been removed previously."
        }
    }
    else {
        Write-Output "No Black List Apps defined in array"
        Write-LogEntry -Value "No Black List Apps defined in array"
    }
}