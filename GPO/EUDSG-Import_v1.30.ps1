<#
    .NOTES
        Copyright (c) Microsoft Corporation.  All rights reserved.

        Use of this sample source code is subject to the terms of the Microsoft
        license agreement under which you licensed this sample source code. If
        you did not accept the terms of the license agreement, you are not
        authorized to use this sample source code. For the terms of the license,
        please see the license agreement between you and Microsoft or, if applicable,
        see the LICENSE.RTF on your install media or the root of your tools installation.
        THE SAMPLE SOURCE CODE IS PROVIDED "AS IS", WITH NO WARRANTIES.
       
    .DESCRIPTION 
    v1.30 19 December 2018  - Added -ImportRefs switch to control import (or not) of REF policies.
                            - Added -ImportDeltas switch to control import (or not) of CUSTOMER delta policies.
                            - Added -AppendOUName param to enable import to new sub-OUs (under EUDSG) appended with the string provided to this parameter.

    v1.23 11 September 2018 - Added -CustomerName param to rename the CUSTOMER delta policies with the string provided to this parameter.
                            - Added -VersionToRestore param to restore only policies which have a name that contains the string provided to this parameter.
    
    v1.1 12 June 2017       - Added WMI Filter cpapbility to allow WMI filter to be used in Group Policy Object filtering
    
    V1.0 15 November 2016   - Import OUs, GPOs, link GPOs to OUs and set link order to match settings defined in XML file provided

    .PARAMETER BackupFolder
    Location where the SettingsFile xml and GPOs are located. GPO exports must be located in folder named GPO under the path specified.

    .PARAMETER SettingsFile
    XML file that contains the OU structure and GPO information that is used by the script.

    .PARAMETER VersionToRestore
    String to filter which policies are restored.

    .PARAMETER CustomerName
    String to replace the CUSTOMER placeholder name for the delta GPOs.

    .PARAMETER ImportRefs
    Used to import (if switch is included) or skip import of REF policies.

    .PARAMETER ImportDeltas
    Used to import (if switch is included) or skip import of CUSTOMER delta policies.

    .PARAMETER AppendOUName
    Used to add new sub-OUs (under EUDSG) that have the string provided to this parameter appended to their name.

    .PARAMETER Restore
    Used to indicate that restore process is undertaken.

    .PARAMETER RestoreAll
    Used to indicate that both RestoreOUs and RestorePolcies switches are run.  Still requires the -LinkGPOs switch.

    .PARAMETER RestoreOUs
    Used to restore OU structure that is defined in the SettingsFile.

    .PARAMETER RestoreGPOs
    Used to restore the GPO structure defined the the SettingsFile.  

    .PARAMETER LinkGPOs
    Used to link the GPOs to the OU specified in the SettingsFile, inclcudes the Name of GPO, and link order and whether it is enabled or not.
    
    .PARAMETER OverwriteExistingPolicies
    Used to overwrite existing policies with the imported policies, where the name of the existing policy matches the name of the imported policy.

    .PARAMETER Force
    Used to bypass confirmation prompt asking user whether they would like to run the scipr or not.
    
    .EXAMPLES

        

        .\EUDSG-Import-AD_v1.30.ps1 -BackupFolder "C:\EUDSG" -SettingsFile "EUDSG-W10-1803-2018-12-11-v1.1.2.xml" -ImportRefs -ImportDeltas -AppendOUName 1803 -CustomerName Contoso -RestoreAll -LinkGPOs -Force -OverwriteExistingPolicies

        Specifies that the script should look for GPO folder located under C:\EUDSG and use settings defined in EUDSG-W10-1803-2018-12-11-v1.1.2.xml.  
        The ImportRefs and ImportDeltas switches must be included to import REF and CUSTOMER policies.
        The AppendOUName parameter adds the provided string (will be _1803 in this example) to new sub-OUs under EUDSG - 
        and will create the OUs (EUDSG\Devices_1803 and EUDSG\Users_1803 in this example) if they don't already exist.
        The CustomerName switch renames the CUSTOMER delta policies with the provided string (Contoso in this example).
        The script is running in Restore mode with both OUs and GPOs being restored by using the RestoreAll switch.
        The GPOs will be restored and the GPOs linked to the correct OUs in the defined order.
        The Force switch is used to remove the confirmation check that the user wants to run the script.
        The OverwriteExistingPolicies switch overwrites existing policies with the imported policies, where the name of the existing policy matches the name of the imported policy.


        .\EUDSG-Import-AD_v1.30.ps1 -BackupFolder "C:\EUDSG" -SettingsFile "EUDSG-W10-1803-2018-12-11-v1.1.2.xml" -ImportRefs -ImportDeltas -Restore -RestoreOUs -RestorePolicies -LinkGPOs -Force

        Specifies that the script should look for GPO folder located under C:\EUDSG and use settings defined in EUDSG-W10-1803-2018-12-11-v1.1.2.xml.  
        The ImportRefs and ImportDeltas switches must be included to import REF and CUSTOMER policies.
        The script is running in Restore mode and that both OUs and GPOs will be restored and the GPOs linked to the correct OUs in the defined order.  
        The Force switch is used to remove the confirmation check that the user wants to run the script.


        .\EUDSG-ExportImport-AD_v1.30.ps1 -BackupFolder "C:\EUDSG" -SettingsFile "EUDSG-W10-1803-2018-12-11-v1.1.2.xml" -ImportRefs -ImportDeltas -RestoreAll -LinkGPOs -Force
        
        Specifies that the script should look for GPO folder located under C:\EUDSG and use settings defined in EUDSG-W10-1803-2018-12-11-v1.1.2.xml.  
        The ImportRefs and ImportDeltas switches must be included to import REF and CUSTOMER policies.
        The script is running in Restore mode with both OUs and GPOs being restored by using the RestoreAll switch.  
        The GPOs will be restored and the GPOs linked to the correct OUs in the defined order.  
        The Force switch is used to remove the confirmation check that the user wants to run the script.
