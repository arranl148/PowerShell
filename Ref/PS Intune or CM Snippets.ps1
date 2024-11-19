


#####
# Firewall
#####

# Example PowerShell script for Intune - Printer sharing
New-NetFirewallRule -DisplayName "Printer Sharing Rule" -Direction Inbound -Protocol TCP -LocalPort 515 -Action Allow
New-NetFirewallRule -DisplayName "SNMP Rule" -Direction Inbound -Protocol UDP -LocalPort 161 -Action Allow
# Add more rules as needed

#####
# ConfigMgr
#####

# Get a list of all available applications
$availableApplications = Get-CMApplication | Where-Object { $_.IsExpired -eq $false }

# Export the list to a CSV file
$availableApplications | Export-Csv -Path "C:\Path\To\Export\AvailableApplications.csv" -NoTypeInformation

##
# Get all active Automated Deployment Rules
$ADRList = Get-CMAutoDeploymentRule | Where-Object { $_.Enabled -eq $true }

# Loop through each ADR and list associated deployments
foreach ($ADR in $ADRList) {
    Write-Host "Automated Deployment Rule: $($ADR.Name)"
    
    # Get deployments associated with the ADR
    $Deployments = Get-CMDeployment | Where-Object { $_.PackageID -eq $ADR.PackageID }

    # Display deployment information
    foreach ($Deployment in $Deployments) {
        Write-Host "  Deployment ID: $($Deployment.PackageID)"
        Write-Host "  Deployment Name: $($Deployment.PackageName)"
        Write-Host "  Deployment Package: $($Deployment.PackageID)"
        Write-Host "  Deployment State: $($Deployment.DeploymentState)"
        Write-Host "  Deployment Time: $($Deployment.PackageTime)"
        Write-Host ""
    }
}

##

# Get all active Automated Deployment Rules
$ADRList = Get-CMAutoDeploymentRule | Where-Object { $_.Enabled -eq $true }

# Loop through each ADR and list associated deployments
foreach ($ADR in $ADRList) {
    Write-Host "Automated Deployment Rule: $($ADR.Name)"
    
    # Get deployments associated with the ADR
    $Deployments = Get-CMDeployment | Where-Object { $_.PackageID -eq $ADR.PackageID }

    # Display deployment information
    foreach ($Deployment in $Deployments) {
        Write-Host "  Deployment ID: $($Deployment.PackageID)"
        Write-Host "  Deployment Name: $($Deployment.PackageName)"
        Write-Host "  Deployment Package: $($Deployment.PackageID)"
        Write-Host "  Deployment State: $($Deployment.DeploymentState)"
        Write-Host "  Deployment Time: $($Deployment.PackageTime)"
        Write-Host ""
    }
}

###########
# Intune

$m = Get-Module -Name Microsoft.Graph.Intune -ListAvailable
if (-not $m)
{
    Install-Module NuGet -Force
    Install-Module Microsoft.Graph.Intune
}
Import-Module Microsoft.Graph.Intune -Global

$serialNumber = "PF16DNHL"
    $device = Get-AutoPilotDevice -serial $serialNumber
    $device.serialNumber

 $IntuneDevice = Get-IntuneManagedDevice | Where-Object serialNumber -eq $serialNumber 
 $IntuneDevice
 