# Latest Microsoft.CompanyPortal_11.2.58
$AllStubPath="HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Applications\Microsoft.CompanyPortal_11.2.58*"
# Check User locations
$UserWildCard="HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\S*\Microsoft.CompanyPortal_11*"

Try {
    If (test-path $AllStubPath) {
	#Company Portal v11.x is installed for All Users
        Write-Host -ForegroundColor Green "Compliant"
        Exit 0
        } 
        Else {
            If (test-path $USerWildCard) {
		    Company Portal v11.x is installed for at least one user
        	$UserCount = (test-path $USerWildCard |Measure).Count
            Write-Host -ForegroundColor Cyan "User Install only - count $UserCount"
        	Exit 2
    		} 
    		Else {
        		Write-Host -ForegroundColor Red "Not Compliant - Device or user"
        		Exit 1
                }
        } 
    }
 
Catch {
    Write-Host -ForegroundColor Red "Not Compliant - Device"
    Exit 1
}