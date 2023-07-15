<# 

.DESCRIPTION
 This script can be run as part of a ConfigMgr Task Sequence to make sure
 the computer is connected with an ethernet cable. It then creates the Variable $ContinueTS
 and sets to "True" or "False"

.NOTES
 Created by Kristoffer Henriksson
 Modified by Arran Lamb

#>

$ContinueTS = "True"

$EthernetConnection = Get-NetAdapter -Physical | Where-Object {$_.Name -match "Ethernet" -and $_.Status -eq "Up"}

if ($EthernetConnection -eq $null)
    {
        $TSProgressUI = New-Object -COMObject Microsoft.SMS.TSProgressUI
        $TSProgressUI.CloseProgressDialog()
        [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') | Out-Null
        $OutPut = "OK"

        do {
                $OutPut = [System.Windows.Forms.MessageBox]::Show("Please Connect Ethernet Cable" ,"Network Status" ,1)
                $EthernetConnection = Get-NetAdapter -Physical | Where-Object {$_.Name -eq "Ethernet" -and $_.Status -eq "Up"}

            } while ($EthernetConnection -eq $null -and $OutPut -eq "OK")

        if ($OutPut -eq "Cancel")
            {
                $ContinueTS = "False"
            }
    }

$TSVariable = New-Object -ComObject Microsoft.SMS.TSEnvironment
$TSVariable.Value("ContinueTS") = $ContinueTS

# PreFlight - Network Wired
