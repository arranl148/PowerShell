$cred = Get-Credential -UserName "<domain>\<you>.admin" #Prompts for a user name and password and stores the result as a System.Security.SecureString object

New-PSDrive -Name "N" -PSProvider FileSystem -Root "\\<Domain FQDN>\pathToSomewhereYouHaveAccessTo\" -Credential $cred

Copy-Item -Path C:\Windows\Logs\CCM\ApplyDriverPackage.log -Destination N:\Windows\Logs\CCM\ApplyDriverPackage
Copy-Item -Path C:\_SMSTaskSequence\Logs\smsts.log -Destination N:\_SMSTaskSequence

