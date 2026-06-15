#!/usr/bin/env bash
# client.sh — executa um experimento: provisiona devices e roda o load test.
# Pergunta os parâmetros interativamente (com valores padrão entre colchetes).
set -e
cd "$(dirname "$0")"

if [ ! -f .env ]; then
  echo "ERRO: .env não encontrado. Rode ./init.sh primeiro e configure o TB_HOST."
  exit 1
fi

TB_HOST=$(grep -E '^TB_HOST=' .env | head -1 | cut -d= -f2 | tr -d ' "')
TB_PORT=$(grep -E '^TB_HTTP_PORT=' .env | head -1 | cut -d= -f2 | tr -d ' "')

echo "==================================================================="
echo " Experimento — Fall Detection (cliente)"
echo " Servidor (.env): TB_HOST=${TB_HOST:-?}  porta=${TB_PORT:-?}"
echo "==================================================================="

read -rp "Quantos devices PROVISIONAR? [20]: " PROV;  PROV=${PROV:-20}
read -rp "Quantos devices usar no TESTE?  [$PROV]: " DEV;  DEV=${DEV:-$PROV}
read -rp "Requisições por device?         [50]: " REQ;  REQ=${REQ:-50}
read -rp "Intervalo entre publicações (ms)? [200]: " INT;  INT=${INT:-200}
read -rp "Probabilidade de queda (0.0-1.0)? [0.05]: " FP;  FP=${FP:-0.05}

echo
echo ">>> Provisionando $PROV devices em $TB_HOST..."
python3 scripts/provision_devices.py --devices "$PROV"

echo
echo ">>> Load test: $DEV devices | $REQ req | ${INT}ms | fall-prob $FP"
python3 scripts/load_test.py --devices "$DEV" --requests "$REQ" --interval "$INT" --fall-prob "$FP"

echo
echo "==================================================================="
echo " Concluído. Relatório em results/."
echo " Veja a telemetria no dashboard: http://${TB_HOST}:${TB_PORT}"
echo "==================================================================="
