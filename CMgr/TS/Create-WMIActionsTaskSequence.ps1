 $ClientActions = @()
 
 #number of seconds the script will sleep before triggering the next action. This gets set on each commandline.
 #Set to 0 to skip sleep.
 $SleepInSeconds = 120
 
 #Comment Out any client actions that you don't want to add to your TS.
 
 #Move actions here that will be added to the Enabled Client Actions group.
$EnabledActions = @()
$EnabledActions += [pscustomobject]@{ ActionName =  'Request Machine Assignments'; ActionID = '{00000000-0000-0000-0000-000000000021}' }
$EnabledActions += [pscustomobject]@{ ActionName =  'Hardware Inventory'; ActionID = '{00000000-0000-0000-0000-000000000001}' }
$EnabledActions += [pscustomobject]@{ ActionName =  'Discovery Inventory'; ActionID = '{00000000-0000-0000-0000-000000000003}' }

#Move actions here that will be added to the Disabled Client Actions group.
#These are simply added to the TS so that they are available if you need them.
#You can comment out the ProcessActions step at the end of the script if you would like to exclude these altogether.
$DisabledActions = @()
$DisabledActions += [pscustomobject]@{ ActionName =  'Software Inventory'; ActionID = '{00000000-0000-0000-0000-000000000002}' }
$DisabledActions += [pscustomobject]@{ ActionName =  'File Collection'; ActionID = '{00000000-0000-0000-0000-000000000010}' }
$DisabledActions += [pscustomobject]@{ ActionName =  'IDMIF Collection'; ActionID = '{00000000-0000-0000-0000-000000000011}' }
$DisabledActions += [pscustomobject]@{ ActionName =  'Client Machine Authentication'; ActionID = '{00000000-0000-0000-0000-000000000012}' }
$DisabledActions += [pscustomobject]@{ ActionName =  'Evaluate Machine Policies'; ActionID = '{00000000-0000-0000-0000-000000000022}' }
$DisabledActions += [pscustomobject]@{ ActionName =  'Refresh Default MP Task'; ActionID = '{00000000-0000-0000-0000-000000000023}' }
$DisabledActions += [pscustomobject]@{ ActionName =  'LS (Location Service) Refresh Locations Task'; ActionID = '{00000000-0000-0000-0000-000000000024}' }
$DisabledActions += [pscustomobject]@{ ActionName =  'LS (Location Service) Timeout Refresh Task'; ActionID = '{00000000-0000-0000-0000-000000000025}' }
$DisabledActions += [pscustomobject]@{ ActionName =  'Policy Agent Request Assignment (User)'; ActionID = '{00000000-0000-0000-0000-000000000026}' }
$DisabledActions += [pscustomobject]@{ ActionName =  'Policy Agent Evaluate Assignment (User)'; ActionID = '{00000000-0000-0000-0000-000000000027}' }
$DisabledActions += [pscustomobject]@{ ActionName =  'Software Metering Generating Usage Report'; ActionID = '{00000000-0000-0000-0000-000000000031}' }
$DisabledActions += [pscustomobject]@{ ActionName =  'Source Update Message'; ActionID = '{00000000-0000-0000-0000-000000000032}' }
$DisabledActions += [pscustomobject]@{ ActionName =  'Clearing proxy settings cache'; ActionID = '{00000000-0000-0000-0000-000000000037}' }
$DisabledActions += [pscustomobject]@{ ActionName =  'Machine Policy Agent Cleanup'; ActionID = '{00000000-0000-0000-0000-000000000040}' }
$DisabledActions += [pscustomobject]@{ ActionName =  'User Policy Agent Cleanup'; ActionID = '{00000000-0000-0000-0000-000000000041}' }
$DisabledActions += [pscustomobject]@{ ActionName =  'Policy Agent Validate Machine Policy / Assignment'; ActionID = '{00000000-0000-0000-0000-000000000042}' }
$DisabledActions += [pscustomobject]@{ ActionName =  'Policy Agent Validate User Policy / Assignment'; ActionID = '{00000000-0000-0000-0000-000000000043}' }
$DisabledActions += [pscustomobject]@{ ActionName =  'Retrying/Refreshing certificates in AD on MP'; ActionID = '{00000000-0000-0000-0000-000000000051}' }
$DisabledActions += [pscustomobject]@{ ActionName =  'Peer DP Status reporting'; ActionID = '{00000000-0000-0000-0000-000000000061}' }
$DisabledActions += [pscustomobject]@{ ActionName =  'Peer DP Pending package check schedule'; ActionID = '{00000000-0000-0000-0000-000000000062}' }
$DisabledActions += [pscustomobject]@{ ActionName =  'SUM Updates install schedule'; ActionID = '{00000000-0000-0000-0000-000000000063}' }
$DisabledActions += [pscustomobject]@{ ActionName =  'NAP action'; ActionID = '{00000000-0000-0000-0000-000000000071}' }
$DisabledActions += [pscustomobject]@{ ActionName =  'Hardware Inventory Collection Cycle'; ActionID = '{00000000-0000-0000-0000-000000000101}' }
$DisabledActions += [pscustomobject]@{ ActionName =  'Software Inventory Collection Cycle'; ActionID = '{00000000-0000-0000-0000-000000000102}' }
$DisabledActions += [pscustomobject]@{ ActionName =  'Discovery Data Collection Cycle'; ActionID = '{00000000-0000-0000-0000-000000000103}' }
$DisabledActions += [pscustomobject]@{ ActionName =  'File Collection Cycle'; ActionID = '{00000000-0000-0000-0000-000000000104}' }
$DisabledActions += [pscustomobject]@{ ActionName =  'IDMIF Collection Cycle'; ActionID = '{00000000-0000-0000-0000-000000000105}' }
$DisabledActions += [pscustomobject]@{ ActionName =  'Software Metering Usage Report Cycle'; ActionID = '{00000000-0000-0000-0000-000000000106}' }
$DisabledActions += [pscustomobject]@{ ActionName =  'Windows Installer Source List Update Cycle'; ActionID = '{00000000-0000-0000-0000-000000000107}' }
$DisabledActions += [pscustomobject]@{ ActionName =  'Software Updates Assignments Evaluation Cycle'; ActionID = '{00000000-0000-0000-0000-000000000108}' }
$DisabledActions += [pscustomobject]@{ ActionName =  'Branch Distribution Point Maintenance Task'; ActionID = '{00000000-0000-0000-0000-000000000109}' }
$DisabledActions += [pscustomobject]@{ ActionName =  'DCM policy'; ActionID = '{00000000-0000-0000-0000-000000000110}' }
$DisabledActions += [pscustomobject]@{ ActionName =  'Send Unsent State Message'; ActionID = '{00000000-0000-0000-0000-000000000111}' }
$DisabledActions += [pscustomobject]@{ ActionName =  'State System policy cache cleanout'; ActionID = '{00000000-0000-0000-0000-000000000112}' }
$DisabledActions += [pscustomobject]@{ ActionName =  'Scan by Update Source'; ActionID = '{00000000-0000-0000-0000-000000000113}' }
$DisabledActions += [pscustomobject]@{ ActionName =  'Update Store Policy'; ActionID = '{00000000-0000-0000-0000-000000000114}' }
$DisabledActions += [pscustomobject]@{ ActionName =  'State system policy bulk send high'; ActionID = '{00000000-0000-0000-0000-000000000115}' }
$DisabledActions += [pscustomobject]@{ ActionName =  'State system policy bulk send low'; ActionID = '{00000000-0000-0000-0000-000000000116}' }
$DisabledActions += [pscustomobject]@{ ActionName =  'AMT Status Check Policy'; ActionID = '{00000000-0000-0000-0000-000000000120}' }
$DisabledActions += [pscustomobject]@{ ActionName =  'Application manager policy action'; ActionID = '{00000000-0000-0000-0000-000000000121}' }
$DisabledActions += [pscustomobject]@{ ActionName =  'Application manager user policy action'; ActionID = '{00000000-0000-0000-0000-000000000122}' }
$DisabledActions += [pscustomobject]@{ ActionName =  'Application manager global evaluation action'; ActionID = '{00000000-0000-0000-0000-000000000123}' }
$DisabledActions += [pscustomobject]@{ ActionName =  'Power management start summarizer'; ActionID = '{00000000-0000-0000-0000-000000000131}' }
$DisabledActions += [pscustomobject]@{ ActionName =  'Endpoint deployment reevaluate'; ActionID = '{00000000-0000-0000-0000-000000000221}' }
$DisabledActions += [pscustomobject]@{ ActionName =  'Endpoint AM policy reevaluate'; ActionID = '{00000000-0000-0000-0000-000000000222}' }
$DisabledActions += [pscustomobject]@{ ActionName =  'External event detection'; ActionID = '{00000000-0000-0000-0000-000000000223}' }