#>

[CmdLetBinding(DefaultParameterSetName = "Restore")]
param(

    [Parameter(Mandatory = $true)]
    [string] $BackupFolder,
    [Parameter(Mandatory = $true)]
    [string] $SettingsFile,
    [string] $VersionToRestore,
    [string] $CustomerName,
    [string] $AppendOUName,    
    [switch] $ImportDeltas,
    [switch] $ImportRefs,
    [switch] $Force,

    [Parameter(Mandatory = $false, ParameterSetName = "Restore")]
    [switch] $RestoreAll,
    [switch] $Restore,
    [switch] $RestoreOUs,
    [switch] $RestorePolicies,
    [switch] $OverwriteExistingPolicies,
    [switch] $LinkGPOs,
    [string] $TargetDomain
)

####################################################################
# Functions  
####################################################################
$global:DevicesLinkOrderDelta = 0
$global:UsersLinkOrderDelta = 0
Function Write-Log($Msg, $category) {  
    #       
    #      .DESCRIPTION  
    #          Creates a log entry with time stamp
    #  
    $logfile = ($currentdir + "\log.log")
    $debug = $false
   
    $date = Get-Date -format dd.MM.yyyy  
    $time = Get-Date -format HH:mm:ss  
    Add-Content -Path $LogFile -Value ($date + " " + $time + "   " + $Msg)  
       
    If ($debug -eq $true) {
        $colours = @{"INFO" = "Green"; "Warning" = "Yellow"; "ERROR" = "Red"}       
        Write-host -ForegroundColor $colours[$category] $msg     
    }   
} 

Function Restore-OU($path) {
    #       
    #      DESCRIPTION  
    #      Restore OU configuration
    #  
    $configXML = [xml](Get-content ($SettingsFile))
       
    Foreach ($ou in $configXML.Configuration.OrganizationalUnits.OU) {
        $Error.Clear()
        
        $targetOU = $ou.DistinguishedName, $strDomainDN -join ""
  
        If ($AppendOUName) {
            $targetOU = $targetOU -replace ('OU=Devices', ('OU=Devices_', $AppendOUName -join ""))
            $targetOU = $targetOU -replace ('OU=Users', ('OU=Users_', $AppendOUName -join ""))
        }
        
        #Check the OU exists
        If (!([ADSI]::Exists("LDAP://" + $targetOU))) {            
            Write-Host -ForegroundColor Green ("INFORMATION: Need to create OU " + $targetOU)                
            $newOUName = (($targetOU.Split(","))[0]) -replace ("ou=", "")
            $newOUPath = ($targetOU.substring($targetOU.indexof(",") + 1)) 
                                    
            try {               
                New-ADOrganizationalUnit -name $newOUName -Path $newOUPath -ProtectedFromAccidentalDeletion $false
            }                  
            Catch {       
                Write-Host -ForegroundColor Red ("ERROR: Unable to create the OU " + $targetOU)
                Write-Host -ForegroundColor Red ("ERROR: The error returned is: " + $Error)                                                      
            }

            If (!$Error) {       
                Write-Host -ForegroundColor Green ("INFORMATION: Successfully created OU " + $targetOU) 
            }
        }
        Else {
            Write-Host -ForegroundColor DarkGray ("The target OU " + $targetOU + " already exists. No need to create")
        }

    }
}

