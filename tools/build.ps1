param([switch]$NoZip)
. (Join-Path $PSScriptRoot 'common.ps1')
Initialize-TrailomonTools
$bundleOutput = New-TrailomonOutput -Parent 'dist' -Prefix 'Windows-0.1.0'
Push-Location $TrailomonRoot
try {
    Invoke-TrailomonBob -BuildArguments @('--archive', '--platform', 'x86_64-win32', '--variant', 'release', '--bundle-output', $bundleOutput, 'build', 'bundle')
    $application = Join-Path $bundleOutput 'Trailomon'
    Copy-Item -LiteralPath (Join-Path $TrailomonRoot 'docs\PLAYTEST.md') -Destination (Join-Path $application 'READ-ME.md')
    $sourceRevision = (& git rev-parse HEAD).Trim()
    if ($LASTEXITCODE -ne 0) { throw 'Cannot identify the source revision.' }
    $sourceDirty = [bool](& git status --porcelain)
    $provenance = [ordered]@{game='Trailomon'; version='0.1.0'; platform='windows-x86_64'; commit=$sourceRevision; working_tree_changes=$sourceDirty; built_at=[DateTime]::UtcNow.ToString('o')}
    $provenance | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $application 'build-info.json') -Encoding utf8
    "`nBuild version: 0.1.0`nSource commit: $sourceRevision`nWorking tree changes: $sourceDirty`nLaunch Trailomon.exe with the four game.* files alongside it.`n" | Add-Content -LiteralPath (Join-Path $application 'READ-ME.md') -Encoding utf8
    if (-not $NoZip) {
        $zip = "$bundleOutput.zip"
        Compress-Archive -LiteralPath $application -DestinationPath $zip
        $shareFolder = Join-Path $TrailomonRoot 'builds'
        New-Item -ItemType Directory -Path $shareFolder -Force | Out-Null
        Copy-Item -LiteralPath $zip -Destination (Join-Path $shareFolder 'Trailomon-windows.zip') -Force
        $provenance | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $shareFolder 'Trailomon-windows.json') -Encoding utf8
        Write-Host "Shareable archive: $(Join-Path $shareFolder 'Trailomon-windows.zip')"
        Write-Host "Windows archive: $zip"
    }
    $application | Set-Content -LiteralPath (Join-Path $TrailomonTools 'latest-bundle.txt')
    Write-Host "Play: $(Join-Path $application 'Trailomon.exe')"
} finally { Pop-Location }
