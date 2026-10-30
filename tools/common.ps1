$ErrorActionPreference = 'Stop'
$TrailomonRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$TrailomonVersion = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'defold-version.json') -Raw | ConvertFrom-Json
$TrailomonTools = Join-Path $TrailomonRoot '.tools'
$TrailomonBob = Join-Path $TrailomonTools "bob-$($TrailomonVersion.version).jar"

function Initialize-TrailomonTools {
    if (-not (Get-Command java -ErrorAction SilentlyContinue)) {
        throw 'Install Java 25, or put the JDK bundled with Defold on PATH.'
    }
    New-Item -ItemType Directory -Path $TrailomonTools -Force | Out-Null
    if (-not (Test-Path -LiteralPath $TrailomonBob)) {
        Write-Host "Downloading the pinned Defold $($TrailomonVersion.version) builder..."
        Invoke-WebRequest -Uri $TrailomonVersion.bob_url -OutFile $TrailomonBob -UseBasicParsing
    }
    $downloadHash = (Get-FileHash -LiteralPath $TrailomonBob -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($downloadHash -ne $TrailomonVersion.bob_sha256) { throw 'The Bob checksum does not match tools/defold-version.json.' }
}

function Invoke-TrailomonBob {
    param([string[]]$BuildArguments)
    & java --enable-native-access=ALL-UNNAMED -jar $TrailomonBob @BuildArguments
    if ($LASTEXITCODE -ne 0) { throw "Defold build failed with exit code $LASTEXITCODE." }
}

function New-TrailomonOutput {
    param([string]$Parent, [string]$Prefix)
    # A fresh bundle directory avoids replacing an executable that is running,
    # and avoids OneDrive's read-only directory attributes during Bob cleanup.
    $stamp = [DateTime]::UtcNow.ToString('yyyyMMdd-HHmmss-fff')
    $path = Join-Path (Join-Path $TrailomonRoot $Parent) "$Prefix-$stamp"
    New-Item -ItemType Directory -Path $path -Force | Out-Null
    return $path
}
