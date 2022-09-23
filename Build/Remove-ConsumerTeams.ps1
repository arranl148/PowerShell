function Unblock-TeamsRegKey {
    #Adapted from: https://stackoverflow.com/a/35843420
    $rootKey = 'LocalMachine'
    $key = 'SOFTWARE\Microsoft\Windows\CurrentVersion\Communications'
    [System.Security.Principal.SecurityIdentifier]$sid = 'S-1-5-32-544'  #Administrators group SID
    $recurse = $true
            function Unblock-KeyPermissions {
            Param($rootKey, $key, $sid, $recurse, $recurseLevel = 0)
            ### Get ownerships of key
            $regKey = [Microsoft.Win32.Registry]::$rootKey.OpenSubKey($key, 'ReadWriteSubTree', 'TakeOwnership')
            $acl = New-Object System.Security.AccessControl.RegistrySecurity
            $acl.SetOwner($sid)
            $regKey.SetAccessControl($acl)
            ### Enable inheritance of permissions for current key from parent
            $acl.SetAccessRuleProtection($false, $false)
            $regKey.SetAccessControl($acl)
            ### Change permissions for top-level key and propagate it for subkeys
            If ($recurseLevel -eq 0) {
                $regKey = $regKey.OpenSubKey('', 'ReadWriteSubTree', 'ChangePermissions')
                $rule = New-Object System.Security.AccessControl.RegistryAccessRule($sid, 'FullControl', 'ContainerInherit', 'None', 'Allow')
                $acl.ResetAccessRule($rule)
                $regKey.SetAccessControl($acl)
            }
            ### Recurse subkeys
            If ($recurse) {
                ForEach($subKey in $regKey.OpenSubKey('').GetSubKeyNames()) {
                    Take-KeyPermissions $rootKey ($key+'\'+$subKey) $sid $recurse ($recurseLevel+1)
                }
            }
        }
    Unblock-KeyPermissions $rootKey $key $sid $recurse
}
function Remove-ConsumerTeams {
    # Added for permanent removal as noted here: https://oofhours.com/2022/09/08/getting-rid-of-teams-consumer-revisited/
    Unblock-TeamsRegKey
    #Create block for consumer Teams auto-install
    New-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Communications" -Name "ConfigureChatAutoInstall" -Value "0" -PropertyType Dword -Force -ErrorAction Continue
}