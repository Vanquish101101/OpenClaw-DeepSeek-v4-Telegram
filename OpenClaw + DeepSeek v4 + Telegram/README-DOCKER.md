# OpenClaw — Docker режим

## Первый запуск (один раз)

```powershell
cd "C:\Users\Unknown\Documents\Projects\OpenClaw + DeepSeek v4 + Telegram\OpenClaw + DeepSeek v4 + Telegram"
docker-compose build
docker-compose up -d
```

## Каждый следующий раз

Запускаешь Docker Desktop → контейнер поднимается **автоматически** (`restart: always`).

## Проверка

```powershell
docker ps
docker logs openclaw-bot --tail 30
```

## Остановить

```powershell
docker-compose down
```

## Что внутри контейнера

| Что | Где |
|-----|-----|
| Конфиг | `/root/.openclaw/openclaw.json` |
| Токен | `/root/.openclaw/secrets/telegram-bot-token.txt` |
| Память агента | Docker volume `openclaw-memory` |
| Сессии | Docker volume `openclaw-sessions` |
| Порт | `18789` → `localhost:18789` |

## Секреты

Хранятся в `docker/.env` — не коммитить в git.

## Монитор (уведомление в Telegram если контейнер упал)

Запускается автоматически через Scheduled Task "OpenClaw Docker Monitor".
При падении контейнера или Docker — придёт сообщение в Telegram.

Проверить вручную:
```powershell
.\scripts\docker-monitor.ps1
```
