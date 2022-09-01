# Needs errorchecking and tidying
# Enumerate users with profiles and add runonce key
$Users = (Get-ChildItem C:\Users).Name
foreach ($user in $users ) {     
    # $User="PowerONSupportADM"
    if ($user -notin "Public","defaultuser0","Administrator") {
        $ntuser = "C:\users\$User\ntuser.dat"         
        $ntuser         
        #<#   
         $output = reg.exe load HKLM\UserHive $ntuser    
        if ($LastExitCode -ne 0) { write-host "Didn't work, $user may be logged on."         #$output         
            $output = reg.exe unload HKLM\UserHive | Out-Null             
            }        
        $registryPath = "HKLM:\UserHive\Software\Microsoft\Windows\CurrentVersion\RunOnce"        
        $Name = "StartMenuReset"        
        $value = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -executionpolicy bypass C:\ProgramData\featureupdate\StartMenuReset.ps1"   
                <# to run as user ..
                #Reset to default - assumes that you have already customised the start Menu
                Get-AppxPackage microsoft.windows.startmenuexperiencehost | Reset-AppxPackage
                #Cause the start menu to redrawStop-Process -Name StartMenuExperienceHost
                #> 
        IF(!(Test-Path $registryPath))  {        
            New-Item -Path $registryPath -Force | Out-Null        
            New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType String -Force | Out-Null    
            } 
               ELSE {        
             New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType String -Force | Out-Null
             }      
   
    reg.exe unload HKLM\UserHive 
   # #>
    }
}
