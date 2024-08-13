## TODO - write a tag in registry or log to say how many times and when it was run.  Historically as a remediation this can hide other issues.
 
#Get services
$global:OriginalServiceStates = Get-Service -DisplayName "Windows Update", "Cryptographic Services", "Background Intelligent Transfer Service", "Windows Installer" | Select-Object -Property Name, Status
$global:OriginalServiceStates
#Stop services
foreach($service in $global:OriginalServiceStates){
    if($service.status -ine "Stopped"){
        Stop-Service $service.name
    }
}

" "
Get-Service -DisplayName "Windows Update", "Cryptographic Services", "Background Intelligent Transfer Service", "Windows Installer" | Select-Object -Property Name, Status
" "

#Remove old Windows update folders
if(Test-Path C:\Windows\SoftwareDistribution.old){
    Remove-Item C:\Windows\SoftwareDistribution.old -Recurse -Force
}
if(Test-Path C:\Windows\Catroot2.old){
    Remove-Item C:\Windows\Catroot2.old -Recurse - Force
}

#Rename Windows update folders
if(Test-Path C:\Windows\SoftwareDistribution) {
    Rename-Item C:\Windows\SoftwareDistribution SoftwareDistribution.old
}
if(Test-Path C:\Windows\Catroot2) {
    Rename-Item C:\Windows\System32\catroot2 Catroot2.old
}

$CurrentServiceState = Get-Service -DisplayName "Windows Update", "Cryptographic Services", "Background Intelligent Transfer Service", "Windows Installer" | Select-Object -Property Name, Status
$PreScriptStatus = $global:OriginalServiceStates
#Restart stopped services

foreach($service in $CurrentServiceState){
        $PreServiceStatus = $PreScriptStatus| Where-Object { $_.Name -ieq $Service.name }
        if ($PreServiceStatus.Status -ne $Service.Status) {
            if($service.Status -eq "Stopped") {
                Start-Service -Name $($PreServiceStatus.name) -ErrorAction Stop
                }
                else {
                Set-Service -Name $($PreServiceStatus.name) -Status $($PreServiceStatus.status) -ErrorAction Stop
                } 
        }
}

Get-Service -DisplayName "Windows Update", "Cryptographic Services", "Background Intelligent Transfer Service", "Windows Installer" | Select-Object -Property Name, Status