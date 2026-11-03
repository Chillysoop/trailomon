param(
    [switch]$ResolveOnly,
    [string]$ProjectRoot = (Split-Path $PSScriptRoot -Parent)
)
$ErrorActionPreference = 'Stop'

# Resolve at click time: the shortcut never points to a timestamped build.
$dist = [IO.Path]::GetFullPath((Join-Path $ProjectRoot 'dist'))
function Read-PlayerBundle([string]$Path) {
    try {
        $folder = [IO.Path]::GetFullPath($Path)
        if (-not $folder.StartsWith($dist + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) { return }
        foreach ($file in @('Trailomon.exe','game.arcd','game.arci','game.dmanifest','game.projectc','build-info.json')) {
            if (-not (Test-Path -LiteralPath (Join-Path $folder $file) -PathType Leaf)) { return }
        }
        $info = Get-Content -LiteralPath (Join-Path $folder 'build-info.json') -Raw -Encoding UTF8 | ConvertFrom-Json
        if ($info.game -ne 'Trailomon' -or $info.platform -ne 'windows-x86_64') { return }
        return [PSCustomObject]@{ Folder=$folder; BuiltAt=[DateTimeOffset]::Parse($info.built_at) }
    } catch { return } # An incomplete build is never a launch target.
}

try {
    $bundle = $null
    $pointer = Join-Path $ProjectRoot '.tools/latest-bundle.txt'
    if (Test-Path -LiteralPath $pointer -PathType Leaf) {
        $bundle = Read-PlayerBundle (Get-Content -LiteralPath $pointer -Raw -Encoding UTF8).Trim()
    }
    if (-not $bundle -and (Test-Path -LiteralPath $dist -PathType Container)) {
        $bundle = Get-ChildItem -LiteralPath $dist -Directory -Filter 'Windows-*' |
            ForEach-Object { Read-PlayerBundle (Join-Path $_.FullName 'Trailomon') } |
            Sort-Object BuiltAt -Descending | Select-Object -First 1
    }
    if (-not $bundle) { throw 'No complete Trailomon build was found. Open the project and run tools/build.ps1, then try again.' }
    $executable = Join-Path $bundle.Folder 'Trailomon.exe'
    if ($ResolveOnly) { return $executable }
    # The requested game is interactive; only this window should be visible.
    Start-Process -FilePath $executable -WorkingDirectory $bundle.Folder -WindowStyle Normal
} catch {
    if ($ResolveOnly) { throw }
    Add-Type -AssemblyName System.Windows.Forms
    [void][Windows.Forms.MessageBox]::Show($_.Exception.Message, 'Trailomon', 'OK', 'Error')
    exit 1
}
