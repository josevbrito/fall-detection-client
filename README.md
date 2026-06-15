# fall-detection-client — Gerador de carga (sensores)

Simula dispositivos ESP32 publicando telemetria de queda via **MQTT** para o
middleware ThingsBoard. Roda na **Máquina B (cliente)** e aponta para o servidor
do repositório [`fall-detection-cloud`](../fall-detection-cloud), executado em
**outra máquina (Máquina A)** — gerando tráfego de rede real entre as duas.

```
Máquina B (este repo)                       Máquina A (fall-detection-cloud)
  python scripts/provision_devices.py         ThingsBoard :8090 / :1883
  python scripts/load_test.py --devices 1000  Postgres
        └──────────────── LAN / MQTT :1883 ──────────────────▶
```

Funciona em 3 cenários, trocando só o `.env`:

| Cenário | Arquivo | Servidor |
|---|---|---|
| Servidor na LAN | `.env.lan.example` / `.env.example` | `fall-detection-cloud` em outra máquina |
| ThingsBoard Cloud | `.env.thingsboard-cloud.example` | gerenciado (thingsboard.cloud) |
| Tudo local (1 máquina) | edite `TB_HOST=localhost` | ThingsBoard no mesmo host |

---

## Instalação

```bash
pip install -r requirements.txt
```

## Uso (modo LAN — duas máquinas)

1. **Suba o servidor** na Máquina A (repo `fall-detection-cloud`) e descubra o IP dela.

2. **Configure o cliente:**
   ```bash
   cp .env.example .env
   # edite TB_HOST com o IP da Máquina A
   ```

3. **Provisione os devices** (sem teto — é self-hosted):
   ```bash
   python scripts/provision_devices.py --devices 1000
   ```

4. **Rode a carga:**
   ```bash
   python scripts/load_test.py --devices 1000 --requests 100 --interval 100
   ```

   Para forçar quedas (aparece `fall_detected` no dashboard):
   ```bash
   python scripts/load_test.py --devices 1000 --requests 100 --interval 100 --fall-prob 0.1
   ```

Veja a telemetria em `http://IP_DA_MAQUINA_A:8090`. Cada execução salva um
relatório JSON em `results/` (latência média/p99, throughput, taxa de erro).

---

## Demonstração distribuída (vários nós)

Divida o pool de devices entre máquinas/processos com `--offset`, simulando
gateways regionais independentes:

```bash
# Máquina B1: devices 0–499
python scripts/load_test.py --devices 500 --offset 0   --requests 100 --interval 100
# Máquina B2: devices 500–999
python scripts/load_test.py --devices 500 --offset 500 --requests 100 --interval 100
```

---

## Scripts

| Script | Função |
|---|---|
| `provision_devices.py` | Cria os devices no ThingsBoard e salva os tokens |
| `load_test.py` | Executa a carga MQTT e gera o relatório |
| `dashboard_setup.py` | Cria um dashboard de quedas no ThingsBoard |
| `cleanup.py` | Remove devices criados |
| `compare_results.py` | Compara relatórios de execuções diferentes |
| `cloud_smoke_test.py` | Teste rápido de conexão (publica 1 evento de queda) |

## Variáveis de ambiente principais

| Variável | Descrição |
|---|---|
| `TB_HOST` | Host do servidor (HTTP). IP da Máquina A na LAN |
| `TB_MQTT_HOST` | Host do broker MQTT (padrão = `TB_HOST`) |
| `TB_HTTP_SCHEME` / `TB_HTTP_PORT` | `http`/`8090` na LAN; `https`/`443` na nuvem |
| `TB_MQTT_PORT` / `TB_MQTT_TLS` | `1883`/`false` na LAN; `8883`/`true` com TLS |
| `TB_CLOUD` | `true` só no ThingsBoard Cloud gerenciado |
| `TB_TOKENS_FILE` | Nome do arquivo de tokens (separa cenários) |
| `MQTT_QOS` | `0` (fire-and-forget) ou `1` (com PUBACK) |
