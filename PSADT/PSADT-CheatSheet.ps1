##Original Lee Ramsay https://gist.github.com/leeramsay/1579b897c579535880f01a267c41e585#file-psadt-cheatsheet-ps1
#    Deploy-Application.exe -DeploymentType Install -DeployMode Silent
#    Deploy-Application.exe -DeploymentType UnInstall -DeployMode Silent -AllowRebootPassThru
##
## Commonly used PSADT env variables
$envCommonDesktop           # C:\Users\Public\Desktop
$envCommonStartMenuPrograms # C:\ProgramData\Microsoft\Windows\Start Menu\Programs
$envProgramFiles            # C:\Program Files
$envProgramFilesX86         # C:\Program Files (x86)
$envProgramData             # c:\ProgramData
$envUserDesktop             # c:\Users\{user currently logged in}\Desktop
$envUserStartMenuPrograms   # c:\Users\{user currently logged in}\AppData\Roaming\Microsoft\Windows\Start Menu\Programs
$envSystemDrive             # c:
$envWinDir                  # c:\windows

## How to load ("dotsource") PSADT functions/variables for manual testing (your powershell window must be run as administrator first)
cd "$path_to_PSADT_folder_youre_working_from"
. .\AppDeployToolkit\AppDeployToolkitMain.ps1

## *** Examples of exe install***
Execute-Process -Path '<application>.exe' -Parameters '/quiet' -WaitForMsiExec:$true
Execute-Process -Path "$dirFiles\DirectX\DXSetup.exe" -Parameters '/silent' -WindowStyle 'Hidden'
#open notepad, don't wait for it to close before proceeding (i.e. continue with script)
Execute-Process -Path "$envSystemRoot\notepad.exe" -NoWait 
#Execute an .exe, and hide confidential parameters from log file
$serialisation_params = '-batchmode -quit -serial <aa-bb-cc-dd-ee-ffff11111> -username "<serialisation username>" -password "SuperSecret123"'
Execute-Process -Path "$envProgramFiles\Application\Serialise.exe" -Parameters "$serialisation_params" -SecureParameters:$True

##***Example to install an msi***
Execute-MSI -Action 'Install' -Path "$dirFiles\<application>.msi" -Parameters 'REBOOT=ReallySuppress /QN'
Execute-MSI -Action 'Install' -Path 'Discovery 2015.1.msi'
#MSI install + transform file
Execute-MSI -Action 'Install' -Path 'Adobe_Reader_11.0.0_EN.msi' -Transform 'Adobe_Reader_11.0.0_EN_01.mst'

## Install a patch
Execute-MSI -Action 'Patch' -Path 'Adobe_Reader_11.0.3_EN.msp'

## To uninstall an MSI
Execute-MSI -Action Uninstall -Path '{5708517C-59A3-45C6-9727-6C06C8595AFD}'

## Uninstall a number of msi codes
"{2E873893-A883-4C06-8308-7B491D58F3D6}", <# Example #>`
"{2E873893-A883-4C06-8308-7B491D58F3D6}", <# Example #>`
"{2E873893-A883-4C06-8308-7B491D58F3D6}", <# Example #>`
"{2E873893-A883-4C06-8308-7B491D58F3D6}", <# Example #>`
"{2E873893-A883-4C06-8308-7B491D58F3D6}", <# Example #>`
"{B234DC00-1003-47E7-8111-230AA9E6BF10}" <# Last example cannot have a comma after the double quotes #>`
| % { Execute-MSI -Action 'Uninstall' -Path "$_" } <# foreach item, uninstall #>

## ***Run a vbscript***
Execute-Process -Path "cscript.exe" -Parameters "$dirFiles\whatever.vbs"


