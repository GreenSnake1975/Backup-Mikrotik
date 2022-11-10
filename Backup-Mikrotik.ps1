[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)][string] $sshPwd     = 'P@$$w0rd',
    [Parameter(Mandatory=$false)][string] $sshUser    = 'sshbackuper',
    [Parameter(Mandatory=$true)] [string] $sshPort    = '22',
    [Parameter(Mandatory=$true)] [string] $Address    = '192.168.x.x',
    [Parameter(Mandatory=$true)] [string] $sshHostKey = "e7:89:7d:d5:93:91:9f:ac:3b:02:ef:05:41:86:d3:35",
    [Parameter(Mandatory=$true)] [string] $BakFldr    = 'c:\backup-mt-conf' 
);

$DateTime = get-date -Format 'yyyyMMdd-HHmmss'; 

$PSCP_ARGS = @(
    "-P $($sshPort)", 
    "-l `"$($sshUser)`"",
    "-pw `"$($sshPwd)`"",
    "-hostkey $($sshHostKey)",
    '-batch',
    "$($Address):*.backup",
    $BakFldr
); 
$PLINK_ARGS = @(
    "-P $($sshPort)", 
    "-l `"$($sshUser)`"",
    "-pw `"$($sshPwd)`"",
    '-batch',
    "-hostkey $($sshHostKey)",
    $Address,
    "`"/export terse`""
); 

$pscp_path = 'C:\Program Files\PuTTY\pscp.exe'; 
$plink_path = 'C:\Program Files\PuTTY\plink.exe'; 
# write-host ("{0}\{1}#{2}.rsc" -f $BakFldr, $Address, $DateTime) ; 
$PSCP_ARGS ;
# $PLINK_ARGS ; 
# 1. copy  all .backup from MT 
$RET = (Start-Process -FilePath $pscp_path -ArgumentList $PSCP_ARGS -PassThru -Wait -RedirectStandardError ("{0}\{1}#{2}.pscp.err" -f $BakFldr, $Address, $DateTime)).ExitCode ;
#&'pscp.exe'  -P 60022 -pw P@$$w0rd= -l admin 192.168.122.8:*.backup d:\tmp\20210323\
Write-Host "pscp: $RET" ; 
# 2. copy daily .rsc from MT
#&'plink.exe' -P 60022 -pw 23Vfhnf2021 -batch -l backuper 192.168.122.8 "/export terse"
$RET = (Start-Process -FilePath $plink_path -ArgumentList $PLINK_ARGS -PassThru -Wait -RedirectStandardOutput ("{0}\{1}#{2}.rsc" -f $BakFldr, $Address, $DateTime) -RedirectStandardError ("{0}\{1}#{2}.plink.err" -f $BakFldr, $Address, $DateTime)).ExitCode ; 
Write-Host "plink: $RET" ; 
