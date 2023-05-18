#Source https://www.winhelponline.com/blog/restore-windows-store-windows-10-uninstall-with-powershell/

$AppxFiles = Get-ChildItem -Filter *.appx -Path "C:\temp\WindowsStore"
ForEach ($app in $AppxFiles){
    Add-AppxPackage -Path $app.FullName
}

po 

$MSIXFiles = Get-ChildItem -Filter *.msixbundle -Path "C:\temp\WindowsStore"
ForEach ($m in $MSIXFiles){
    Add-AppxPackage -Path $m.FullName
}