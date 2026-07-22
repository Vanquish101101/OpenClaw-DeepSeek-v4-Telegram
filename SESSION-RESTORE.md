# Восстановление сессии — 2026-06-15

Следующую сессию открывать из:
`C:\Users\Unknown\Documents\Projects\OpenClaw + DeepSeek v4 + Telegram`

---

## Три Telegram-бота на машине

| Бот | Папка проекта | Scheduled Task |
|-----|--------------|----------------|
| **OpenClaw** (DeepSeek v4-pro) | `Projects\OpenClaw + DeepSeek v4 + Telegram` | "OpenClaw Telegram Gateway" |
| **Hermes** (DeepSeek) | `Projects\Hermes + DeepSeek v4 + Telegram` | "Hermes Gateway Wrapper" |
| **Claude Code Telegram** | `Projects\Claude code + Telegram Telemost` | "Claude Code Telegram Bot" |

---

## OpenClaw — конфигурация

| Параметр | Значение |
|----------|----------|
| Telegram bot | `@foresight_project_openclaw_bot` |
| Telegram bot token | `7976447539:AAEoWER2mXnI2mHaJqrR7JMMn4uOkUlFqTM` |
| DeepSeek API key | `sk-802ca69853b34d968d43babbd6c9f408` |
| Allowed user ID | `1064521326` — паринг выполнен |
| Модель | `deepseek/deepseek-v4-pro` |
| Config | `~\.openclaw\openclaw.json` |
| Token file | `~\.openclaw\secrets\telegram-bot-token.txt` |
| DeepSeek key file | `~\.openclaw\secrets\deepseek-api-key.txt` |
| Скрипт запуска | `.\scripts\start-openclaw-gateway.ps1` |
| Лог gateway | `%LOCALAPPDATA%\Temp\openclaw\openclaw-YYYY-MM-DD.log` |

### Scheduled Task
```powershell
schtasks /Query /TN "OpenClaw Telegram Gateway" /FO LIST
```
Статус на 2026-06-15: задача **Ready** (не Running), но gateway реально работает на порту 18789.

### КРИТИЧНО — 3 условия для работы Telegram
Если хотя бы одно нарушено — gateway говорит "ready", но бот молчит:

```powershell
# 1. Токен не пустой
Get-Content ~\.openclaw\secrets\telegram-bot-token.txt

# 2. channels.telegram.enabled = true
(cat ~\.openclaw\openclaw.json | ConvertFrom-Json).channels.telegram.enabled

# 3. plugins.entries.telegram.enabled = true
(cat ~\.openclaw\openclaw.json | ConvertFrom-Json).plugins.entries.telegram.enabled
```

### Ручные команды
```powershell
openclaw gateway stop
Start-Process powershell -ArgumentList "-NonInteractive -Command `"openclaw gateway run --force`"" -WindowStyle Hidden
openclaw status
openclaw channels status
openclaw logs --follow
```
Gateway реально запустился — искать строку: `starting provider (@foresight_project_openclaw_bot)`

### История поломок
**2026-06-12:** Бот молчал — все три условия были нарушены одновременно.
Gateway запускался без ошибок — это вводило в заблуждение.

---

## Hermes — конфигурация

| Параметр | Значение |
|----------|----------|
| Telegram bot token | `8915005412:AAHcFfvpdADarPgoeZHcTdswfJ4cBYOvnyw` |
| Allowed user ID | `1064521326` |
| Модель | `deepseek-chat` |
| DeepSeek API key | `sk-802ca69853b34d968d43babbd6c9f408` |
| Config | `C:\Users\Unknown\AppData\Local\hermes\config.yaml` |
| Secrets | `C:\Users\Unknown\AppData\Local\hermes\.env` |
| Wrapper скрипт | `Projects\Hermes + DeepSeek v4 + Telegram\scripts\run-hermes-gateway-forever.ps1` |
| Лог рестартов | `C:\Users\Unknown\AppData\Local\Temp\hermes-gateway\restart.log` |

Две задачи в планировщике — главная: **"Hermes Gateway Wrapper"** (бесконечный рестарт).

---

## Claude Code Telegram Bot — конфигурация

| Параметр | Значение |
|----------|----------|
| Telegram bot | `@foresight_project_claudecode_bot` |
| Bot token | `[REDACTED — хранится в .env файле бота]` |
| Anthropic API key | `[REDACTED — хранится в .env файле бота]` |
| .env файл | `Projects\Claude code + Telegram Telemost\.claude-telegram\.env` |
| Wrapper скрипт | `Projects\Claude code + Telegram Telemost\scripts\run-claude-telegram-forever.ps1` |
| Лог рестартов | `C:\Users\Unknown\AppData\Local\Temp\claude-telegram\restart.log` |

### Исправлено в сессии 2026-06-15
Добавлены в `CLAUDE_ALLOWED_TOOLS`:
`TaskCreate,TaskList,TaskGet,TaskUpdate,TaskStop,TaskOutput,CronCreate,CronList,CronDelete`

### Известная проблема — рестарты каждые ~8 часов
`.env` без `ANTHROPIC_API_KEY` → бот падает на OAuth каждые 8 часов.
**Постоянное решение:** добавить в `.env`:
```
ANTHROPIC_API_KEY=[REDACTED — добавить из .env файла бота]
```

---

## Notion MCP

| Параметр | Значение |
|----------|----------|
| Активный способ | MCP Market (HTTP/SSE) |
| MCP Market API Key | `[REDACTED — хранится в ~/.claude.json]` |
| Резервный Notion API Key | `[REDACTED — хранится в ~/.claude.json]` |
| Конфиг | `~/.claude.json` (user scope) |

---

## Глобальные правила диагностики

1. **Кириллица в путях** → 8.3 short path (`LESSON~1`, `CLAUDE~2`)
2. **Лог-папка** → создавать в начале wrapper (`New-Item -Force`)
3. **`& $exe` в hidden session** → `Start-Process -PassThru`
4. **.env с кириллицей** → `[System.IO.File]::WriteAllText` без BOM
5. **409 Conflict Telegram** → убить ВСЕ процессы + ждать 15 сек
6. **OAuth истекает за 8ч** → всегда `ANTHROPIC_API_KEY` для background-процессов
7. **CLAUDE_ALLOWED_TOOLS** → включать все Task*/Cron* инструменты
8. **Диагностика "бот не работает"** → ScheduledTask State → restart.log → запуск вручную → 409 → .env кодировка → папки логов

---

## Структура Projects на 2026-06-15

```
C:\Users\Unknown\Documents\Projects\
├── Claude code + Telegram Telemost\
├── Codex\
├── Digital brain\
├── Hermes + DeepSeek v4 + Telegram\
├── Lesson 1 (Урок 1)\          ← только инструкция.txt, скриптов нет
└── OpenClaw + DeepSeek v4 + Telegram\
```
