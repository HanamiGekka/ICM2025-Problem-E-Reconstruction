param([string]$MatlabExe='matlab',[switch]$Public)
$ErrorActionPreference='Stop'
$taskRoot=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
if(!(Test-Path -LiteralPath $MatlabExe -PathType Leaf)){
 $command=Get-Command $MatlabExe -ErrorAction Stop
 $MatlabExe=$command.Source
}
$runtime=Join-Path $taskRoot '.work\matlab_runtime'
$prefs=Join-Path $taskRoot '.work\matlab_prefs'
New-Item -ItemType Directory -Path $runtime,$prefs -Force | Out-Null
$previousTemp=$env:TEMP; $previousTmp=$env:TMP; $previousPrefs=$env:MATLAB_PREFDIR
try {
 $env:TEMP=$runtime; $env:TMP=$runtime; $env:MATLAB_PREFDIR=$prefs
 $label='full'; if($Public){$label='public'}
 & $MatlabExe -wait -sd $taskRoot -logfile (Join-Path $taskRoot '.work\reconstruction_batch.log') -batch "addpath('tests/matlab','src/matlab'); run_checks('$label'); export_task4('historical_compat'); export_task4('corrected'); export_ca_scenarios; export_historical_comparison; export_full_reconstruction; verify_exports; exit(0)"
 if($LASTEXITCODE -ne 0){throw "MATLAB batch failed: $LASTEXITCODE"}
 Write-Output 'RECONSTRUCTION_BATCH_EXIT0'
} finally {
 $env:TEMP=$previousTemp; $env:TMP=$previousTmp; $env:MATLAB_PREFDIR=$previousPrefs
}