Function Restore-WMIFilter {
    Param (
        [Parameter(Mandatory = $false)]
        [String]
        $DestServer,
        [Parameter(Mandatory = $true)]
        [ValidateScript( {Test-Path $_})]
        [String]
        $Path
    )
    if (!$DestServer) {$DestServer = (Get-ADDomainController).HostName}
    $WMIExportFile = Join-Path -Path $Path -ChildPath 'WMIFilters.csv'
    If ((Test-Path $WMIExportFile) -eq $false) {
        Write-Warning "No WMI filters to import."
    }
    Else {
    
        $WMIImport = Import-Csv $WMIExportFile
        $WMIPath = "CN=SOM,CN=WMIPolicy,$((Get-ADDomain -Server $DestServer).SystemsContainer)"

        $ExistingWMIFilters = Get-ADObject -Server $DestServer -SearchBase $WMIPath `
            -Filter {objectClass -eq 'msWMI-Som'} `
            -Properties msWMI-Author, msWMI-Name, msWMI-Parm1, msWMI-Parm2
        If ($VersionToRestore) {
            Write-Host "Only processing WMI filters for version: " $VersionToRestore
            
            ForEach ($WMIFilter in $WMIImport) {
                If ($WMIFilter.'msWMI-Name' -like $VersionToRestore) {
                    Write-Host "Processing WMI filter for verson: " $WMIFilter.'msWMI-Name'
                    If ($ExistingWMIFilters | Where-Object {$_.'msWMI-Name' -eq $WMIFilter.'msWMI-Name'}) {
                        Write-Host "WMI filter already exists: $($WMIFilter."msWMI-Name")"
                    }
                    Else {
                        $msWMICreationDate = (Get-Date).ToUniversalTime().ToString("yyyyMMddhhmmss.ffffff-000")
                        $WMIGUID = "{$([System.Guid]::NewGuid())}"
        
                        $Attr = @{
                            "msWMI-Name"             = $WMIFilter."msWMI-Name";
                            "msWMI-Parm2"            = $WMIFilter."msWMI-Parm2";
                            "msWMI-Author"           = $WMIFilter."msWMI-Author";
                            "msWMI-ID"               = $WMIGUID;
                            "instanceType"           = 4;
                            "showInAdvancedViewOnly" = "TRUE";
                            "msWMI-ChangeDate"       = $msWMICreationDate; 
                            "msWMI-CreationDate"     = $msWMICreationDate
                        }
        
                        # The Description in the GUI (Parm1) may be null. If so, that will botch the New-ADObject.
                        If ($WMIFilter."msWMI-Parm1") {
                            $Attr.Add("msWMI-Parm1", $WMIFilter."msWMI-Parm1")
                        }

                        $ADObject = New-ADObject -Name $WMIGUID -Type "msWMI-Som" -Path $WMIPath -OtherAttributes $Attr -Server $DestServer -PassThru
                        Write-Host "Created WMI filter: $($WMIFilter."msWMI-Name")"
                    }
                }
            }
        }
        Else {
            Write-Host "Processing all WMI Filters"
            ForEach ($WMIFilter in $WMIImport) {

                If ($ExistingWMIFilters | Where-Object {$_.'msWMI-Name' -eq $WMIFilter.'msWMI-Name'}) {
                    Write-Host "WMI filter already exists: $($WMIFilter."msWMI-Name")"
                }
                Else {
                    $msWMICreationDate = (Get-Date).ToUniversalTime().ToString("yyyyMMddhhmmss.ffffff-000")
                    $WMIGUID = "{$([System.Guid]::NewGuid())}"
    
                    $Attr = @{
                        "msWMI-Name"             = $WMIFilter."msWMI-Name";
                        "msWMI-Parm2"            = $WMIFilter."msWMI-Parm2";
                        "msWMI-Author"           = $WMIFilter."msWMI-Author";
                        "msWMI-ID"               = $WMIGUID;
                        "instanceType"           = 4;
                        "showInAdvancedViewOnly" = "TRUE";
                        "msWMI-ChangeDate"       = $msWMICreationDate; 
                        "msWMI-CreationDate"     = $msWMICreationDate
                    }
    
                    # The Description in the GUI (Parm1) may be null. If so, that will botch the New-ADObject.
                    If ($WMIFilter."msWMI-Parm1") {
                        $Attr.Add("msWMI-Parm1", $WMIFilter."msWMI-Parm1")
                    }

                    $ADObject = New-ADObject -Name $WMIGUID -Type "msWMI-Som" -Path $WMIPath -OtherAttributes $Attr -Server $DestServer -PassThru
                    Write-Host "Created WMI filter: $($WMIFilter."msWMI-Name")"
                }
            }
        }
    } # End If No WMI filters
}

Function Set-GPWMIFilterFromBackup {
    Param (
        [Parameter(Mandatory = $false)]
        [String]
        $DestDomain,
        [Parameter(Mandatory = $false)]
        [String]
        $DestServer,
        [Parameter(Mandatory = $true)]
        [ValidateScript( {Test-Path $_})]
        [String]
        $BackupPath
    )
    if (!$DestServer) {$DestServer = (Get-ADDomainController).HostName}
    if (!$DestDomain) {$DestDomain = (Get-ADDomain).DNSRoot}   
    # Get the WMI Filter associated with each GPO backup
    $GPOBackups = Get-ChildItem $BackupPath -Filter "backup.xml" -Recurse

    If ($VersionToRestore) {
        Write-Host "Configure WMI Filter backups for version: " $VersionToRestore
        ForEach ($Backup in $GPOBackups) {

            $GPODisplayName = $WMIFilterName = $null

            [xml]$BackupXML = Get-Content $Backup.FullName
            #$GPODisplayName = $BackupXML.GroupPolicyBackupScheme.GroupPolicyObject.GroupPolicyCoreSettings.DisplayName."#cdata-section"
            $GPODisplayName = $BackupXML.GroupPolicyBackupScheme.GroupPolicyObject.GroupPolicyCoreSettings.DisplayName."#cdata-section" -replace 'CUSTOMER', $CustomerName
            $WMIFilterName = $BackupXML.GroupPolicyBackupScheme.GroupPolicyObject.GroupPolicyCoreSettings.WMIFilterName."#cdata-section"
            If ($GPODisplayName -like $VersionToRestore) {
                If ($WMIFilterName) {
                    "Linking WMI filter '$WMIFilterName' to GPO '$GPODisplayName'."
                    $WMIFilter = Get-ADObject -SearchBase "CN=SOM,CN=WMIPolicy,$((Get-ADDomain -Server $DestServer).SystemsContainer)" `
                        -LDAPFilter "(&(objectClass=msWMI-Som)(msWMI-Name=$WMIFilterName))" `
                        -Server $DestServer
                    If ($WMIFilter) {
                        Set-ADObject -Identity (Get-GPO $GPODisplayName).Path `
                            -Replace @{gPCWQLFilter = "[$DestDomain;$($WMIFilter.Name);0]"} `
                            -Server $DestServer
                    }
                    Else {
                        Write-Warning "WMI filter '$WMIFilterName' NOT FOUND.  Manually create and link the WMI filter."
                    }
                } #Else {
                #"No WMI Filter for GPO '$GPODisplayName'."
                #}
            }
        }
    }
    Else {
        Write-Host "Configure all WMI Filter backups"
        ForEach ($Backup in $GPOBackups) {

            $GPODisplayName = $WMIFilterName = $null

            [xml]$BackupXML = Get-Content $Backup.FullName
            #$GPODisplayName = $BackupXML.GroupPolicyBackupScheme.GroupPolicyObject.GroupPolicyCoreSettings.DisplayName."#cdata-section"
            $GPODisplayName = $BackupXML.GroupPolicyBackupScheme.GroupPolicyObject.GroupPolicyCoreSettings.DisplayName."#cdata-section" -replace 'CUSTOMER', $CustomerName
            $WMIFilterName = $BackupXML.GroupPolicyBackupScheme.GroupPolicyObject.GroupPolicyCoreSettings.WMIFilterName."#cdata-section"

            If ($WMIFilterName) {
                "Linking WMI filter '$WMIFilterName' to GPO '$GPODisplayName'."
                $WMIFilter = Get-ADObject -SearchBase "CN=SOM,CN=WMIPolicy,$((Get-ADDomain -Server $DestServer).SystemsContainer)" `
                    -LDAPFilter "(&(objectClass=msWMI-Som)(msWMI-Name=$WMIFilterName))" `
                    -Server $DestServer
                If ($WMIFilter) {
                    Set-ADObject -Identity (Get-GPO $GPODisplayName).Path `
                        -Replace @{gPCWQLFilter = "[$DestDomain;$($WMIFilter.Name);0]"} `
                        -Server $DestServer
                }
                Else {
                    Write-Warning "WMI filter '$WMIFilterName' NOT FOUND.  Manually create and link the WMI filter."
                }
            } #Else {
            #"No WMI Filter for GPO '$GPODisplayName'."
            #}
        }
    }
}

