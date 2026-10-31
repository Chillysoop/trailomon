. (Join-Path $PSScriptRoot 'common.ps1')
$luaPath = Initialize-TrailomonLua
$output = New-TrailomonOutput -Parent '.tools' -Prefix 'guardian-report'
New-Item -ItemType Directory -Path $output -Force | Out-Null
Push-Location $TrailomonRoot
try {
    $first = & $luaPath tools/guardian_compare.lua
    if ($LASTEXITCODE -ne 0) { throw 'Guardian comparison failed.' }
    $second = & $luaPath tools/guardian_compare.lua
    if ($LASTEXITCODE -ne 0 -or $first -cne $second) { throw 'Guardian comparison did not repeat exactly.' }
    $first | Set-Content -LiteralPath (Join-Path $output 'comparison.json') -Encoding utf8
    $inputs = @{}
    foreach ($folder in @('simulation','content','services','tools/report')) {
        Get-ChildItem -LiteralPath $folder -Filter '*.lua' -File | ForEach-Object { $inputs[$_.FullName.Substring($TrailomonRoot.Length+1)] = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash }
    }
    $inputs['tools/guardian_compare.lua'] = (Get-FileHash -LiteralPath tools/guardian_compare.lua -Algorithm SHA256).Hash
    @{commit=(& git rev-parse HEAD); dirty=[bool](& git status --porcelain); inputs=$inputs; repeated_exactly=$true} | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $output 'source.json')
    Write-Host "Repeated guardian comparison: $output"
    $output | Set-Content -LiteralPath (Join-Path $TrailomonTools 'latest-guardian-report.txt')
} finally { Pop-Location }
