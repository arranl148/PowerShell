<#
    .SYNOPSIS
        Detection script to check a physical device has an activated OEM or Retail Windows product key.
   
    .NOTES
        Author: James Robinson | SkipToTheEndpoint | https://skiptotheendpoint.co.uk
        Version: v1
        Release Date: 27/04/24
#>

# Virtual Machine Check - Fails if reports as a VM via Hyper-V, VMware, etc. or Windows 365 Cloud PC
$VMCheck = Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -ExpandProperty Model
If ($VMCheck -like '*Virtual*'){
    Write-Host "Virtual Machine Detected"
    Exit 0
}

$Product =  Get-CimInstance SoftwareLicensingProduct -Property ID,Name,Description,ProductKeyChannel,LicenseStatus -Filter "Name like 'Windows%' and ProductKeyChannel is not null" | Select-Object ID,Name,Description,ProductKeyChannel,LicenseStatus

If (($Product.ProductKeyChannel -eq 'Retail' -or 'OEM_DM') -and $Product.LicenseStatus -eq 1){
    Write-Host "Retail or OEM key found and license activated"
    Exit 0
}
Else {
    Write-Host "Name: $($Product.Name) | Channel: $($Product.ProductKeyChannel) | Status: $($Product.LicenseStatus) - Remediating"
    Exit 1
}