Function Restore-GroupPolicy($backupID, $path) {
    #       
    #      .DESCRIPTION  
    #         Restore group policies
    #  
    $error.clear()
    $configXML = [xml](Get-Content ($SettingsFile))     
    #$domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().Name
    $gpoPath = Join-Path $path -ChildPath "GPO"
    $manifestPath = Join-Path $gpoPath -ChildPath "manifest.xml"
    $manifestXML = [xml](Get-Content $manifestPath)

    If ($VersionToRestore) {
        Write-Host -ForegroundColor Cyan "INFORMATION: Processing specific policy versions: $VersionToRestore"
        Foreach ($gpoName in $configXML.Configuration.GroupPolicies.Policy) {
            $backupGuid = $manifestXML.Backups.BackupInst | Where-Object {$_.GPODisplayName."#cdata-section" -eq $gpoName.Name}
            If ($CustomerName) {
                $gpoNameFinal = $gpoName.name -replace 'CUSTOMER', $CustomerName
            }
            Else {
                $gpoNameFinal = $gpoName.name
            } 
            If ($gpoNameFinal -like $VersionToRestore) {
                #If the GPO exists and Overwriting is enabled, or the GPO does not exist, import the GPO
                If (((Get-GPO -Name $gpoNameFinal -ErrorAction SilentlyContinue) -and ($OverwriteExistingPolicies -eq $True)) -or (!(Get-GPO -name $gpoNameFinal -ErrorAction SilentlyContinue))) {
                    $error.clear()   
            
                    try {
                        Import-GPO -BackupGpoName ($backupGuid.GPODisplayName."#cdata-section") -TargetName $gpoNameFinal -Path $gpoPath -CreateIfNeeded | Out-Null
                    }
                    Catch {        
                        Write-Host -ForegroundColor Red ("ERROR: Unable to import the policy " + ($gpoNameFinal))
                    }
    
                    If (!$Error) {       
                        Write-Host -ForegroundColor Green ("INFORMATION: Restored the policy " + ($gpoNameFinal))
                        If ($gpoName.Permissions) {
                            #Set permissions if defined
                            Foreach ($group in $gpoName.Permissions) {
                                If ((Get-Group -groupName $group) -eq $True) {
                                    Set-GPOApplyPermissions -groupName $group -name $gpoNameFinal
                                }
                            }
                        }
                     
                    }
                }
                #If the GPO does exist and overwriting is disabled, continue without importing
                ElseIf ((Get-GPO -Name $gpoNameFinal) -and ($OverwriteExistingPolicies -eq $false)) {
                    Write-Host -ForegroundColor DarkGray ("INFORMATION: The Group Policy " + $gpoNameFinal + " already exists and the option to overwrite existing policies has not been specified. The policy will not be imported")
                }
            }
        }
    }
    Else {
        Write-Host -ForegroundColor Cyan "INFORMATION: Processing all policies"
        Foreach ($gpoName in $configXML.Configuration.GroupPolicies.Policy) {
            $backupGuid = $manifestXML.Backups.BackupInst | Where-Object {$_.GPODisplayName."#cdata-section" -eq $gpoName.Name}
            
            If ($CustomerName) {
                $gpoNameFinal = $gpoName.name -replace 'CUSTOMER', $CustomerName
            }
            Else {
                $gpoNameFinal = $gpoName.name
            } 
            #If ImportDeltas switch false, skip import of Customer Delta GPOs for Device policies
            If ((($ImportDeltas -eq $False) -and ($gpoNameFinal -like '*CUSTOMER*(C)*')) -or ((($ImportDeltas -eq $False) -and ($gpoNameFinal -like "*" + $CustomerName + "*(C)*")))) {
                Write-Host "INFORMATION: Skipping Devices Delta policy: $gpoNameFinal"
                $global:DevicesLinkOrderDelta = $global:DevicesLinkOrderDelta + 1
                Continue
            }
            #If ImportRefs switch false, skip import of Reference GPOs for Device policies
            ElseIf (($ImportRefs -eq $False) -and ($gpoNameFinal -like '*REF*(C)*')) {
                Write-Host "INFORMATION: Skipping Devices Reference policy: $gpoNameFinal"
                $global:DevicesLinkOrderDelta = $global:DevicesLinkOrderDelta + 1
                Continue
            }
            #If ImportDeltas switch false, skip import of Customer Delta GPOs for User policies
            ElseIf ((($ImportDeltas -eq $False) -and ($gpoNameFinal -like '*CUSTOMER*(U)*')) -or ((($ImportDeltas -eq $False) -and ($gpoNameFinal -like "*" + $CustomerName + "*(U)*")))) {
                Write-Host "INFORMATION: Skipping Users Delta policy: $gpoNameFinal"
                $global:UsersLinkOrderDelta = $global:UsersLinkOrderDelta + 1
                Continue
            }
            #If ImportRefs switch false, skip import of Reference GPOs for User policies
            ElseIf (($ImportRefs -eq $False) -and ($gpoNameFinal -like '*REF*(U)*')) {
                Write-Host "INFORMATION: Skipping Users Reference policy: $gpoNameFinal"
                $global:UsersLinkOrderDelta = $global:UsersLinkOrderDelta + 1
                Continue
            }
            #If the GPO exists and Overwriting is enabled, or the GPO does not exist, import the GPO
            ElseIf (((Get-GPO -Name $gpoNameFinal -ErrorAction SilentlyContinue) -and ($OverwriteExistingPolicies -eq $True)) -or (!(Get-GPO -name $gpoNameFinal -ErrorAction SilentlyContinue))) {
                $error.clear()   
            
                try {
                    Import-GPO -BackupGpoName ($backupGuid.GPODisplayName."#cdata-section") -TargetName $gpoNameFinal -Path $gpoPath -CreateIfNeeded | Out-Null
                }
                Catch {        
                    Write-Host -ForegroundColor Red ("ERROR: Unable to import the policy " + ($gpoNameFinal))
                }
    
                If (!$Error) {       
                    Write-Host -ForegroundColor Green ("INFORMATION: Restored the policy " + ($gpoNameFinal))
                    If ($gpoName.Permissions) {
                        #Set permissions if defined
                        Foreach ($group in $gpoName.Permissions) {
                            If ((Get-Group -groupName $group) -eq $True) {
                                Set-GPOApplyPermissions -groupName $group -name $gpoNameFinal
                            }
                        }
                    }
                     
                }
            }
            #If the GPO does exist and overwriting is disabled, continue without importing
            ElseIf ((Get-GPO -Name $gpoNameFinal) -and ($OverwriteExistingPolicies -eq $false)) {
                Write-Host -ForegroundColor DarkGray ("INFORMATION: The Group Policy " + $gpoNameFinal + " already exists and the option to overwrite existing policies has not been specified. The policy will not be imported")
            }
        }
    }
    #WMIFilter
    Set-GPWMIFilterFromBackup -BackupPath $gpoPath

}

