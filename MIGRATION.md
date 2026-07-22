# MIGRATION MAP — OpenClaw + DeepSeek v4 + Telegram
> Создан: 2026-07-14  
> Назначение: полный перенос проекта на диск E и/или на новый системный диск (Windows 10, 1 ТБ)  
> Связанные проекты: [[Claude code + Telegram Telemost]], [[Hermes + DeepSeek v4 + Telegram]]

---

## 1. ПАПКИ ПРОЕКТА — что копировать

### 1.1 Этот проект (OpenClaw скрипты)
```
ИСТОЧНИК:  C:\Users\Unknown\Documents\Projects\OpenClaw + DeepSeek v4 + Telegram\
ЦЕЛЬ:      E:\Projects\OpenClaw + DeepSeek v4 + Telegram\
РАЗМЕР:    ~0.06 MB (только скрипты и документация)
```
**Содержит:**  
- `scripts\` — PowerShell скрипты запуска и диагностики  
- `MIGRATION.md` — этот файл  
- `SESSION-RESTORE.md` — справочник по всем 3 ботам  
- `LESSON-README.md`, `AGENTS.md`, `CHECKLIST.md`, `README.md`  
- `.secrets\` — gitignored, отчёт импорта ключей (без значений)  
- `logs\` — пустые placeholder-логи  

**НЕТ git-репозитория.** При переносе на новый диск — git init не нужен.

---

### 1.2 Claude Code Telegram (связанный проект)
```
⚠️ СВЯЗАН С ЭТИМ ПРОЕКТОМ — scheduled task "Claude Code Telegram Bot" использует пути отсюда
ИСТОЧНИК:  C:\Users\Unknown\Documents\Projects\Claude code + Telegram Telemost\
РАЗМЕР:    ~0.52 MB
```
**Ключевые файлы:**
- `.claude-telegram\.env` — токен Telegram-бота Claude + ANTHROPIC_API_KEY  
- `scripts\run-claude-telegram-forever.ps1` — wrapper бесконечного рестарта  
- Scheduled Task `"Claude Code Telegram Bot"` вызывает скрипт из этой папки  

**НЕТ git-репозитория.**

---

### 1.3 Hermes (связанный проект)
```
⚠️ СВЯЗАН — имеет git и shared DeepSeek API key
ИСТОЧНИК:  C:\Users\Unknown\Documents\Projects\Hermes + DeepSeek v4 + Telegram\
GITHUB:    https://github.com/Vanquish101101/Hermes-DeepSeek-v4-Telegram.git
РАЗМЕР:    ~3974 MB (содержит venv)
ПОСЛЕДНИЙ КОММИТ: 3845a40 — Видео-пайплайн обёрнут в MCP | version 0.3.17
```
**При переносе на новый диск:** можно клонировать с GitHub, потом `pip install -e .` вместо копирования venv.

---

## 2. ГЛОБАЛЬНЫЕ КОНФИГИ — за пределами папок проекта

> ⚠️ Эти папки НЕ входят в проект, но критичны для работы. Копировать отдельно.

### 2.1 OpenClaw config root
```
ПУТЬ:   C:\Users\Unknown\.openclaw\
РАЗМЕР: ~20.5 MB
```
| Подпапка / файл | Назначение |
|-----------------|-----------|
| `openclaw.json` | Главный конфиг: модель, каналы, плагины, MCP |
| `openclaw.json.last-good` | Последний рабочий снимок конфига |
| `.env` | `DEEPSEEK_API_KEY` для OpenClaw |
| `secrets\telegram-bot-token.txt` | 🔑 Токен @foresight_project_openclaw_bot |
| `secrets\deepseek-api-key.txt` | 🔑 DeepSeek API ключ |
| `secrets\mcp-market-token.txt` | 🔑 MCP Market API ключ |
| `agents\main\sessions\` | История сессий агента |
| `memory\` | Долгосрочная память OpenClaw |
| `workspace\` | Рабочее пространство агента |
| `gateway.cmd` | Команда запуска gateway |

**🔑 КРИТИЧНО:** `secrets\` содержит все ключи. При восстановлении — скопировать первым.

---

### 2.2 Hermes config (AppData)
```
ПУТЬ:   C:\Users\Unknown\AppData\Local\hermes\
РАЗМЕР: ~2284 MB (включает hermes-agent и state.db)
```
| Файл | Назначение |
|------|-----------|
| `config.yaml` | Главный конфиг Hermes |
| `.env` | **Все API-ключи Hermes** (список ниже) |
| `auth.json` | Авторизация |
| `state.db` | База состояния (~15 MB WAL) |
| `SOUL.md` | Системный промпт Hermes |
| `hermes-agent\` | Исполняемый код + venv (~2 ГБ) |

**🔑 Ключи в `hermes/.env` (58 переменных):**
```
ANTHROPIC_API_KEY, DEEPSEEK_API_KEY, OPENAI_API_KEY, GEMINI_API_KEY,
GROQ_API_KEY, OPENROUTER_API_KEY, REPLICATE_API_KEY, RUNWAY_API_KEY,
ELEVENLABS_API_KEY, PERPLEXITY_API_KEY, FIRECRAWL_API_KEY, APIFY_TOKEN,
GITHUB_TOKEN, SUPABASE_URL, SUPABASE_ANON_KEY, SUPABASE_SECRET_KEY,
SUPABASE_SERVICE_ROLE_KEY, SUPABASE_PAT, SUPABASE_PUBLISHABLE_KEY,
CHROMA_API_KEY, CHROMA_HOST, CHROMA_DATABASE, CHROMA_TENANT,
NOTION_API_KEY, NOTION_TOKEN, MCP_MARKET_API_KEY, MCP_SUPABASE_API_KEY,
SMITHERY_API_KEY, PINECONE_API_KEY, QDRANT_API_KEY, QDRANT_URL,
LANGGRAPH_API_KEY, LANGSMITH_API_KEY, MASTRA_API_KEY, HELICONE_API_KEY,
CREWAI_API_KEY, REDIS_API_KEY, VERCEL_API_KEY, YOUGILE_API_KEY,
POSTMYPOST_API_KEY, TELEGRAM_BOT_TOKEN, TELEGRAM_ALLOWED_USERS, ...
```

---

### 2.3 Claude Code global config
```
ПУТЬ:   C:\Users\Unknown\.claude\
РАЗМЕР: ~380 MB
```
| Путь | Назначение |
|------|-----------|
| `~\.claude.json` | User-level MCP серверы + настройки Claude Code |
| `~\.claude\channels\telegram\.env` | 🔑 TELEGRAM_BOT_TOKEN для Claude бота |
| `~\.claude\channels\telegram\access.json` | Allowed users для Claude Telegram |
| `~\.claude\projects\` | Память проектов Claude Code |

---

## 3. УСТАНОВЛЕННЫЕ ПРОГРАММЫ (глобально)

> При переносе на новый диск — нужно переустановить, НЕ копировать

| Программа | Версия | Путь установки | Команда переустановки |
|-----------|--------|----------------|----------------------|
| **Node.js** | 24.16.0 | `C:\Program Files\nodejs\` | скачать с nodejs.org |
| **npm** | bundled | с Node.js | — |
| **OpenClaw** | 2026.6.1 | `C:\Users\Unknown\AppData\Roaming\npm\` | `npm install -g openclaw` |
| **Claude Code** | 2.1.209.0 | `C:\Users\Unknown\.local\bin\claude.exe` | `npm install -g @anthropic-ai/claude-code` |
| **Bun** | 1.3.14 | `C:\Users\Unknown\.bun\bin\bun.exe` | `powershell -c "irm bun.sh/install.ps1\|iex"` |
| **Hermes** | 0.0.0.0 | `AppData\Local\hermes\hermes-agent\venv\Scripts\` | клонировать с GitHub + pip install |
| **Python** (venv) | — | внутри Hermes venv | создаётся при установке Hermes |

---

## 4. SCHEDULED TASKS (планировщик Windows)

> При переносе — задачи нужно пересоздать с новыми путями

| Задача | Статус | Триггер | Команда |
|--------|--------|---------|---------|
| **OpenClaw Telegram Gateway** | Ready | At logon | `powershell.exe ... -File "...\OpenClaw + DeepSeek v4 + Telegram\scripts\start-openclaw-gateway.ps1"` |
| **Claude Code Telegram Bot** | Running | At logon | `powershell.exe ... -File "...\Claude code + Telegram Telemost\scripts\run-claude-telegram-forever.ps1"` |
| **Hermes Gateway Wrapper** | Running | At logon | скрипт в папке Hermes |
| **Claude MCP Health Monitor** | Running | At logon | мониторинг MCP-серверов |
| Hermes_Gateway | Disabled | — | устарела |
| OpenClaw Gateway | Disabled | — | устарела |

**⚠️ При смене диска:** обновить пути в задачах через `schtasks /Delete /TN "<name>" /F` и пересоздать с новыми путями.

---

## 5. TELEGRAM БОТЫ — доступы

| Бот | Username | Token location | Allowed User ID | Статус |
|-----|----------|----------------|-----------------|--------|
| **OpenClaw bot** | @foresight_project_openclaw_bot | `~\.openclaw\secrets\telegram-bot-token.txt` | 1064521326 | ✅ настроен |
| **Claude Code bot** | @foresight_project_claudecode_bot | `.claude-telegram\.env` (TELEGRAM_BOT_TOKEN) | — | ✅ Running |
| **Hermes bot** | — | `AppData\Local\hermes\.env` (TELEGRAM_BOT_TOKEN) | 1064521326 | ✅ Running |

**⚠️ ПОСЛЕ ПЕРЕНОСА — проверить Telegram:**
```powershell
# Отправить тестовое сообщение каждому боту из Telegram
# OpenClaw:
openclaw message send --channel telegram --target 1064521326 --message "Тест после переноса"

