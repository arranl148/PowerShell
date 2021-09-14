Get-WindowsImage -ImagePath f:\sources\install.wim
$EnterpriseIndex = Get-WindowsImage -ImagePath f:\sources\install.wim 
Export-WindowsImage -SourceImagePath F:\sources\install.wim -DestinationImagePath C:\Win10-20H2\Windows10-20H2-Enterprise.wim -SourceIndex $EnterpriseIndex