Function Get-GPOLink ($OU, $GPO) {
    $result = (Get-GPInheritance -Target $OU).GpoLinks.DisplayName

    if ($result -contains $GPO) {
        return $true
    }
    else {
        return $false
    }    
}


Function Link-GroupPolicy($path) {
    #       
    #      .DESCRIPTION  
    #         Restore group policy link configuration
    #  
    $configXML = [xml](Get-Content($SettingsFile))
    Write-Host "INFORMATION: Devices Link Order Delta: $DevicesLinkOrderDelta"
    Write-Host "INFORMATION: Users Link Order Delta: $UsersLinkOrderDelta"
    If ($VersionToRestore) {
        Write-Host "Linking policies restricted to version: " $VersionToRestore
        Foreach ($gpo in $configXML.Configuration.GroupPolicies.Policy) {
            If ($CustomerName) {
                $gpoNameFinal = $gpo.name -replace 'CUSTOMER', $CustomerName
            }
            Else {
                $gpoNameFinal = $gpo.name
            }
            If ($gpoNameFinal -like $VersionToRestore) {
                #First, create the links
                Foreach ($link in $gpo.link) {  
                    $error.Clear()
                    
                    $targetOU = $link.ou, $strDomainDN -join ""
  
                    If ($AppendOUName) {
                        $targetOU = $targetOU -replace ('OU=Devices', ('OU=Devices_', $AppendOUName -join ""))
                        $targetOU = $targetOU -replace ('OU=Users', ('OU=Users_', $AppendOUName -join ""))
                    }            

                    If ($link.Enabled -eq "False") {$linkEnabled = "No"}
                    ElseIf ($link.Enabled -eq "True") {$linkEnabled = "Yes"}
            
                    If (Get-GPOLink $targetOU $gpoNameFinal) {
                        Write-Host -ForegroundColor DarkGray ("INFORMATION: GPO " + $gpoNameFinal + " is already linked to " + $targetOU)
                    }
                    else {        
                        try {           
                            New-GPLink -Name $gpoNameFinal -Target $targetOU -LinkEnabled $linkEnabled -ErrorAction Stop| Out-Null
                        }

                        Catch {       
                            Write-Host -ForegroundColor Red ("ERROR: Unable to create a gplink for policy " + $gpoNameFinal + " to the OU " + $targetOU)
                            If ($error -match "is already linked")
                            {Write-Host -ForegroundColor Red ("ERROR: The policy " + $gpoNameFinal + " is already linked to the OU " + $targetOU)}
                        }
   
                        If (!$Error) {       
                            Write-Host -ForegroundColor Green ("INFORMATION: GPO " + $gpoNameFinal + " has been linked to " + $targetOU)
                        }
                    }
                }
            }  
        }
    
        #Configure the link orders
        foreach ($gpo in $configXML.Configuration.GroupPolicies.Policy) {
            If ($gpo.name -like $VersionToRestore) {
                If ($CustomerName) {
                    $gpoNameFinal = $gpo.name -replace 'CUSTOMER', $CustomerName
                }
                Else {
                    $gpoNameFinal = $gpo.name
                } 
                Foreach ($link in $gpo.link) { 
                    $error.clear()

                    $targetOU = $link.ou, $strDomainDN -join ""
  
                    If ($AppendOUName) {
                        $targetOU = $targetOU -replace ('OU=Devices', ('OU=Devices_', $AppendOUName -join ""))
                        $targetOU = $targetOU -replace ('OU=Users', ('OU=Users_', $AppendOUName -join ""))
                    }
            
                    try {          
                        # Set-GPLink -Name $gpoNameFinal -Target  $targetOU -Order $link.LinkOrder -ErrorAction SilentlyContinue | out-null
                        Set-GPLink -Name $gpoNameFinal -Target  $targetOU -Order $link.LinkOrder | out-null 
                    }
                    Catch {
        
                        Write-Host -ForegroundColor Red ("ERROR: Unable to set the link order for policy " + $gpoNameFinal + " linked to OU " + $targetOU)
                    }
   
                    If (!$Error) {     
                        Write-Host -ForegroundColor Green ("INFORMATION: The link order of " + $link.LinkOrder + " for GPO " + $gpoNameFinal + " that is linked to " + $targetOU + " has been set")
                    }       
                }
            }
        }
    }
    Else {
        Write-Host "Linking all policies"
        Foreach ($gpo in $configXML.Configuration.GroupPolicies.Policy) {
            If ($CustomerName) {
                $gpoNameFinal = $gpo.name -replace 'CUSTOMER', $CustomerName
            }
            Else {
                $gpoNameFinal = $gpo.name
            }

            #If ImportDelta switch false, skip import of Customer Delta GPOs
            If ((($ImportDeltas -eq $False) -and ($gpoNameFinal -like '*CUSTOMER*')) -or ((($ImportDeltas -eq $False) -and ($gpoNameFinal -like "*" + $CustomerName + "*")))) {
                Write-Host "INFORMATION: Skipping Delta policies"
                Continue
            }
            ElseIf (($ImportRefs -eq $False) -and ($gpo.name -like '*REF*')) {
                Write-Host "INFORMATION: Skipping Reference policies"
                Continue
            }
            Else {
                #First, create the links
                Foreach ($link in $gpo.link) {  
                    $error.Clear()

                    $targetOU = $link.ou, $strDomainDN -join ""
    
                    If ($AppendOUName) {
                        $targetOU = $targetOU -replace ('OU=Devices', ('OU=Devices_', $AppendOUName -join ""))
                        $targetOU = $targetOU -replace ('OU=Users', ('OU=Users_', $AppendOUName -join ""))
                    }

                    If ($link.Enabled -eq "False") {$linkEnabled = "No"}
                    ElseIf ($link.Enabled -eq "True") {$linkEnabled = "Yes"}
                
                    if (Get-GPOLink $targetOU $gpoNameFinal) {
                        Write-Host -ForegroundColor DarkGray ("INFORMATION: GPO " + $gpoNameFinal + " is already linked to " + $targetOU)
                    }
                    else {        
                        try {           
                            New-GPLink -Name $gpoNameFinal -Target $targetOU -LinkEnabled $linkEnabled -ErrorAction Stop| Out-Null
                        }

                        Catch {       
                            Write-Host -ForegroundColor Red ("ERROR: Unable to create a gplink for policy " + $gpoNameFinal + " to the OU " + $targetOU)
                            If ($error -match "is already linked")
                            {Write-Host -ForegroundColor Red ("ERROR: The policy " + $gpoNameFinal + " is already linked to the OU " + $targetOU)}
                        }
    
                        If (!$Error) {       
                            Write-Host -ForegroundColor Green ("INFORMATION: GPO " + $gpoNameFinal + " has been linked to " + $targetOU)
                        }
                    }
                }
            }
        }

        $i = 0
        $DevicesGPOLinkOrder = @()
        foreach ($gpo in $configXML.Configuration.GroupPolicies.Policy) {      
            $gpObj = New-Object PSObject

            If ((($ImportDeltas -eq $False) -and ($gpo.name -like '*CUSTOMER*(C)*')) -or ((($ImportDeltas -eq $False) -and ($gpo.name -like "*" + $CustomerName + "*(C)*")))) {
                Continue
            }
            ElseIf (($ImportRefs -eq $False) -and ($gpo.name -like '*REF*(C)*')) {
                Continue
            }
            ElseIf ($gpo.name -like '*(U)*') {
                Continue   
            }
            Else {
                $i += 1
                If ($CustomerName) {
                    $gpObj | Add-Member NoteProperty GPOName ($gpo.Name -replace 'CUSTOMER', $CustomerName)
                }
                Else {
                    $gpObj | Add-Member NoteProperty GPOName $gpo.Name
                }                
                Foreach ($link in $gpo.link) { 
                    If ($AppendOUName) {
                        $TargetOU = ($link.ou -replace ('OU=Devices', ('OU=Devices_', $AppendOUName -join ""))), $strDomainDN -join ""
                        $gpObj | Add-Member NoteProperty TargetOU $TargetOU
                    }
                    Else {
                        $TargetOU = $link.ou, $strDomainDN -join ""
                        $gpObj | Add-Member NoteProperty TargetOU $TargetOU
                    }
                }
                $gpObj | Add-Member NoteProperty LinkOrder $i
            }
            $DevicesGPOLinkOrder += $gpObj
        }

        $i = 0
        $UsersGPOLinkOrder = @()
        foreach ($gpo in $configXML.Configuration.GroupPolicies.Policy) {
            $gpObj = New-Object PSObject

            If ((($ImportDeltas -eq $False) -and ($gpo.name -like '*CUSTOMER*(U)*')) -or ((($ImportDeltas -eq $False) -and ($gpo.name -like "*" + $CustomerName + "*(U)*")))) {
                Continue
            }
            ElseIf (($ImportRefs -eq $False) -and ($gpo.name -like '*REF*(U)*')) {
                Continue
            }
            ElseIf ($gpo.name -like '*(C)*') {
                Continue   
            }
            Else {
                $i += 1
                If ($CustomerName) {
                    $gpObj | Add-Member NoteProperty GPOName ($gpo.Name -replace 'CUSTOMER', $CustomerName)
                }
                Else {
                    $gpObj | Add-Member NoteProperty GPOName $gpo.Name
                }
                Foreach ($link in $gpo.link) {
                    If ($AppendOUName) {
                        $TargetOU = ($link.ou -replace ('OU=Users', ('OU=Users_', $AppendOUName -join ""))), $strDomainDN -join ""
                        $gpObj | Add-Member NoteProperty TargetOU $TargetOU
                    }
                    Else {
                        $TargetOU = $link.ou, $strDomainDN -join ""
                        $gpObj | Add-Member NoteProperty TargetOU $TargetOU
                    }
                }
                $gpObj | Add-Member NoteProperty LinkOrder $i
            }
            $UsersGPOLinkOrder += $gpObj
        }

        #Write-Host "INFORMATION: Devices GPO Link Orders"
        # $DevicesGPOLinkOrder | Format-Table
        #$DevicesGPOLinkOrder

        #Write-Host "INFORMATION: Users GPO Link Orders"
        # $UsersGPOLinkOrder | Format-Table
        #$UsersGPOLinkOrder
        
        # Write-Host "Devices"
        foreach ($gpoEntry in $DevicesGPOLinkOrder) {
            # Write-Host "Name:" $gpoEntry.GPOName
            # Write-Host "TargetOU:" $gpoEntry.TargetOU
            # Write-Host "LinkOrder:" $gpoEntry.LinkOrder
            $error.clear()
            # Write-Host "Linking - Name:" $gpoEntry.GPOName "TargetOU:" $gpoEntry.TargetOU "LinkOrder:" $gpoEntry.LinkOrder
            try {          
                Set-GPLink -Name $gpoEntry.GPOName -Target $gpoEntry.TargetOU -Order $gpoEntry.LinkOrder | out-null            
            }
            Catch {
                Write-Host -ForegroundColor Red ("ERROR: Unable to set the link order for policy: " + $gpoEntry.GPOName + " linked to OU: " + $gpoEntry.TargetOU)
            }

            If (!$Error) {     
                Write-Host -ForegroundColor Green ("INFORMATION: The link order of " + $gpoEntry.LinkOrder + " for GPO: " + $gpoEntry.GPOName + " that is linked to " + $gpoEntry.TargetOU + " has been set")
            }
        }
        
        # Write-Host "Users"
        foreach ($gpoEntry in $UsersGPOLinkOrder) {
            # Write-Host "Name:" $gpoEntry.GPOName
            # Write-Host "TargetOU:" $gpoEntry.TargetOU
            # Write-Host "LinkOrder:" $gpoEntry.LinkOrder
            $error.clear()
            # Write-Host "Linking - Name:" $gpoEntry.GPOName "TargetOU:" $gpoEntry.TargetOU "LinkOrder:" $gpoEntry.LinkOrder
            try {          
                Set-GPLink -Name $gpoEntry.GPOName -Target $gpoEntry.TargetOU -Order $gpoEntry.LinkOrder | out-null            
            }
            Catch {
                Write-Host -ForegroundColor Red ("ERROR: Unable to set the link order for policy: " + $gpoEntry.GPOName + " linked to OU: " + $gpoEntry.TargetOU)
            }

            If (!$Error) {     
                Write-Host -ForegroundColor Green ("INFORMATION: The link order of " + $gpoEntry.LinkOrder + " for GPO: " + $gpoEntry.GPOName + " that is linked to " + $gpoEntry.TargetOU + " has been set")
            }
        }
    }
}

