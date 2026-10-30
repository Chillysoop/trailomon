param([switch]$NoZip)
. (Join-Path $PSScriptRoot 'common.ps1')
Initialize-TrailomonTools
$bundleOutput = New-TrailomonOutput -Parent 'dist' -Prefix 'Windows-0.1.0'
Push-Location $TrailomonRoot
try {
    Invoke-TrailomonBob -BuildArguments @('--archive', '--platform', 'x86_64-win32', '--variant', 'release', '--bundle-output', $bundleOutput, 'build', 'bundle')
    $application = Join-Path $bundleOutput 'Trailomon'
    Copy-Item -LiteralPath (Join-Path $TrailomonRoot 'docs\PLAYTEST.md') -Destination (Join-Path $application 'READ-ME.md')
    if (-not $NoZip) {
        $zip = "$bundleOutput.zip"
        Compress-Archive -LiteralPath $application -DestinationPath $zip
        Write-Host "Windows archive: $zip"
    }
    $application | Set-Content -LiteralPath (Join-Path $TrailomonTools 'latest-bundle.txt')
    Write-Host "Play: $(Join-Path $application 'Trailomon.exe')"
} finally { Pop-Location }
