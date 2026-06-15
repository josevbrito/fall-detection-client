# init.ps1 — setup inicial do CLIENTE no Windows (rodar uma vez).
# Equivalente ao init.sh, para máquinas Windows sem WSL/bash.
#
# COMO RODAR (PowerShell):
#   Set-ExecutionPolicy -Scope Process Bypass -Force
#   .\init.ps1
#
# Pré-requisito: Python 3 instalado (verifique com:  python --version)

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

Write-Host ">>> [1/2] Instalando dependencias Python..."
python -m pip install -r requirements.txt

Write-Host ">>> [2/2] Verificando .env..."
if (-not (Test-Path .env)) {
    Copy-Item .env.example .env
    Write-Host "    .env criado. EDITE o .env e defina TB_HOST com o IP do servidor (ex: 192.168.100.86)."
} else {
    Write-Host "    .env ja existe."
}

Write-Host ""
Write-Host "Init concluido. Agora rode:  .\client.ps1"
