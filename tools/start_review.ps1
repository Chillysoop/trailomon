param([string]$Page = 'plan-1')
$ErrorActionPreference = 'Stop'
$reviewProjectRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$reviewExpectedRoot = Join-Path $reviewProjectRoot 'reviews'
$reviewTools = Join-Path $reviewProjectRoot '.tools'
New-Item -ItemType Directory -Path $reviewTools -Force | Out-Null
if ($Page -notmatch '^[a-z0-9][a-z0-9_-]{0,79}$') { throw 'Invalid review page id.' }
$reviewHealth = $null
try { $reviewHealth = Invoke-RestMethod -Uri 'http://localhost:8765/api/health' -TimeoutSec 2 } catch {
    if (Get-NetTCPConnection -LocalPort 8765 -State Listen -ErrorAction SilentlyContinue) {
        throw 'Port 8765 is occupied by another service. It was not stopped.'
    }
}
if ($reviewHealth) {
    if ($reviewHealth.service -ne 'trailomon-review' -or [IO.Path]::GetFullPath($reviewHealth.root) -ne $reviewExpectedRoot) {
        throw 'The running review server belongs to a different project. It was not changed.'
    }
} else {
    $reviewPython = (Get-Command python -ErrorAction Stop).Source
    Start-Process -FilePath $reviewPython -ArgumentList @('tools/review_server.py') -WorkingDirectory $reviewProjectRoot -WindowStyle Hidden -RedirectStandardOutput (Join-Path $reviewTools 'review-server.stdout.log') -RedirectStandardError (Join-Path $reviewTools 'review-server.stderr.log') | Out-Null
    for ($reviewAttempt = 0; $reviewAttempt -lt 20; $reviewAttempt++) {
        Start-Sleep -Milliseconds 150
        try { $reviewHealth = Invoke-RestMethod -Uri 'http://localhost:8765/api/health' -TimeoutSec 1; break } catch { }
    }
    if (-not $reviewHealth -or $reviewHealth.service -ne 'trailomon-review' -or [IO.Path]::GetFullPath($reviewHealth.root) -ne $reviewExpectedRoot) { throw 'Review server did not become ready. See .tools/review-server.stderr.log.' }
}
Write-Host "Review: http://localhost:8765/$Page.html"
