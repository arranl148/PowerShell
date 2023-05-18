# Original from NickolajA v1.0.0
# From https://github.com/MSEndpointMgr/Intune/blob/master/Security/Get-BitLockerEncryptionDetection.ps1
#
$BitLockerOSVolume = Get-BitLockerVolume -MountPoint $env:SystemRoot
if (($BitLockerOSVolume.VolumeStatus -like "FullyEncrypted") -and ($BitLockerOSVolume.KeyProtector.Count -eq 2)) {
    return 0
}