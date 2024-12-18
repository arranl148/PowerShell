Connect-Azuread
Get-AzureADDevice | Where-Object DisplayName -Match $env:COMPUTERNAME | Remove-AzureADDevice