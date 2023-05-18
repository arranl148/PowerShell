function Import-SecurityBaselineGPO
<#
## Tweaked to comment out Link line 105 and add URL
.Synopsis
   Import-SecurityBaselineGPO
.DESCRIPTION
   Import-SecurityBaselineGPO
.PARAMETER GPOBackupPath
  The path that constains the Security baselines GPO backup
 
.EXAMPLE
    Import-SecurityBaselineGPO -GPOBackupPath "C:\data\Security Baselines\Microsoft 1903 - September 2019\GPOs" -Verbose 

    The above command imports all Windows 10 1903 baselines

.EXAMPLE
    Import-SecurityBaselineGPO -GPOBackupPath "C:\data\Security Baselines\Microsoft - Office365\GPOs" -Verbose 

    The above command imports all Microsoft Office baselines

.NOTES
    Author: Alex Verboon
    version: 1.0
    Date: 07.10.2019
    URL https://www.verboon.info/2019/10/importing-gpo-security-baselines-with-powershell/
#>
{
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        # MS Security Baseline GPO Backup path
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string]$GPOBackupPath
    )

    Begin
    {
        If (-not(Test-Path -Path $GPOBackupPath))
        {
            Write-Error "Unable to find GPO backup folder: $GPOBackupPath"
            Break
        }

        # Retrieve GPO backup information
        $gpoBackupFiles = Get-ChildItem -Path $gpoBackupPath -Filter "bkupinfo.xml" -Recurse -Attributes Hidden,Normal,System,ReadOnly,Archive

        If ([string]::IsNullOrEmpty($gpoBackupFiles))
        {
                Write-Error "Unable to find GPO backup files (bkupinfo.xml) under folder: $GPOBackupPath"
                Break
        }

        $DomainName = (Get-ADDomain).DistinguishedName

    }
    Process
    {

    $NewGPOObjects = @()
    ForEach ($gpobackupfile in $gpoBackupFiles)
    {
        $bkupInfoFile = "$($gpobackupfile.FullName)"
        [xml]$bkupInfo = @(Get-Content -Path $bkupInfoFile)
        ForEach ($GPO in $bkupInfo.BackupInst)
        {
            $GPOName = $GPO.GPODisplayName.'#cdata-section'
            write-verbose "Processing $GPOName"
            If (Get-GPO -Name "$GPOName" -ErrorAction SilentlyContinue)
            {
                write-warning "GPO Object $GPOName already exists. Delete or rename the existing GPO object first if you want to import a new version"
            }
            Else
            {
                Try{
                    #Write-verbose "Creating GPO Object $GPOName"
                     if ($PSCmdlet.ShouldProcess($DomainName, 'Creating GPO Object.'))
                     {
                        New-GPO "$GPOName" | Out-Null
                        $gpobject = [PSCustomObject] @{
                            GPOName = $GPOName
                        }
                        $NewGPOObjects = $NewGPOObjects + $gpobject
                    }
                  
                }
                Catch{
                      Write-Error "Error creating GPO Object $GPOName"
                }

                Try{
                    #Write-verbose "Importing settings into GPO Object $GPOName"
                    
                     if ($PSCmdlet.ShouldProcess($GPOName, 'Importing settings'))
                     {
                        Import-gpo -Path "$gpoBackupPath" -TargetName "$GPOName" -BackupGpoName "$GPOName" | Out-Null
                        # add a little wait to prevent errors
                        Start-Sleep -Seconds 2
                    }
                }
                Catch{
                    Write-Error "Error importing settings for $GPOName"
                }
            #New-GPLink -Target "OU=Admin,DC=pwsh,DC=ch" -Name "$GPOName" -LinkEnabled Yes
            }
        }
    }
    }
    End
    {
         $NewGPOObjects | Select-Object GPOName
    }
}


