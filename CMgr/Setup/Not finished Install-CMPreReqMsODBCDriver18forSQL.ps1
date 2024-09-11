$TempDownloadPath = "D:\Apps" 
## If not installed "Microsoft ODBC Driver 18 for SQL Server"
## download from  https://go.microsoft.com/fwlink/?linkid=2220989
Start-Process -FilePath .\msiexec.exe -ArgumentList "/i msodbcsql.msi /qb /l*v c:\windows\logs\msodbcsql_install.log IAcceptMSODBCSQLLicenseTerms=YES" -WorkingDirectory $TempDownloadPath