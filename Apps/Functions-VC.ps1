# Checks for installed Visual Studio Redistributables
# Requires VcRedist PowerShell Module
# Simplifies command to return $true/$false for specified version 
Function Test-VcRedist {
    [cmdletbinding()]
    Param (
        [Parameter(Position=0,Mandatory=$true)]
        [string]$Release,
        [Parameter(Position=1,Mandatory=$true)]
        [ValidateSet('x86','x64')]
        [string]$Architecture,
        [Parameter(Position=2)]
        [AllowEmptyString()]
        [string]$MinVersion
    )
    #End of parameters
    Process {
        If (-not (Get-Module -Name 'VcRedist')) {retun ('Error: VcRedist Module Not found')}
        #If no MinVersion specified, set minumum to 0.0.0.0
        If (-not ($MinVersion)) {$MinVersion = '0.0.0.0'}
        #If MinVersion is a single integer, append .0.0.0 for SemVer
        If ($MinVesion -match "^\d+$") {$MinVersion = ($MinVersion + '.0.0.0')}
        #Still possible version parsing issues with "x.0"; maybe should just check if valid version and error if not
        If (Get-InstalledVcRedist | Where-Object {$_.Release -match $Release -and $_.Architecture -match $Architecture -and [version]$_.Version -ge [version]$MinVersion}) {
		return ([bool]$true)
		} else {
		return ([bool]$false)
		}
	}
}

# Downloads and installs specified Visual Studio Redistributable
# Requires VcRedist PowerShell Module
# Simplifies the install into one command to align with Test-VcRedist
Function Install-VcRedistByRelease {
    [cmdletbinding()]
    Param (
        [Parameter(Position=0,Mandatory=$true)]
        [string]$Release,
        [Parameter(Position=1,Mandatory=$true)]
        [ValidateSet('x86','x64')]
        [string]$Architecture
    )
    #End of parameters
    Process {
    If (-not (Get-Module -Name 'VcRedist')) { retun ('Error: VcRedist Module Not found') }
    
    $vcRedistReq = (Get-VcList -Release $Release -Architecture $Architecture)
    Write-Log -Message ('Downloading ' + $vcRedistReq)
    Save-VcRedist -Path ($dirSupportFiles) -VcList $vcRedistReq
    Write-Log -Message ('Installing ' + $vcRedistReq)
    Install-VcRedist -Path ($dirSupportFiles) -VcList $vcRedistReq -Silent
	}
}

