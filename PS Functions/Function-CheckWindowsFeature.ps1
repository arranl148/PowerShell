function Check-WindowsFeature {
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=$true)] [string]$FeatureName 
    )  
  if((Get-WindowsOptionalFeature -FeatureName $FeatureName -Online).State -eq "Enabled") {
        Write-Host -ForegroundColor green "$FeatureName is Installed"
        # (simplified function to paste here)
    } else {
        # Install $FeatureName
	Write-Host -ForegroundColor Yellow "$FeatureName is missing"
    }
  }