$Path = "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate"
$Name = "DoNotConnectToWindowsUpdateInternetLocations"
$Type = "DWORD"
$Value = '0'

Try {
    $Registry = Get-ItemProperty -Path $Path -Name $Name -ErrorAction Stop | Select-Object -ExpandProperty $Name
    If ($Registry -eq $Value){
        Write-Host -ForegroundColor Cyan "Compliant"
        Exit 0
    } 
    Else {
        Write-Host -ForegroundColor Red "Not Compliant"
        Exit 1
    }
} 
Catch {
    Write-Host -ForegroundColor Red "Not Compliant"
    Exit 1
}