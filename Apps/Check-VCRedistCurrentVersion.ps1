# Check VCRedist current version
$OS = if ( ${env:ProgramFiles(x86)} ) {"\WOW6432Node"} else {"\"}
$vcredist = Get-ItemProperty -Path "HKLM:\SOFTWARE$OS\Microsoft\VisualStudio\14.0\VC\Runtimes\x86" -ErrorAction SilentlyContinue -ErrorVariable NoVcRedist86
if ($NoVcRedist86) {
    $Warning += @( "VCRedist x86 not found" )
    ## RunInstall
    }
    elseif (($vcredist86.Bld -le 27820)) {
        # 2015 (Bld = 23026) 2017 (Bld = 26020) 2019 (Bld = 27820)
        $Warning += @( "VCRedist x86 needs updating" )
        ## RunInstall
        }
$vcredist64 = Get-ItemProperty -Path "HKLM:\SOFTWARE$OS\Microsoft\VisualStudio\14.0\VC\Runtimes\x64" -ErrorAction SilentlyContinue -ErrorVariable NoVcRedist64
if ($NoVcRedist64) {
    $Warning += @( "VCRedist x64 not found" )
    ## RunInstall
    }
    elseif (($vcredist64.Bld -le 27820)) {
        # 2015 (Bld = 23026) 2017 (Bld = 26020) 2019 (Bld = 27820)
        $Warning += @( "VCRedist x64 needs updating" )
        ## RunInstall
        }
$Warning