## Copy a file to the correct relative location for all user accounts
#grabbed from here: http://psappdeploytoolkit.com/forums/topic/copy-file-to-all-users-currently-logged-in-and-for-all-future-users/
$ProfilePaths = Get-UserProfiles | Select-Object -ExpandProperty 'ProfilePath'
ForEach ($Profile in $ProfilePaths) {
    Copy-File -Path "$dirFiles\Example\example.ini" -Destination "$Profile\Example\To\Path\"
}

##***Remove registry key***
#I dont know the right term, but these are to delete the whole 'folder' reg key
Remove-RegistryKey -Key 'HKEY_LOCAL_MACHINE\SOFTWARE\Macromedia\FlashPlayer\SafeVersions' -Recurse
Remove-RegistryKey -Key 'HKLM:SOFTWARE\Macromedia\FlashPlayer\SafeVersions' -Recurse
#This is to remove a specific reg key item from within a 'folder'
Remove-RegistryKey -Key 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -Name 'RunAppInstall'
Remove-RegistryKey -Key 'HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -Name 'RunAppInstall'

## ***Create a reg key***
Set-RegistryKey -Key 'HKEY_LOCAL_MACHINE\SOFTWARE\LMKR\Licensing' -Name 'LMKR_LICENSE_FILE' -Value '@license'-Type String -ContinueOnError:$True

## ***To set an HKCU key for all users including default profile***
[scriptblock]$HKCURegistrySettings = {
    # I included both to illustrate that HKCU\ is an acceptable abbreviation
    Set-RegistryKey -Key 'HKEY_CURRENT_USER\SOFTWARE\Classes\AppX4hxtad77fbk3jkkeerkrm0ze94wjf3s9' -Name 'NoOpenWith' -Value '""'-Type String -ContinueOnError:$True -SID $UserProfile.SID
    Set-RegistryKey -Key 'HKCU\Software\Microsoft\Office\14.0\Common' -Name 'qmenable' -Value 0 -Type DWord -SID $UserProfile.SID
}
Invoke-HKCURegistrySettingsForAllUsers -RegistrySettings $HKCURegistrySettings

#import a .reg key, useful if there's a butt-tonne of nested keys/etc
Execute-Process -FilePath "reg.exe" -Parameters "IMPORT `"$dirFiles\name-of-reg-export.reg`"" -PassThru

## To pause script for <x> time
Start-Sleep -Seconds 120

## ***To copy and overwrite a file***
Copy-File -Path "$dirSupportFiles\mms.cfg" -Destination "C:\Windows\SysWOW64\Macromed\Flash\mms.cfg"

## ***To copy a file***
Copy-File -Path "$dirSupportFiles\mms.cfg" -Destination "C:\Windows\SysWOW64\Macromed\Flash\"

## ***To copy a folder***
# pls note the destination should be the PARENT folder, not the folder name you want it to be. 
# for example, you'd copy "mozilla firefox" to "c:\program files", if you were wanting to copy the application files.
# if copying to root of c:, include trailing slash - i.e. "$envSystemDrive\" not "$envSystemDrive" or "c:"
Copy-File -Path "$dirFiles\client_1" -Destination "C:\oracle\product\11.2.0\" -Recurse

## ***To delete a file or shortcut***
Remove-File -Path "$envCommonDesktop\GeoGraphix Seismic Modeling.lnk"

## Remove a bunch of specific files
"$envCommonDesktop\Example 1.lnk", <# Example #>`
"$envCommonDesktop\Example 2.lnk", <# Example #>`
"$envCommonDesktop\Example 3.lnk" <# Careful with the last item to not include a comma after the double quote #>`
| % { Remove-File -Path "$_" }

## Remove a bunch of specific folders and their contents
"$envSystemDrive\Example Dir1",  <# Example #>`
"$envProgramFiles\Example Dir2",  <# Example #>`
"$envProgramFiles\Example Dir3",  <# Example #>`
"$envProgramFilesX86\Example Dir4",  <# Example #>`
"$envSystemRoot\Example4" <# Careful with the last item to not include a comma after the double quote #>``
| % { Remove-Folder -Path "$_" }

