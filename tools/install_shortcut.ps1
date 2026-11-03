param([string]$DesktopDirectory = [Environment]::GetFolderPath('Desktop'))
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$launcher = Join-Path $PSScriptRoot 'play.ps1'
$game = & $launcher -ResolveOnly
if (-not (Test-Path -LiteralPath $DesktopDirectory -PathType Container)) { throw "Desktop folder does not exist: $DesktopDirectory" }

# Keep the existing game icon independently of old bundle folders.
Add-Type -AssemblyName System.Drawing
$iconPath = Join-Path $root '.tools/trailomon-launcher.ico'
$icon = [Drawing.Icon]::ExtractAssociatedIcon($game)
try {
    $stream = [IO.File]::Create($iconPath)
    try { $icon.Save($stream) } finally { $stream.Dispose() }
} finally { $icon.Dispose() }

$shell = New-Object -ComObject WScript.Shell
$shortcutPath = Join-Path $DesktopDirectory 'Trailomon.lnk'
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = Join-Path $env:SystemRoot 'System32/WindowsPowerShell/v1.0/powershell.exe'
$shortcut.Arguments = '-NoLogo -NoProfile -NonInteractive -WindowStyle Hidden -ExecutionPolicy Bypass -File "' + $launcher + '"'
$shortcut.WorkingDirectory = $root
$shortcut.IconLocation = $iconPath + ',0'
$shortcut.Description = 'Play the latest locally built Trailomon version. Updates automatically after each successful build.'
$shortcut.WindowStyle = 7
$shortcut.Save()
Write-Output $shortcutPath
