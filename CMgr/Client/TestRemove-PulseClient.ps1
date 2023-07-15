$script:InstallDEBUG = 0
$Script:ProductShortName = "DMS"
$exitresult = 0
#Remove Certs

Function Write-Log
{
	[alias("write-DMSLog")]
	Param
	(
		[Parameter(Mandatory = $true)]
		[String]
		$Message,
		[String]
		$Component="$($Script:ProductShortName)Unknown"
	)

    $WriteLog = "{0} `$$<{1}><{2} {3}><thread={4}>" -f ($message), ($component), (Get-Date -Format "MM-dd-yyyy"), (Get-Date -Format "HH:mm:ss.ffffff"), $pid
    Write-Verbose $WriteLog -Verbose:$true

	If($InstallDEBUG -eq 1)
	{
		$WriteLog | Out-File -Append  "$env:windir\Temp\$($Script:ProductName)Configuration.log" -Encoding ascii
	}
}


#region <Remove Certificate>
Write-DMSLog 'Starting Pulse DMS Cert Removal...' -Component "PulseCertRemoval"
$certs = Get-ChildItem Cert:\LocalMachine\My | Where-Object {$_.Issuer -eq 'CN=PulseIssuingCA, DC=Pulse, DC=PowerONPlatforms, DC=com'}  | Where-Object {$_.Subject -like "*$ENV:COMPUTERNAME*"}

Foreach($cert in $certs)
{
    Write-DMSLog " Removing Certificate: Subject=$($cert.Subject) Thumbprint=$($cert.Thumbprint)" -Component "PulseCertRemoval"
    Remove-Item "$($cert.PSPath)" -Force -Recurse -ErrorAction SilentlyContinue
}

#endregion <Remove Certificate>




#region <Remove Pulse Agent>
Write-DMSLog 'Starting Pulse DMS Agent Removal...' -Component "PulseAgentRemoval"
Write-DMSLog 'Checking Registry for Pulse DMS' -Component "PulseAgentRemoval"
$PulseMSI = Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall | Get-ItemProperty| Where-Object {$_.DisplayName -match 'Pulse DMS' }
If($PulseMSI)
{

	Write-DMSLog "Registry uninstallstring found." -Component "PulseAgentRemoval"
	Write-DMSLog "Product Code: $($PulseMSI.PSChildName)" -Component "PulseAgentRemoval"
	Write-DMSLog "Product Version: $($PulseMSI.Version)" -Component "PulseAgentRemoval"
	Write-DMSLog "Executing Msiexec.exe /X $($PulseMSI.PSChildName) /qn then closing script" -Component "PulseAgentRemoval"
	Start-Process Msiexec.exe -ArgumentList "/X $($PulseMSI.PSChildName) /qn" -NoNewWindow -Wait

}
Else
{

	Write-DMSLog "Unable to find Pulse DMS Registry uninstallstring." -Component "PDMSInstallerS2"
	Write-DMSLog "Product looks to be uninstalled already" -Component "PDMSInstallerS2"


}

Write-DMSLog 'Finished Pulse DMS Agent Removal' -Component "PulseAgentRemoval"
#endregion <Remove Pulse Agent>


#region <Remove CCM Agent>
if(Get-Service -Name ccmExec -ErrorAction SilentlyContinue)
{
    If(Test-Path C:\Windows\ccmsetup\ccmsetup.exe)
    {
	    Write-DMSLog 'Uninstalling existing CCM Client' -Component "PulseCCMRemoval"
        Start-Process C:\Windows\ccmsetup\ccmsetup.exe -ArgumentList @('/Uninstall') -NoNewWindow -Wait
    }
    Else
    {
        Write-DMSLog 'No setup files found for existing CCM Client' -Component "PulseCCMRemoval"

    }

    if(Get-Service -Name ccmExec -ErrorAction SilentlyContinue)
    {
        Write-DMSLog 'ccmExec service found, client may not be able to remove the ccm agent properly' -Component "PulseCCMRemoval"
        [int]$exitresult = '400'

    }
    Else
    {
        Write-DMSLog 'CCM Client has already successfully been removed' -Component "PulseCCMRemoval"

    }
}
Else
{
        Write-DMSLog 'CCM Client has already been removed' -Component "PulseCCMRemoval"

}
	
Write-DMSLog "Removing SMSCFG" -Component "PulseCCMRemoval"
If(Test-Path C:\Windows\SMSCFG.ini) {
	Remove-Item C:\Windows\SMSCFG.ini -Force -Confirm:$false
	}

If(Test-path HKLM:\SOFTWARE\Microsoft\SMS)
{
    Write-DMSLog "Removing SMSCFG" -Component "PulseCCMRemoval"
	Remove-Item HKLM:\SOFTWARE\Microsoft\SMS -Recurse -Force  -ErrorAction SilentlyContinue | Out-Null
}
Else
{
    Write-DMSLog "No Old SMS Reg directory found" -Component "PulseCCMRemoval"		
}

#endregion <Remove CCM Agent>

exit $exitresult