Function Get-OU($strOU) {
    #       
    #      .DESCRIPTION  
    #         Query OU configuration
    #  
    $error.clear()
    try {
        $OUObject = Get-ADOrganizationalUnit $strOU
    }
    Catch {     
        Write-Host -ForegroundColor Red ("ERROR: Unable to locate the OU " + $strOU + "in Active Directory.")
        return $false
    }

    If (!$Error) {      
        return $OUObject
    }
}
     
Function LoadModule([string]$name) { 
    #       
    #      .DESCRIPTION  
    #         Load the specified PowerShell module
    #  
    If (Get-Module -ListAvailable | Where-Object { $_.name -eq $name }) { 
        Import-Module -Name $name 
        return $true
    } #end if module available then import 
    else { 
        return $false 
    } #module not available
     
} # end if not module 

Function Main {
    #       
    #      .DESCRIPTION  
    #          Main processing function
    #  
    #Load Active Directory Module
    If ((LoadModule -name ActiveDirectory) -eq $True) {
        Write-Host -ForegroundColor Green "Loaded Active Directory Module"
    }
    Else {
        Write-Host -ForegroundColor Red "Failed to load Active Directory Module"   
    }

    #Load Group Policy Module
    IF ((LoadModule -name GroupPolicy) -eq $True) {
        Write-Host -ForegroundColor Green "Loaded Group Policy Module"
    }
    Else {
        Write-Host -ForegroundColor Red "Failed to load Group Policy Module"
    }
   

    If ($Restore) {    
        $gpoFolder = $BackupFolder  
        #$configXML = [xml](Get-content ($SettingsFile))  
                
        If ($restoreOUs -eq $True) {
            #Restore Ous
            Write-Host -ForegroundColor DarkGray "INFORMATION: Restoring Organisational Units..."
            Restore-OU -path $gpoFolder
        }
      

        #Import the Group Policies from the XML file       
        If ($restorePolicies -eq $true) {      
            Write-Host -ForegroundColor DarkGray "INFORMATION: Restoring Group Policies..."
            Restore-WMIFilter -Path (Join-Path $gpoFolder "GPO")
            Restore-GroupPolicy -path $gpoFolder

            #Configure the Group Policy links and ordering
            if ($LinkGPOs) {
                Write-Host -ForegroundColor DarkGray "INFORMATION: Linking Group Policies to Organisational Units..."     
                Link-GroupPolicy -path $gpoFolder
            }
            else {
                Write-Host -ForegroundColor DarkGray "INFORMATION: Group Policies NOT linked to Organisational Units..."            
            }
        }    
                             
    }   
}

