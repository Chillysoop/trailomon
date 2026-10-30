param([switch]$SkipEngine)
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
        Invoke-TrailomonBob -BuildArguments @('--settings','tests/engine.project','--output','build/engine-checks','--archive','--platform','x86_64-win32','--variant','release','--bundle-output',$output,'build','bundle')
        $checkFolder = Join-Path $output 'Trailomon Checks'
        $engine = Start-Process -FilePath (Join-Path $checkFolder 'TrailomonChecks.exe') -WorkingDirectory $checkFolder -ArgumentList '--config=engine.run_while_iconified=1' -WindowStyle Hidden -PassThru
        if (-not $engine.WaitForExit(15000)) { Stop-Process -Id $engine.Id; throw 'Native persistence checks timed out.' }
        $report = Get-Content -LiteralPath (Join-Path $checkFolder 'engine-check-report.txt') -Raw
        Write-Host $report
        if ($engine.ExitCode -ne 0 -or -not $report.StartsWith('PASS:')) { throw 'Native persistence checks failed.' }
    }
} finally { Pop-Location }
