<#
    .SYNOPSIS
        Remediation script to pull an embedded product key and install and activate it.
   
    .NOTES
        Author: James Robinson | SkipToTheEndpoint | https://skiptotheendpoint.co.uk
        Version: v1
        Release Date: 27/04/24
#>

# License Key Remediation
$Service = Get-CimInstance SoftwareLicensingService
$Product =  Get-CimInstance SoftwareLicensingProduct -Property ID,Name,Description,ProductKeyChannel,LicenseStatus -Filter "Name like 'Windows%' and ProductKeyChannel is not null" | Select-Object ID,Name,Description,ProductKeyChannel,LicenseStatus

# Get embedded product key
$ProductKey = $Service | Select-Object -ExpandProperty OA3xOriginalProductKey
If (!$ProductKey) {
    Write-Host "No embedded product key found!"
    Exit 1
}

Try {
    # Install Key
    $Service | Invoke-CimMethod -MethodName InstallLicense -Arguments @{ ProductKey = $ProductKey }

    # Activate Key
    Get-CimInstance SoftwareLicensingProduct -Filter "ID = '$($Product.ID)'" | Invoke-CimMethod -MethodName Activate | Out-Null
}

Catch {
    Write-Host "Failed to install or activate key"
    Exit 1
}

Finally {
    $Product =  Get-CimInstance SoftwareLicensingProduct -Property ID,Name,Description,ProductKeyChannel,LicenseStatus -Filter "Name like 'Windows%' and ProductKeyChannel is not null" | Select-Object ID,Name,Description,ProductKeyChannel,LicenseStatus

    Write-Host "Name: $($Product.Name) | Channel: $($Product.ProductKeyChannel) | Status: $($Product.LicenseStatus)"
    Exit 0
}