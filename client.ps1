# client.ps1 — executa um experimento no Windows (provisiona + load test).
# Equivalente ao client.sh, com perguntas interativas.
#
# COMO RODAR (PowerShell):
#   Set-ExecutionPolicy -Scope Process Bypass -Force
#   .\client.ps1

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

if (-not (Test-Path .env)) {
    Write-Host "ERRO: .env nao encontrado. Rode .\init.ps1 primeiro e configure o TB_HOST."
    exit 1
}

# Le TB_HOST e porta do .env (apenas para exibir)
function Get-EnvValue($key) {
    $line = Get-Content .env | Where-Object { $_ -match "^$key=" } | Select-Object -First 1
    if ($line) { return ($line -split "=", 2)[1].Trim().Trim('"') }
    return "?"
}
$TB_HOST = Get-EnvValue "TB_HOST"
$TB_PORT = Get-EnvValue "TB_HTTP_PORT"

Write-Host "==================================================================="
Write-Host " Experimento - Fall Detection (cliente)"
Write-Host " Servidor (.env): TB_HOST=$TB_HOST  porta=$TB_PORT"
Write-Host "==================================================================="

function Ask($prompt, $default) {
    $v = Read-Host "$prompt [$default]"
    if (-not $v) { return $default }
    return $v
}

$PROV = Ask "Quantos devices PROVISIONAR?" "20"
$DEV  = Ask "Quantos devices usar no TESTE?" $PROV
$REQ  = Ask "Requisicoes por device?" "50"
$INT  = Ask "Intervalo entre publicacoes (ms)?" "200"
$FP   = Ask "Probabilidade de queda (0.0-1.0)?" "0.05"

Write-Host ""
Write-Host ">>> Provisionando $PROV devices em $TB_HOST..."
python scripts/provision_devices.py --devices $PROV

Write-Host ""
Write-Host ">>> Load test: $DEV devices | $REQ req | ${INT}ms | fall-prob $FP"
python scripts/load_test.py --devices $DEV --requests $REQ --interval $INT --fall-prob $FP

Write-Host ""
Write-Host "==================================================================="
Write-Host " Concluido. Relatorio em results/."
Write-Host " Veja a telemetria no dashboard: http://${TB_HOST}:${TB_PORT}"
Write-Host "==================================================================="
