try{
    $BitlockerVol = Get-BitLockerVolume -MountPoint $env:SystemDrive
    $KPID=""
    foreach($KP in $BitlockerVol.KeyProtector){
        if($KP.KeyProtectorType -eq "RecoveryPassword"){
            $KPID=$KP.KeyProtectorId
            break;
            }
        }
        $output = BackupToAAD-BitLockerKeyProtector -MountPoint "$($env:SystemDrive)" -KeyProtectorId $KPID
        return $true
    }
    catch{
            return $false
    }

# Try https://call4cloud.nl/2021/02/b-for-bitlocker/