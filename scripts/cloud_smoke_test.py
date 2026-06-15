#!/usr/bin/env python3
"""Smoke test do ThingsBoard Cloud.

Conecta ao broker MQTT do ThingsBoard Cloud usando as credenciais do device
(Basic MQTT: username/password do firmware) sobre TLS (8883) e publica alguns
pontos de telemetria — inclusive um evento de queda. Serve para provar, de
ponta a ponta, que o middleware na nuvem recebe dados pela internet.
"""
import asyncio
import json
import ssl
import time

import aiomqtt

HOST = "mqtt.thingsboard.cloud"
PORT = 8883
USER = "esp32user"
PASSWORD = "FallDetect@2026"
CLIENT_ID = "esp32-fall-detector"
TOPIC = "v1/devices/me/telemetry"


async def main() -> None:
    ctx = ssl.create_default_context()
    print(f"Conectando a {HOST}:{PORT} (TLS) como '{USER}'...")
    async with aiomqtt.Client(
        hostname=HOST, port=PORT,
        username=USER, password=PASSWORD,
        identifier=CLIENT_ID, tls_context=ctx, timeout=15,
    ) as client:
        print("Conectado ao ThingsBoard Cloud com sucesso.")

        # 3 leituras normais
        for i in range(3):
            payload = {
                "accel_x": round(0.01 * i, 3), "accel_y": 0.0,
                "accel_z": 1.0, "magnitude": 1.0, "status": "normal",
            }
            await client.publish(TOPIC, json.dumps(payload), qos=1)
            print(f"  [{i+1}/3] telemetria normal publicada: {payload}")
            await asyncio.sleep(0.5)

        # 1 evento de queda
        fall = {
            "magnitude": 3.2, "status": "FALL_DETECTED",
            "fall_detected": True, "impact_magnitude": 3.2,
            "timestamp": int(time.time() * 1000),
        }
        await client.publish(TOPIC, json.dumps(fall), qos=1)
        print(f"  [QUEDA] alerta de queda publicado: {fall}")

    print("Desconectado. Verifique no dashboard: Devices -> esp32-fall-detector -> Latest telemetry.")


if __name__ == "__main__":
    asyncio.run(main())
