# Function for testing internet connectivity
# Uses same parameters as NCSI
Function Test-InternetConnection {
    [cmdletbinding()]
    Param ()
    Process {
        $activeWebProbeHost = ((Get-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet).ActiveWebProbeHost)
        $activeWebProbePath = ((Get-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet).ActiveWebProbePath)
        $activeWebProbeContent = ((Get-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet).ActiveWebProbeContent)
        $activeDnsProbeIpAddress = (((Get-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet).ActiveDnsProbeHost).IPAddress)
        $activeDnsProbeContent = ((Get-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet).ActiveDnsProbeContent)
        $webRequest = (Invoke-Webrequest ('http://'+ $activeWebProbeHost+ '/'+ $activeWebProbePath) -UseBasicParsing)
        If ($webRequest.content -eq $activeWebProbeContent) {
            return ([bool]$true)
        }
        If ($activeDnsProbeIpAddress -and $activeWebProbeContent) {
            If (Resolve-DnsName -Type A -ErrorAction SilentlyContinue $activeDnsProbeIpAddress -eq $activeDnsProbeContent) {
                return ([bool]$true)
            }
        }
        return ([bool]$false)
    }
}

# Function for downloading files from URIs (http,https,ftp,file)
# URIs are tried in order and optionally verified via SHA256 hash
# If no destination is specified, gets the filename and saves to $dirSupportFiles
Function Get-FileFromUri {
    [cmdletbinding()]
    Param (
        [Parameter(Position=0,Mandatory=$true)]
        [string[]]$Uri,
        [Parameter(Position=1,Mandatory=$false)]
        [AllowEmptyString()]
        [string]$Destination,
        [Parameter(Position=2,Mandatory=$false)]
        [AllowEmptyString()]
        [string]$Sha256
    )
    #End of parameters
    Process {
        If (-not ($Destination)) {
			# Get filename from the URI
			$uriFilename = (Split-Path -Path $Uri -Leaf)
			
			# Strip any part of filename after ? (query strings for protected downloads)
			If ($uriFilename -match '\?') {
				$uriFilename = $uriFilename.Substring(0, $uriFilename.IndexOf('?'))    
			}            
            $Destination = ($dirSupportFiles + '\' + $uriFilename)
        }

        If (-not (Split-Path -Path $Destination -IsAbsolute)) {
            throw ('Destination invalid; an abolsute path is required')
        }
        
        # Force TLS1.2 seems to help with some websites
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        # Speeds up Invoke-WebRequest when downloading files
        $ProgressPreference = 'SilentlyContinue'

        $uriCount = 0
        do {
            If (-not ($Uri[$uriCount]) ) {
				Write-Log -Message ('No more URIs to try; cannot download ' + $uriFilename)
				return ($false)
            }
            
            Try {
                Write-Log -Message ('Trying to download from: ' + $Uri[$uriCount])
                $dlStartTime = Get-Date
                $download = Invoke-WebRequest -Uri $Uri[$uriCount] -OutFile $Destination -UseBasicParsing -ErrorAction 'Continue'

                    If ($?) {
                        Write-Log -Message ('Download completed in ' + $((Get-Date).Subtract($dlStartTime).Seconds) + ' second(s)')

                        # Verify SHA256 Hash if provided
                        If ($Sha256) {
                            $DestinationSha256 = (Get-FileHash -Path $Destination -Algorithm 'SHA256')
                            Write-Log -Message ('Checking hash of downloaded file')
                            $hashMatch = ($DestinationSha256.Hash -eq $Sha256)
    
                            If ($hashMatch) {
                                Write-Log -Message ('Downloaded file matached expected hash.')
                                $dlSuccess = $true
                            } else {
                                Write-Log -Message ('Downloaded file did not match expected hash.')
                                Write-Log -Message ('Expected hash was: ' + $Sha256)
                                Write-Log -Message ('Downloaded hash was: ' + $DestinationSha256.Hash)
                                # Delete wrong file to prevent usage of corrupt or malicious file
                                Remove-Item -Path $Destination -Force
                                $dlSuccess = $false
                            }
                        } else {
                            Write-Log -Message ('Download completed successfully. No SHA256 to compare.')
                            $dlSuccess = $true
                        }
                    } else {
                        # This else is redundant?
                        Write-Log -Message ('Error with download.')
                        $dlSuccess = $false
                    }

            } Catch {
                $download = $_.Exception
                Write-Log -Message ($download)
            }

            $uriCount++
        }
        until ($dlSuccess -eq $true) # Download is successful
        return ($dlSuccess)
    }
}