<#
    .SYNOPSIS
        Script to check if the device has virtualization enabled and enable the Windows Sandbox feature.
   
    .NOTES
        Author: James Robinson | SkipToTheEndpoint | https://skiptotheendpoint.co.uk
        Version: v1
        Release Date: 03/09/23
#>
#$FeatureName = "Containers-DisposableClientVM"

function Start-Logging {
    $LogFile = "$($env:ProgramData)\Microsoft\IntuneManagementExtension\Logs\Enable-Sandbox.log"
    
    # Set transcript logging path
    Start-Transcript -Path $LogFile -Append -Verbose
    Write-Host "Current script timestamp: $(Get-Date -f yyyy-MM-dd_HH-mm)"
}

function Test-Virtualization {
    $HV = Get-ComputerInfo | Select-Object HyperVisorPresent
    If ($HV.HyperVisorPresent -eq "True") {
        Write-Host "Hypervisor is enabled"
        $Script:HVEnabled = 1
    }
    Else {
        Write-Host "Hypervisor is not enabled"
        $Script:HVEnabled = 0
    }
}

function Enable-Sandbox {
    Try {
        Write-Host "Hypervisor is enabled, enabling Sandbox"
        Enable-WindowsOptionalFeature -FeatureName $FeatureName -All -Online -NoRestart -Verbose
    }
    Catch {
        Write-Error "$($_.Exception.Message)"
    }
}

Start-Logging

Test-Virtualization

If ($($HVEnabled) -eq 1) {
            Enable-Sandbox
            Write-Host ".. Success" -ForegroundColor Green
            Exit 3010 # Soft Reboot
        } #end if
    } #end if
    Else {
        Write-Host "Hypervisor is not enabled, unable to enable Sandbox"
        Exit 1 # Failure
        } #end elee

Stop-Transcript