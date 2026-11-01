param([switch]$SkipEngine, [switch]$Headless, [ValidateSet('All','Game','Review','Report')][string]$Suite='All', [ValidateSet('', 'scavengers', 'territorial', 'legacy')][string]$Fixture='')
. (Join-Path $PSScriptRoot 'common.ps1')
if ($Fixture -and $Suite -notin @('All','Game')) { throw 'Fixtures require the All or Game suite.' }
if ($Suite -in @('All','Game','Report')) { $luaPath = Initialize-TrailomonLua }
Push-Location $TrailomonRoot
try {
    if ($Suite -in @('All','Review')) {
        & python -m unittest discover -s tests -p 'test_review*.py'
        if ($LASTEXITCODE -ne 0) { throw 'Review server checks failed.' }
    }
    if ($Suite -in @('All','Game')) {
        & python -m unittest discover -s tests -p 'test_capture.py'
        if ($LASTEXITCODE -ne 0) { throw 'Capture isolation checks failed.' }
        & $luaPath 'tests/run.lua'
        if ($LASTEXITCODE -ne 0) { throw 'Simulation checks failed.' }
    }
    if ($Suite -in @('All','Report')) {
        & python -m unittest discover -s tests -p 'test_report*.py'
        if ($LASTEXITCODE -ne 0) { throw 'Expedition reporter checks failed.' }
    }
    if (-not $SkipEngine -and $Suite -in @('All','Game')) {
        $output = New-TrailomonOutput -Parent '.tools' -Prefix 'engine-checks'
        # Hosted runners need Defold's null graphics backend. Local checks keep
        # the release renderer so they exercise real GUI nodes without a debug server.
        $variant = if ($Headless) { 'headless' } else { 'release' }
        Invoke-TrailomonBob -BuildArguments @('--settings','tests/engine.project','--output','build/engine-checks','--archive','--platform','x86_64-win32','--variant',$variant,'--bundle-output',$output,'build','bundle')
        $checkFolder = Join-Path $output 'Trailomon Checks'
        $reportPath = Join-Path $checkFolder 'engine-check-report.txt'
        $stdoutPath = Join-Path $checkFolder 'engine-stdout.txt'
        $stderrPath = Join-Path $checkFolder 'engine-stderr.txt'
        $engineArgs = @('--config=engine.run_while_iconified=1')
        if ($Fixture) {
            $qaNamespace = 'trailomon_qa_' + $Fixture + '_' + [DateTime]::UtcNow.ToString('yyyyMMddHHmmss')
            $engineArgs += @("--config=trailomon.fixture=$Fixture", "--config=trailomon.save_namespace=$qaNamespace")
        }
        $engine = Start-Process -FilePath (Join-Path $checkFolder 'TrailomonChecks.exe') -WorkingDirectory $checkFolder -ArgumentList $engineArgs -WindowStyle Hidden -RedirectStandardOutput $stdoutPath -RedirectStandardError $stderrPath -PassThru
        if (-not $engine.WaitForExit(15000)) { Stop-Process -Id $engine.Id; throw 'Native persistence checks timed out.' }
        if (-not (Test-Path -LiteralPath $reportPath)) {
            Get-Content -LiteralPath $stdoutPath,$stderrPath
            throw "The test engine exited before initialization (exit $($engine.ExitCode)). Use -Headless on machines without a graphics driver."
        }
        $report = Get-Content -LiteralPath $reportPath -Raw
        Write-Host $report
        if ($engine.ExitCode -ne 0 -or $report.Contains('FAIL:') -or -not $report.Contains('PASS: native save/load') -or -not $report.Contains('PASS: 36 native GUI states') -or -not $report.Contains('PASS: battle readiness') -or -not $report.Contains('PASS: isolated wagon ambush')) { throw 'Native persistence or GUI checks failed.' }
        if ($Fixture) {
            Set-Content -LiteralPath (Join-Path $TrailomonTools 'latest-playtest-namespace.txt') -Value $qaNamespace
            Write-Host "Isolated fixture ready. Launch the game with --config=trailomon.save_namespace=$qaNamespace"
        }
    }
} finally { Pop-Location }
