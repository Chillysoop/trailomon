param()
. (Join-Path $PSScriptRoot 'common.ps1')
Initialize-TrailomonTools
Push-Location $TrailomonRoot
try {
    & python tools/capture_prepare.py
    if ($LASTEXITCODE -ne 0) { throw 'Capture isolation preparation failed.' }
    $captureProject = Join-Path $TrailomonTools 'capture-project'
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'trailer_capture.gui_script') -Destination (Join-Path $captureProject 'tests/screenshots.gui_script')
    $output = New-TrailomonOutput -Parent '.tools' -Prefix 'trailer-footage'
    Push-Location $captureProject
    try {
        Invoke-TrailomonBob -BuildArguments @('--settings','tests/screenshots.project','--archive','--platform','x86_64-win32','--variant','release','--bundle-output',$output,'resolve','build','bundle')
    } finally { Pop-Location }
    $app = Join-Path $output 'Trailomon Capture'
    $engine = Start-Process -FilePath (Join-Path $app 'TrailomonCapture.exe') -WorkingDirectory $app -ArgumentList '--config=engine.run_while_iconified=1' -WindowStyle Hidden -RedirectStandardOutput (Join-Path $app 'stdout.txt') -RedirectStandardError (Join-Path $app 'stderr.txt') -PassThru
    if (-not $engine.WaitForExit(60000)) { Stop-Process -Id $engine.Id; throw 'Trailer capture timed out.' }
    $resultPath = Join-Path $app 'trailer-capture.json'
    if (-not (Test-Path -LiteralPath $resultPath)) { throw "Capture ended without a result: $app" }
    $result = Get-Content -LiteralPath $resultPath -Raw | ConvertFrom-Json
    if (-not $result.ok -or $result.frames -ne 600) { throw $result.error }
    Copy-Item -LiteralPath (Join-Path $captureProject '.capture-source.json') -Destination (Join-Path $app 'source.json')
    $app | Set-Content -LiteralPath (Join-Path $TrailomonTools 'latest-trailer-footage.txt')
    Write-Host "600 actual gameplay frames: $app"
} finally { Pop-Location }
