  <#
This script will disable automatic updates if it is enabled.
 
  Created:     04.08.2014
  Version:     1.0
  Author:      Odd-Magne Kristoffersen
  Homepage:    https://sccmguru.wordpress.com/
 
  References:
  - Acrobat-Reader Updater: A Configuration and User Guide
    <object data="http://kb2.adobe.com/cps/837/cpsid_83709/attachments/Acrobat_Reader_Updater.pdf" type="application/pdf" width="100%" height="800" style="height: 800px;">
            <p><a href="http://kb2.adobe.com/cps/837/cpsid_83709/attachments/Acrobat_Reader_Updater.pdf">Click to access Acrobat_Reader_Updater.pdf</a></p>
        </object>
#>
 
Get-ChildItem 'HKLM:\SOFTWARE\Policies\Adobe\Acrobat Reader\' | ForEach-Object {Set-ItemProperty "HKLM:$_\FeatureLockDown" -Name bUpdater -Value 0 -Force}
