Param (
    [Parameter(Mandatory=$True)]
    [string]$FriendlyName,
    [Parameter(Mandatory=$false)]
    [string]$Subject,
    [Parameter(Mandatory=$True)]
    [string]$Password,
    [Parameter(Mandatory=$false)]
    [int]$LengthInYears = 5,
    [Parameter(Mandatory=$false)]
    [string]$HashAlgorithm = "sha256",
    [Parameter(Mandatory=$false)]
    [int]$KeyLength = 2048
    )

If (!(Get-Module PKI)) {Import-Module PKI -ErrorAction Stop}

$SecurePassword = (ConvertTo-SecureString -String $Password -Force –AsPlainText)
IF ([string]::IsNullOrEmpty($Subject)) {
    $Subject = "CN="+($FriendlyName).Replace(" ","-")
    }
If ($Subject -notlike "CN=*") {
    $Subject = "CN="+$Subject
    }

Try {
    Write-Output "`nCreating new self signed certificate..."
    Write-Output "Subject: $Subject"
    Write-Output "FriendlyName: $FriendlyName"
    Write-Output "Cert expires on $((Get-Date).AddYears($LengthInYears))"

    New-SelfSignedCertificate -Subject $Subject -FriendlyName $FriendlyName -CertStoreLocation "Cert:\LocalMachine\My" -Provider "Microsoft Strong Cryptographic Provider" -NotAfter (Get-Date).AddYears($LengthInYears) -KeyExportPolicy Exportable -HashAlgorithm $HashAlgorithm -KeyLength $KeyLength

    Write-Output "`nExporting PFX Certificate"
    Write-Output "Location: $env:TEMP\$FriendlyName`.pfx"
    Export-PfxCertificate -Cert (Get-ChildItem Cert:\LocalMachine\My\ | Where-Object Subject -eq $Subject) -FilePath $env:TEMP\$FriendlyName`.pfx -Password $SecurePassword | Out-Null

    Write-Output "`nExporting CER Certificate"
    Write-Output "Location: $env:TEMP\$FriendlyName`.cer"
    Export-Certificate -Cert (Get-ChildItem Cert:\LocalMachine\My\ | Where-Object Subject -eq $Subject) -FilePath $env:TEMP\$FriendlyName`.cer | Out-Null

    Write-Output "`nFinished!"
    }
Catch {
    Write-Error "Something went wrong creating the certificate."
    }