$TS = New-CMTaskSequence -CustomTaskSequence -Name "Run ConfigMgr Client Actions"
 
$EnabledGroup = New-CMTaskSequenceGroup -Name "Enabled Client Actions"
Add-CMTaskSequenceStep -InsertStepStartIndex 0 -TaskSequenceName $TS.Name -Step $EnabledGroup

$DisabledGroup = New-CMTaskSequenceGroup -Name "Disabled Client Actions" -Disable
Add-CMTaskSequenceStep -InsertStepStartIndex 1 -TaskSequenceName $TS.Name -Step $DisabledGroup

Function ProcessActions ($ClientActions, $Group)
{
    Foreach ($Action in $ClientActions)
    {
        #Format the sleep command for appending
        $Sleep = If($SleepInSeconds -gt 0) {";Start-Sleep -seconds $($SleepInSeconds);"} else {$Sleep = ''}

        #Format TS CommandLine
        $cmdLine = [string]::Format("%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -Command `"Invoke-WmiMethod -Namespace root\CCM -Class SMS_Client -Name TriggerSchedule '{0}'{1}`"",$Action.ActionID, $Sleep)
        Write-Host $cmdLine

        #Create TS Step
        $Step = New-CMTaskSequenceStepRunCommandLine -StepName "$($Action.ActionName)" -CommandLine "$($cmdLine)" -ContinueOnError

        #Append Step to group
        Set-CMTaskSequenceGroup -TaskSequenceName $TS.Name -StepName $Group.Name -AddStep $Step
    }
}

ProcessActions $EnabledActions $EnabledGroup
ProcessActions $DisabledActions $DisabledGroup