## Remove a bunch of specific folders, only if they're empty
<# Use this by specifying folders from "deepest folder level" to "most shallow folder level" order e.g.
c:\program files\vendor\app\v12\junk - then 
c:\program files\vendor\app\v12 - then
c:\program files\vendor\app - then
c:\program files\vendor
using the above example, it will only remove c:\program files\vendor if every other folder above is completely empty. 
if for example v11 was also installed, it would stop prior #>
(
    "$envProgramFiles\vendor\app\v12\junk",
    "$envProgramFiles\vendor\app\v12",
    "$envProgramFiles\vendor\app",
    "$envProgramFiles\vendor",
    "$envProgramFilesX86\vendor\app\v12\junk",
    "$envProgramFilesX86\vendor\app\v12",
    "$envProgramFilesX86\vendor\app",
    "$envProgramFilesX86\vendor" <# careful not to include the comma after the double quotes in this one #>
) | % { if (!(Test-Path -Path "$_\*")) { Remove-Folder -Path "$_" } }
    # for each piped item, if the folder specified DOES NOT have contents ($folder\*), remove the folder 

## Import a certificate to system 'Trusted Publishers' store.. helpful for clickOnce installers & importing drivers
# (for references sake, I saved as base64, unsure if DER encoded certs work)
Execute-Process -Path "certutil.exe" -Parameters "-f -addstore -enterprise TrustedPublisher `"$dirFiles\certname.cer`""
Write-Log -Message "Imported Cert" -Source $deployAppScriptFriendlyName

## Import a driver (note, >= win7 must be signed, and cert must be in trusted publishers store) 
Execute-Process -Path 'PnPutil.exe' -Parameters "/a `"$dirFiles\USB Drivers\driver.inf`""