#Test the presence of valid Configuration
Function CheckConfig {
}     
if ($RestoreAll) {
    $Restore = $true
    $RestoreOUs = $true
    $RestorePolicies = $true
}

if ($RestoreOUs -or $RestorePolicies) {
    $Restore = $true
}

if ($Backup -and $Restore) {
    Write-Host -ForegroundColor Red "ERROR: You cannot backup and restore at the same time. Exiting..."
    Exit
}

if ($Restore) {
    If ($VersionToRestore) {
        Write-Host -ForegroundColor Cyan "INFORMATION: Restoring Policies for: $VersionToRestore"
        $VersionToRestore = "*" + $VersionToRestore + "*"
        Write-Host -ForegroundColor Cyan "INFORMATION: Modified version search string: $VersionToRestore"
    }
    Else {
        Write-Host -ForegroundColor Cyan "INFORMATION: Restoring All Policies"
    }

    If ($CustomerName) {
        Write-Host -ForegroundColor Cyan "INFORMATION: Renaming Delta Policies for: $CustomerName"   
    }

    If ($AppendOUName) {
        Write-Host -ForegroundColor Cyan "INFORMATION: Appending string to OU names: $AppendOUName"   
    }

    If ($ImportDeltas) {
        Write-Host -ForegroundColor Cyan "INFORMATION: Importing Customer Delta Policies"   
    }

    If ($ImportRefs) {
        Write-Host -ForegroundColor Cyan "INFORMATION: Importing Reference Policies"   
    }
    #break
    If (!(Test-Path $BackupFolder -ErrorAction SilentlyContinue)) {   
        Write-Host -ForegroundColor Red "ERROR: The backup folder path specified is invalid. The path cannot be found or has not been specified"
        Exit
    }
    Else {
        $gpoFolder = $BackupFolder
    }

    If (!(Test-Path $SettingsFile -ErrorAction SilentlyContinue)) {   
        $SettingsFile = Join-Path $BackupFolder -ChildPath $SettingsFile

        If (!(Test-Path $SettingsFile -ErrorAction SilentlyContinue)) { 
            Write-Host -ForegroundColor Red "ERROR: The setting file path specified is invalid. The path cannot be found or has not been specified"
            Exit
        }
        else {$SettingsFile = $SettingsFile}
    }
    else {$SettingsFile = $SettingsFile}
   
    If (!($RestoreOUs -eq $true -or $RestoreOUs -eq $false)) { 
        Write-Host -ForegroundColor Red "ERROR: The RestoreOUs configuration contains an invalid value"
        Exit
    }
    Else {
        If ($RestoreOUs) { $restoreOUs = $true }
        Else {$restoreOUs = $false}
    }

    If (!($RestorePolicies -eq $true -or $RestorePolicies -eq $false)) { 
        Write-Host -ForegroundColor Red "ERROR: The RestorePolicies configuration contains an invalid value"
        Exit
    }
    Else {
        If ($RestorePolicies) { $restorePolicies = $true }
        Else {$restorePolicies = $false}
    }
    If (!($OverwriteExistingPolicies -eq $true -or $OverwriteExistingPolicies -eq $false) ) { 
        Write-Host -ForegroundColor Red "ERROR: The OverwriteExistingPolicies configuration contains an invalid value"
        Exit
    } 
    Else {
        If ($OverwriteExistingPolicies) { $overwriteExisting = $true }
        Else {$overwriteExisting = $false}
    }
    $domain = Get-ADDomain 
    $Script:strDomainDN = $domain.DistinguishedName
    Write-Host -ForegroundColor Cyan "INFORMATION: Configuration Validation:"
    Write-Host -ForegroundColor Cyan ("Settings File Path: " + $SettingsFile)
    Write-Host -ForegroundColor Cyan ("Backup Folder Path: " + $BackupFolder)
    
    if ($Restore) {
        Write-Host -ForegroundColor Cyan ("Restore OUs: " + $RestoreOUs)
        Write-Host -ForegroundColor Cyan ("Restore Policies: " + $RestorePolicies)
        Write-Host -ForegroundColor Cyan ("Overwrite Existing Policies: " + $OverwriteExistingPolicies)
        Write-Host -ForegroundColor Cyan ("Restore GPO Links: " + $LinkGPOs)
        Write-Host -ForegroundColor Cyan ("Target Domain: " + $strDomainDN)
    } 

    if ($Force) {
        Main
    }
    else {
        $prompt = Read-Host "Do you want to continue with the above settings? [Y/N]"

        if ($prompt.ToLower() -eq "y") {
            $currentDir = (Get-Item -Path ".\" -Verbose).FullName
            Main
            Set-location $currentDir
        }
        else {
            Write-Host -ForegroundColor Cyan ("Exiting")
        }
    }
}
####################################################################
# End Functions  
####################################################################
$currentdir = Split-path -parent $MyInvocation.MyCommand.Definition
CheckConfig