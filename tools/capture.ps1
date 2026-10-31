param([ValidateSet('minimal_camp','clarity_crew','clarity_travel','clarity_gather','clarity_symbols','clarity_symbols_crew','clarity_symbols_road','exhausted_encounter','closure_arrival','aims_departure','aims_fresh','aims_progress','aims_result','aims_complete','aims_legacy','options','options_brisk','combat_setup','combat_ready','guardian_setup','guardian_warning','guardian_rush','guardian_tired_result','legacy_guardian_setup','developer','route_depot','route_meadow','route_woodland','items_prep','items_shop','items_depot','items_equipped','items_battle','items_locked','items_crew','route_oak','report_equipment','report_rain','chain_tree','chain_thanks','chain_axle','chain_failure','chain_repair','route_outpost','route_river','route_gate','route_ridge','route_gorge','route_reach','route_map','route_rain')][string[]]$Scenes=@('options','combat_setup'))
. (Join-Path $PSScriptRoot 'common.ps1')
$captureClock = [Diagnostics.Stopwatch]::StartNew()
Initialize-TrailomonTools
$captureProject = Join-Path $TrailomonTools 'capture-project'
$captureOutput = New-TrailomonOutput -Parent '.tools' -Prefix 'captures'
Push-Location $TrailomonRoot
try {
    & python tools/capture_prepare.py
    if ($LASTEXITCODE -ne 0) { throw 'Could not prepare the isolated capture project.' }
} finally { Pop-Location }
Push-Location $captureProject
try {
    Invoke-TrailomonBob -BuildArguments @('--settings','tests/screenshots.project','--archive','--platform','x86_64-win32','--variant','release','--bundle-output',$captureOutput,'resolve','build','bundle')
    $application = Join-Path $captureOutput 'Trailomon Capture'
    $captureArgs = @('--config=engine.run_while_iconified=1', ('--config=trailomon.capture_cases='+($Scenes -join ',')))
    $capture = Start-Process -FilePath (Join-Path $application 'TrailomonCapture.exe') -WorkingDirectory $application -ArgumentList $captureArgs -WindowStyle Hidden -RedirectStandardOutput (Join-Path $application 'stdout.txt') -RedirectStandardError (Join-Path $application 'stderr.txt') -PassThru
    if (-not $capture.WaitForExit(20000)) { Stop-Process -Id $capture.Id; throw 'Capture timed out; see its stdout/stderr.' }
    if (-not (Test-Path -LiteralPath (Join-Path $application 'capture-result.json'))) { Get-Content (Join-Path $application 'stdout.txt'),(Join-Path $application 'stderr.txt'); throw "Capture failed (exit $($capture.ExitCode)): $application" }
    $result = Get-Content -LiteralPath (Join-Path $application 'capture-result.json') -Raw | ConvertFrom-Json
    if ($capture.ExitCode -ne 0 -or -not $result.ok -or $result.captures.Count -ne $Scenes.Count) { throw ('Capture result failed: '+$result.error) }
    Copy-Item -LiteralPath (Join-Path $captureProject '.capture-source.json') -Destination (Join-Path $application 'source.json')
    $captureClock.Stop()
    @{ seconds=[Math]::Round($captureClock.Elapsed.TotalSeconds,3); scenes=$Scenes } | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $application 'timing.json')
    $application | Set-Content -LiteralPath (Join-Path $TrailomonTools 'latest-captures.txt')
    Write-Host "Captured $($result.captures.Count) real rendered screens in $($captureClock.Elapsed.TotalSeconds.ToString('F2')) seconds: $application"
} finally { Pop-Location }
