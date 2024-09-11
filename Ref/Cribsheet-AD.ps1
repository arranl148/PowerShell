#Break terminates execution of a loop or switch statement and hands over control to next statement after it. 
#Return terminates execution of the current function and passes control to the statement immediately after the function call. 
#Exit terminates the current execution session altogether.

Write-Host "Cheat sheet - Exiting"
Start-Wait 60 
Exit

##### AD ######

# ReJoin to AD
$Credential=Get-Credential

#Enter domain admin account and pwd
Reset-ComputerMachinePassword -Credential $Credential

Or 

Test-ComputerSecureChannel -Repair -Credential (Get-Credential)

##
