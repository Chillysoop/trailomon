param(
    [string]$Seeds='1:40',
    [string]$Strategies='careful,peaceful,fighter',
    [switch]$Compare,
    [string]$Output='',
    [string]$Replay='',
    [ValidateRange(1,10000)][int]$MaxActions=250,
    [ValidateRange(2,100)][int]$StallVisits=3
)
. (Join-Path $PSScriptRoot 'common.ps1')
$luaPath = Initialize-TrailomonLua
$reportArgs = @((Join-Path $PSScriptRoot 'expedition_report.py'),'--lua',$luaPath,'--seeds',$Seeds,'--strategies',$Strategies,'--max-actions',$MaxActions,'--stall-visits',$StallVisits)
if ($Compare) { $reportArgs += '--compare' }
if ($Output) { $reportArgs += @('--output',$Output) }
if ($Replay) { $reportArgs += @('--replay',$Replay) }
Push-Location $TrailomonRoot
try {
    & python @reportArgs
    if ($LASTEXITCODE -ne 0) { throw 'Expedition report failed; inspect the report folder and diagnostic above.' }
} finally { Pop-Location }
