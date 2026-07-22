#!/bin/sh
set -e

echo "[openclaw] Writing secrets from environment..."
printf '%s' "$TELEGRAM_BOT_TOKEN" > /root/.openclaw/secrets/telegram-bot-token.txt
printf '%s' "$DEEPSEEK_API_KEY"   > /root/.openclaw/secrets/deepseek-api-key.txt
printf 'DEEPSEEK_API_KEY=%s\n' "$DEEPSEEK_API_KEY" > /root/.openclaw/.env

echo "[openclaw] Starting gateway..."
exec openclaw gateway run --force