# Hermes:
hermes send --to telegram "Тест после переноса"

# Claude Code: написать боту напрямую в Telegram
```

**Известная проблема 409 Conflict:** если два процесса используют один токен — убить все, подождать 15 сек.

---

## 6. MCP СЕРВЕРЫ подключённые к OpenClaw

```json
// из openclaw.json — mcpServers
mcp-market:  https://link.mcpmarket.com/vfvf6462/toolkits/my-toolkit/mcp
miro:        https://link.mcpmarket.com/vfvf6462/miro/mcp
```
**Токен для MCP Market:** `~\.openclaw\secrets\mcp-market-token.txt`  
**После переноса:** токен должен остаться в том же месте — MCP Market сессионный, переавторизация не нужна при сохранённом токене.

---

## 7. GITHUB РЕПОЗИТОРИИ

| Проект | Репозиторий | Статус |
|--------|------------|--------|
| Hermes + DeepSeek v4 + Telegram | `https://github.com/Vanquish101101/Hermes-DeepSeek-v4-Telegram.git` | ✅ есть коммиты |
| OpenClaw + DeepSeek v4 + Telegram | ❌ нет репозитория | — |
| Claude code + Telegram Telemost | ❌ нет репозитория | — |

**Для Hermes при восстановлении на новом диске:**
```powershell
git clone https://github.com/Vanquish101101/Hermes-DeepSeek-v4-Telegram.git "Hermes + DeepSeek v4 + Telegram"
# затем восстановить .env из backup
# затем pip install -e . в venv
```

