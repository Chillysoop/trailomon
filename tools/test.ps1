param([switch]$SkipEngine, [switch]$Headless)
. (Join-Path $PSScriptRoot 'common.ps1')
Initialize-TrailomonTools
Add-Type -AssemblyName System.IO.Compression.FileSystem
$luaPath = Join-Path $TrailomonTools 'luajit-64.exe'
$builderArchive = [System.IO.Compression.ZipFile]::OpenRead($TrailomonBob)
try {
    foreach ($assetName in @('luajit-64.exe','libwinpthread-1.dll')) {
        $entry = $builderArchive.GetEntry("libexec/x86_64-win32/$assetName")
        if ($entry) { [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, (Join-Path $TrailomonTools $assetName), $true) }
    }
} finally { $builderArchive.Dispose() }
Push-Location $TrailomonRoot
try {
    & $luaPath 'tests/run.lua'
    if ($LASTEXITCODE -ne 0) { throw 'Simulation checks failed.' }
    if (-not $SkipEngine) {
        $output = New-TrailomonOutput -Parent '.tools' -Prefix 'engine-checks'
        # Hosted runners need Defold's null graphics backend. Local checks keep
        # the release renderer so they exercise real GUI nodes without a debug server.
        $variant = if ($Headless) { 'headless' } else { 'release' }
        Invoke-TrailomonBob -BuildArguments @('--settings','tests/engine.project','--output','build/engine-checks','--archive','--platform','x86_64-win32','--variant',$variant,'--bundle-output',$output,'build','bundle')
        $checkFolder = Join-Path $output 'Trailomon Checks'
        $reportPath = Join-Path $checkFolder 'engine-check-report.txt'
        $stdoutPath = Join-Path $checkFolder 'engine-stdout.txt'
        $stderrPath = Join-Path $checkFolder 'engine-stderr.txt'
        $engine = Start-Process -FilePath (Join-Path $checkFolder 'TrailomonChecks.exe') -WorkingDirectory $checkFolder -ArgumentList '--config=engine.run_while_iconified=1' -WindowStyle Hidden -RedirectStandardOutput $stdoutPath -RedirectStandardError $stderrPath -PassThru
        if (-not $engine.WaitForExit(15000)) { Stop-Process -Id $engine.Id; throw 'Native persistence checks timed out.' }
        if (-not (Test-Path -LiteralPath $reportPath)) {
            Get-Content -LiteralPath $stdoutPath,$stderrPath
            throw "The test engine exited before initialization (exit $($engine.ExitCode)). Use -Headless on machines without a graphics driver."
        }
        $report = Get-Content -LiteralPath $reportPath -Raw
        Write-Host $report
        if ($engine.ExitCode -ne 0 -or $report.Contains('FAIL:') -or -not $report.Contains('PASS: native save/load') -or -not $report.Contains('PASS: 25 native GUI states')) { throw 'Native persistence or GUI checks failed.' }
    }
} finally { Pop-Location }