## Register a DLL module
Execute-Process -FilePath "regsvr32.exe" -Parameters "/s `"$dirFiles\example\codec.dll`""

## Make an install marker reg key for custom detections
#for e.g. below would create something like:
#HKLM:\SOFTWARE\PSAppDeployToolkit\InstallMarkers\Microsoft_KB2921916_1.0_x64_EN_01
Set-RegistryKey -Key "$configToolkitRegPath\$appDeployToolkitName\InstallMarkers\$installName"


## While loop pause (incase app installer exits immediately)
#pause until example reg key
While(!(test-path -path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{product-code-hereD}")) {
                sleep 5;
                Write-Log -Message "$appVendor - $appName - $appVersion is still not finished installing, sleeping another 5" -Source $deployAppScriptFriendlyName;
}
#pause until example file
While(!(test-path -path "$envCommonDesktop\Example Shortcut.lnk")) {
                sleep 5;
                Write-Log -Message "$appVendor - $appName - $appVersion is still not finished installing, sleeping another 5" -Source $deployAppScriptFriendlyName;
}

##***To Create a shortcut***
New-Shortcut -Path "$envCommonStartMenuPrograms\My Shortcut.lnk" `
    -TargetPath "$envWinDir\system32\notepad.exe" `
    -Arguments "--example-argument --example-argument-two" `
    -Description 'Notepad' `
    -WorkingDirectory "$envHomeDrive\$envHomePath"

## Modify ACL on a file
#first load the ACL
$acl_to_modify = "$envProgramData\Example\File.txt"
$acl = Get-Acl "$acl_to_modify"
#add another entry to the ACL list (in this case, add all users to have full control)
$ar = New-Object System.Security.AccessControl.FileSystemAccessRule("BUILTIN\Users", "FullControl", "None", "None", "Allow")
$acl.SetAccessRule($ar)
#re-write the acl on the target file
Set-Acl "$acl_to_modify" $acl

## Modify ACL on a folder
$folder_to_change = "$envSystemDrive\Example_Folder"
$acl = Get-Acl "$folder_to_change"
$ar = New-Object System.Security.AccessControl.FileSystemAccessRule("BUILTIN\Users", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
$acl.SetAccessRule($ar)
Set-Acl "$folder_to_change" $acl  

## Add to environment variables (specifically PATH in this case)
# The first input in the .NET code can have Path subtituted for any other environemnt variable name (gci env: to see what is presently set)
$path_addition = "C:\bin"
#add $path_addition to permanent system wide path
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";" + $path_addition, "Machine")
#add $path_addition to permanent user specific path
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";" + $path_addition, "User")
#add $path_addition to the process level path only (i.e. when you quit script, it will no longer be applied)
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";" + $path_addition, "Process")


#.NET 4.x comparison/install
$version_we_require = [version]"4.5.2"
$version_we_want_path = "$dirFiles\NDP452-KB2901907-x86-x64-AllOS-ENU.exe"
$install_params = "/q /norestart"
if((Get-RegistryKey "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full" -Value Version) -lt $version_we_require) {
    Write-Log -Source $deployAppScriptFriendlyName -Message ".NET version is < [string]$version_we_require, installing"
    Execute-Process -Path "$version_we_want_path" -Parameters "$install_params" -WaitForMSIExec:$true
}

#exit codes for reboot required
#soft reboot <- will not 'force' restart, and sccm will progress past, but will nag to restart afterward
Exit-Script -ExitCode 3010
#hard reboot <- does not 'force' restart, but sccm won't proceed past any pre-reqs without reboot
Exit-Script -ExitCode 1641

##Create Active Setup to run once per user, and run an arbitrary executable as the user
# *WARNING* this really isn't a recommended method for a number of reasons.
# 1. You must logoff a logged in user for them to run this
# 2. Activesetup is not syncronous and will hold up the user login process until the command completes
# If the executable requests user input you can prevent logins
# 3. It's slow
# You're better off using a scheduled task, or capturing what the executable does and doing it another way

Copy-File -Path "$dirFiles\Example.exe" -Destination "$envProgramData\Example"
Set-ActiveSetup -StubExePath "$envProgramData\Example\Example.exe" `
    -Description 'AutoDesk BIM Glue install' `
    -Key 'Autodesk_BIM_Glue_Install' `
    -ContinueOnError:$true

## Create an activesetup to run once per user, to import a .reg file
# *WARNING* this really isn't a recommended method for a number of reasons.
# 1. You must logoff a logged in user for them to run this
# 2. Activesetup is not syncronous and will hold up the user login process until the command completes
# If the executable requests user input you can prevent logins
# 3. It's slow
# You're better off using a scheduled task, or capturing what the executable does and doing it another way

Copy-File -Path "$dirFiles\many_registry_keys_for_app_x.reg" -Destination "$envProgramData\Hidden\Path"
Set-ActiveSetup -StubExePath "reg.exe IMPORT `"$envProgramData\Hidden\Path\many_registry_keys_for_app_x.reg`"" `
    -Description 'My undesirable way of applying registry keys' `
    -Key 'Undesirable_Reg_keys' `
    -ContinueOnError:$true

## function to assist finding uninstall strings, msi codes, display names of installed applications
# paste into powershell window (or save in (powershell profile)[http://www.howtogeek.com/50236/customizing-your-powershell-profile/]
# usage once loaded: 'Get-Uninstaller chrome'
function Get-Uninstaller {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $Name
  )
 
  $local_key     = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
  $machine_key32 = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
  $machine_key64 = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
 
  $keys = @($local_key, $machine_key32, $machine_key64)
 
  Get-ItemProperty -Path $keys -ErrorAction 'SilentlyContinue' | ?{ ($_.DisplayName -like "*$Name*") -or ($_.PsChildName -like "*$Name*") } | Select-Object PsPath,DisplayVersion,DisplayName,UninstallString,InstallSource,InstallLocation,QuietUninstallString,InstallDate
}
## end of function