---

## 8. ПОРЯДОК ВОССТАНОВЛЕНИЯ НА НОВОМ ДИСКЕ

### Шаг 1. Установить базовые программы
```powershell
# Node.js 24.x — с nodejs.org
# После установки Node:
npm install -g openclaw@2026.6.1
npm install -g @anthropic-ai/claude-code
powershell -c "irm bun.sh/install.ps1|iex"
```

### Шаг 2. Восстановить глобальные конфиги
```powershell
# Скопировать с бэкапа или с диска E:
Copy-Item "E:\BACKUP_GLOBAL\.openclaw"   "$env:USERPROFILE\.openclaw" -Recurse
Copy-Item "E:\BACKUP_GLOBAL\hermes"      "$env:LOCALAPPDATA\hermes"   -Recurse
Copy-Item "E:\BACKUP_GLOBAL\.claude"     "$env:USERPROFILE\.claude"   -Recurse
Copy-Item "E:\BACKUP_GLOBAL\.claude.json" "$env:USERPROFILE\.claude.json"
```

### Шаг 3. Восстановить папки проектов
```powershell
Copy-Item "E:\Projects\OpenClaw + DeepSeek v4 + Telegram"   "C:\Users\...\Projects\" -Recurse
Copy-Item "E:\Projects\Claude code + Telegram Telemost"       "C:\Users\...\Projects\" -Recurse
# Hermes лучше клонировать с GitHub (экономия 4 ГБ):
git clone https://github.com/Vanquish101101/Hermes-DeepSeek-v4-Telegram.git
```

