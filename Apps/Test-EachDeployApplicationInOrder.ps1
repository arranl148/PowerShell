$AppsPath = "D:\Apps\Packages\Customer"

$AppFolders = GCI -Path $AppsPath | Select-Object -ExpandProperty FullName

Foreach ($Folder in $AppFolders) {
    $Params = @{
        ArgumentList = "-Deploymenttype Install -Deploymode Silent"
        FilePath = "(Join-Path -Path $Folder -ChildPath Deploy-application.exe)"
        wait = $true
    }
    "Installing $Folder"
    Start-Process @Params
    }