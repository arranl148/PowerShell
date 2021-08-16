# Ken Smith 
# Microsoft Premier Field Engineer (PFE) 
# https://twitter.com/pfeken 
# http://blogs.technet.com/b/kensmith/ 
# 
# 9/2/2015 
# Rev 1.0 
# 
# This script will scan for, and optionally correct, application deployment types that are missing a trailing "\" 
# in the content location path. This will allow for proper migration to 2012 SP2/R2 SP1 without generating a new ContentID 
# 
# Usage: Verify-ContentLocation -SiteCode <SiteCode> -FixMe <$True> (Optional) 
# 
# 
# This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment.  
# THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, 
# INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.  
# We grant You a nonexclusive, royalty-free right to use and modify the Sample Code and to reproduce and distribute the object 
# code form of the Sample Code, provided that You agree: (i) to not use Our name, logo, or trademarks to market Your software 
# product in which the Sample Code is embedded; (ii) to include a valid copyright notice on Your software product in which the 
# Sample Code is embedded; and (iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims 
# or lawsuits, including attorneys’ fees, that arise or result from the use or distribution of the Sample Code. 
Param( 
  [parameter(Mandatory=$True)][string]$SiteCode, 
  [bool]$FixMe 
) 
import-module ($Env:SMS_ADMIN_UI_PATH.Substring(0,$Env:SMS_ADMIN_UI_PATH.Length-5) + '\ConfigurationManager.psd1') 
CD "$($SiteCode):\" 
$LogFile = "$($Env:Temp)\Verify-ContentLocation$(get-date -Format HHmmss).txt" 
Write-Host "Logging to $LogFile" 
Function LogWrite { 
    Param([String]$logstring) 
    Write-Host $logstring 
    Add-Content -Path $LogFile -Value $logstring 
} 
LogWrite "Gathering Applications" 
$apps = Get-CMApplication 
foreach ($app in $apps) 
{ 
 LogWrite "Processing Application $($app.LocalizedDisplayName)" 
    $SDMXML = [XML]$App.SDMPackageXML 
    $DeploymentTypes = $SDMXML.AppMgmtDigest.DeploymentType 
 foreach ($DeploymentType in $DeploymentTypes) 
 { 
        If ($DeploymentType.Technology -eq "Script" -or $DeploymentType.Technology -eq "MSI") { 
            If(-Not $DeploymentType.Installer.Contents.Content.Location.EndsWith("\")){ 
                LogWrite "…found corrupt ContentLocation – $($DeploymentType.Title.InnerText) – $($DeploymentType.Installer.Contents.Content.Location)" 
                If ($fixme){ 
                    LogWrite "……setting Content Location – $($DeploymentType.Installer.Contents.Content.Location)\" 
                    Set-CMDeploymentType -ApplicationName $app.LocalizedDisplayName -DeploymentTypeName $DeploymentType.Title.InnerText -MsiOrScriptInstaller -ContentLocation "$($DeploymentType.Installer.Contents.Content.Location)\" 
                } 
            } 
        } 
 } 
} 