### Шаг 4. Проверить 3 критических условия OpenClaw
```powershell
Get-Content ~\.openclaw\secrets\telegram-bot-token.txt              # не пустой
(cat ~\.openclaw\openclaw.json | ConvertFrom-Json).channels.telegram.enabled    # True
(cat ~\.openclaw\openclaw.json | ConvertFrom-Json).plugins.entries.telegram.enabled  # True
```

### Шаг 5. Пересоздать Scheduled Tasks с новыми путями
```powershell
# OpenClaw gateway:
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument '-NonInteractive -WindowStyle Hidden -ExecutionPolicy Bypass -File "C:\Users\<USER>\...\OpenClaw + DeepSeek v4 + Telegram\scripts\start-openclaw-gateway.ps1"'
$trigger = New-ScheduledTaskTrigger -AtLogOn
Register-ScheduledTask -TaskName "OpenClaw Telegram Gateway" -Action $action -Trigger $trigger -RunLevel Highest
```

### Шаг 6. Тест Telegram
```powershell
.\scripts\start-openclaw-gateway.ps1
.\scripts\check-all-status.ps1
# Написать каждому боту в Telegram
```

---

## 9. ФАЙЛЫ БЭКАПА ГЛОБАЛЬНЫХ КОНФИГОВ

```
E:\BACKUP_GLOBAL\              ← создать при миграции
  .openclaw\                   ← ~20.5 MB — КРИТИЧНО
  hermes\                      ← ~2284 MB (без venv оптимально ~50 MB config только)
  .claude\                     ← ~380 MB
  .claude.json                 ← <1 MB
```

---

## 10. ССЫЛКИ И МЕТКИ

| Ресурс | Ссылка / Метка |
|--------|----------------|
| GitHub Hermes | https://github.com/Vanquish101101/Hermes-DeepSeek-v4-Telegram.git |
| MCP Market | https://link.mcpmarket.com/vfvf6462/toolkits/my-toolkit/mcp |
| MCP Market Miro | https://link.mcpmarket.com/vfvf6462/miro/mcp |
| Telegram @BotFather | https://t.me/BotFather (для пересоздания ботов) |
| Node.js | https://nodejs.org |
| Bun | https://bun.sh |
| DeepSeek API | https://api.deepseek.com (ключ в .openclaw\secrets\) |
| OpenClaw npm | https://www.npmjs.com/package/openclaw |

---

## 11. ТЕКУЩЕЕ СОСТОЯНИЕ (2026-07-14)

- OpenClaw gateway: **Ready** (не Running, но port 18789 слушается)  
- Claude Code Telegram Bot: **Running** (scheduled task активна)  
- Hermes Gateway Wrapper: **Running**  
- Claude MCP Health Monitor: **Running**  
- Disk E: **доступен**, свободно 1715 ГБ  
- Проект скопирован на E: **в процессе**  

---

> 📎 Этот файл связан с: SESSION-RESTORE.md, LESSON-README.md  
> 📎 Глобальные конфиги: `~\.openclaw\`, `%LOCALAPPDATA%\hermes\`, `~\.claude\`  
> 📎 GitHub: только Hermes имеет репозиторий
