#!/usr/bin/env bash
# init.sh — setup inicial do CLIENTE (rodar uma vez).
# Instala dependências, prepara o .env e (opcional) cria o dashboard no servidor.
set -e
cd "$(dirname "$0")"

echo ">>> [1/3] Instalando dependências Python..."
python3 -m pip install -r requirements.txt

echo ">>> [2/3] Verificando .env..."
if [ ! -f .env ]; then
  cp .env.example .env
  echo "    .env criado. ⚠️  EDITE o .env e defina TB_HOST com o IP do servidor."
else
  echo "    .env já existe."
fi

TB_HOST=$(grep -E '^TB_HOST=' .env | head -1 | cut -d= -f2 | tr -d ' "')
TB_PORT=$(grep -E '^TB_HTTP_PORT=' .env | head -1 | cut -d= -f2 | tr -d ' "')

echo ">>> [3/3] Dashboard no ThingsBoard (opcional)"
echo "    Requer o servidor no ar e ao menos uma rodada de provisionamento."
read -rp "    Configurar o dashboard agora? [s/N]: " ans
if [[ "$ans" =~ ^[Ss]$ ]]; then
  python3 scripts/dashboard_setup.py || echo "    (dashboard falhou — rode depois de provisionar devices)"
fi

echo
echo "Init do cliente concluído."
echo "  Servidor configurado: TB_HOST=${TB_HOST:-?}:${TB_PORT:-?}"
echo "  Agora rode:  ./client.sh   (provisiona e executa o experimento)"
