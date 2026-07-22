# GLOBAL CONFIGS SNAPSHOT
> Снимок: 2026-07-14  
> Назначение: полное восстановление всех глобальных ресурсов при переезде  
> Связан с: [[MIGRATION.md]], [[SESSION-RESTORE.md]]  
> Бэкап конфигов: `E:\BACKUP_GLOBAL\`

---

## 1. УСТАНОВЛЕННЫЕ ПРОГРАММЫ

> При переезде на новый диск — переустанавливать, не копировать (кроме отдельных указаний)

| Программа | Версия | Где установлена | Команда переустановки |
|-----------|--------|-----------------|----------------------|
| **Node.js** | 24.16.0 | `C:\Program Files\nodejs\` | [nodejs.org](https://nodejs.org) → LTS |
| **npm** | bundled с Node | — | — |
| **OpenClaw** | 2026.6.1 | `%APPDATA%\npm\openclaw.ps1` | `npm install -g openclaw` |
| **Claude Code** | 2.1.209.0 | `%USERPROFILE%\.local\bin\claude.exe` | `npm install -g @anthropic-ai/claude-code` |
| **Bun** | 1.3.14 | `%USERPROFILE%\.bun\bin\bun.exe` | `powershell -c "irm bun.sh/install.ps1\|iex"` |
| **Hermes** | 0.0.0.0 | `%LOCALAPPDATA%\hermes\hermes-agent\venv\` | клонировать с GitHub (см. раздел 5) |
| **Python** | — | внутри Hermes venv | создаётся автоматически при установке Hermes |

---

## 2. SCHEDULED TASKS (Планировщик Windows)

> Бэкап XML задач: `E:\BACKUP_GLOBAL\scheduled-tasks\` (создаётся скриптом ниже)  
> При переезде — пересоздать с новыми путями. Скрипт для OpenClaw: `scripts\update-scheduled-task-to-E.ps1`

### ⚠️ ТЕКУЩЕЕ СОСТОЯНИЕ ЗАДАЧ (2026-07-14)

| Задача | Состояние | Диск | Путь к скрипту |
|--------|-----------|------|----------------|
| **OpenClaw Telegram Gateway** | ⚠️ УДАЛЕНА (нужен admin для пересоздания) | → E: | `E:\Projects\OpenClaw + DeepSeek v4 + Telegram\scripts\start-openclaw-gateway.ps1` |
| **Claude Code Telegram Bot** | Running | C: | `C:\Users\Unknown\DOCUME~1\Projects\CLAUDE~1\scripts\RUN-CL~1.PS1` |
| **Hermes Gateway Wrapper** | Running | C: | `C:\Users\Unknown\Documents\Projects\Hermes + DeepSeek v4 + Telegram\scripts\run-hermes-gateway-forever.ps1` |
| **Claude MCP Health Monitor** | Running | C: | `C:\Users\Unknown\DOCUME~1\Projects\CLAUDE~1\scripts\MCP-HE~1.PS1` |

### ⚡ СРОЧНО: Пересоздать OpenClaw Telegram Gateway

Задача была удалена в ходе миграции. Нужно запустить **от имени Администратора**:
```powershell
& "E:\Projects\OpenClaw + DeepSeek v4 + Telegram\scripts\update-scheduled-task-to-E.ps1"
```
Или вручную (от имени Администратора):
```powershell
$xml = @'
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Description>Запускает OpenClaw gateway с Telegram при входе в систему (E: drive)</Description>
  </RegistrationInfo>
  <Triggers><LogonTrigger><Enabled>true</Enabled></LogonTrigger></Triggers>
  <Principals>
    <Principal id="Author">
      <LogonType>InteractiveToken</LogonType>
      <RunLevel>HighestAvailable</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <ExecutionTimeLimit>PT0S</ExecutionTimeLimit>
    <Enabled>true</Enabled>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>powershell.exe</Command>
      <Arguments>-NonInteractive -WindowStyle Hidden -ExecutionPolicy Bypass -File "E:\Projects\OpenClaw + DeepSeek v4 + Telegram\scripts\start-openclaw-gateway.ps1"</Arguments>
    </Exec>
  </Actions>
</Task>
'@
$p = "$env:TEMP\oc-task.xml"
[System.IO.File]::WriteAllText($p, $xml, [System.Text.Encoding]::Unicode)
schtasks /Create /TN "OpenClaw Telegram Gateway" /XML $p /F
Remove-Item $p
```

### Команды экспорта XML всех задач (выполнить от Администратора)
```powershell
New-Item -ItemType Directory "E:\BACKUP_GLOBAL\scheduled-tasks" -Force | Out-Null
$tasks = "OpenClaw Telegram Gateway","Claude Code Telegram Bot","Hermes Gateway Wrapper","Claude MCP Health Monitor"
foreach ($t in $tasks) {
    schtasks /Query /TN $t /XML ONE > "E:\BACKUP_GLOBAL\scheduled-tasks\$($t -replace ' ','-').xml"
}
```

---

## 3. OPENCLAW CONFIG ROOT

```
ПАПКА:    C:\Users\<user>\.openclaw\
БЭКАП:    E:\BACKUP_GLOBAL\.openclaw\
РАЗМЕР:   ~20.5 MB (90 файлов)
```

### Ключевые файлы

| Файл | Назначение | Восстановление |
|------|-----------|----------------|
| `openclaw.json` | Главный конфиг | Скопировать, НЕ редактировать вручную |
| `openclaw.json.last-good` | Снимок последнего рабочего конфига | Резерв если основной сломался |
| `.env` | `DEEPSEEK_API_KEY` | Скопировать |
| `gateway.cmd` | Команда запуска gateway | Скопировать |
| `secrets\telegram-bot-token.txt` | 🔑 Токен @foresight_project_openclaw_bot | Скопировать |
| `secrets\deepseek-api-key.txt` | 🔑 DeepSeek API key | Скопировать |
| `secrets\mcp-market-token.txt` | 🔑 MCP Market API key | Скопировать |
| `agents\main\sessions\sessions.json` | История сессий | Скопировать (опционально) |
| `memory\` | Долгосрочная память агента | Скопировать |
| `workspace\` | Рабочие файлы агента | Скопировать (опционально) |

### Текущие настройки OpenClaw
```
Модель:              deepseek/deepseek-v4-pro
Telegram enabled:    true
Telegram plugin:     true
Allowed user ID:     1064521326
Telegram bot:        @foresight_project_openclaw_bot
Gateway port:        18789 (ws://127.0.0.1:18789)
Sessions:            5 активных
```

### MCP серверы OpenClaw
```
mcp-market:  URL-based  https://link.mcpmarket.com/vfvf6462/toolkits/my-toolkit/mcp
miro:        URL-based  https://link.mcpmarket.com/vfvf6462/miro/mcp
Токен:       ~\.openclaw\secrets\mcp-market-token.txt
```

### КРИТИЧНО: правило записи openclaw.json
```
⚠️ НИКОГДА не перезаписывать openclaw.json через PowerShell ConvertFrom-Json | ConvertTo-Json
   Это уменьшает размер файла → OpenClaw отклоняет как "size-drop" → создаёт .rejected.* файлы
   Изменения только через CLI:
     openclaw config set channels.telegram.enabled true
     openclaw channels add --channel telegram --token-file "<path>"
```

---

## 4. HERMES CONFIG

```
КОНФИГ:   C:\Users\<user>\AppData\Local\hermes\
БЭКАП:    E:\BACKUP_GLOBAL\hermes\   (~116 MB без venv и state.db)
VENV:     C:\Users\<user>\AppData\Local\hermes\hermes-agent\  (~2 GB — восстанавливать с GitHub)
```

### Ключевые файлы

| Файл | Назначение | При восстановлении |
|------|-----------|-------------------|
| `config.yaml` | Главный конфиг Hermes | Скопировать |
| `.env` | **Все API ключи** (58 переменных) | Скопировать в первую очередь |
| `auth.json` | Авторизация | Скопировать |
| `SOUL.md` | Системный промпт (~85 KB) | Скопировать |
| `state.db` | База состояния (~15 MB) | Опционально (история чатов) |
| `gateway.pid` / `gateway.lock` | PID запущенного gateway | НЕ копировать (создаётся при запуске) |
| `hermes-agent\` | Исполняемый код + venv | НЕ копировать — клонировать с GitHub |

### Ключи в `hermes/.env` (все переменные)
```
API ПРОВАЙДЕРЫ:
  ANTHROPIC_API_KEY       — Claude API
  DEEPSEEK_API_KEY        — DeepSeek API  ← shared с OpenClaw
  OPENAI_API_KEY          — OpenAI
  GEMINI_API_KEY          — Google Gemini
  GROQ_API_KEY            — Groq
  OPENROUTER_API_KEY      — OpenRouter
  REPLICATE_API_KEY       — Replicate (image/video gen)
  RUNWAY_API_KEY          — Runway (video)
  ELEVENLABS_API_KEY      — ElevenLabs (TTS)
  PERPLEXITY_API_KEY      — Perplexity search
  FIRECRAWL_API_KEY       — Firecrawl (web)
  APIFY_TOKEN             — Apify (scraping)
  GITHUB_TOKEN            — GitHub API
  CREWAI_API_KEY          — CrewAI
  HELICONE_API_KEY        — Helicone (LLM monitoring)
  LANGSMITH_API_KEY / LANGSMITH_SERVICE_KEY
  LANGGRAPH_API_KEY
  MASTRA_API_KEY / MASTRA_SERVER_URL
  SMITHERY_API_KEY        — Smithery MCP

БАЗЫ ДАННЫХ:
  SUPABASE_URL / SUPABASE_ANON_KEY / SUPABASE_SECRET_KEY
  SUPABASE_SERVICE_ROLE_KEY / SUPABASE_PAT / SUPABASE_PUBLISHABLE_KEY
  CHROMA_API_KEY / CHROMA_HOST / CHROMA_DATABASE / CHROMA_TENANT
  PINECONE_API_KEY
  QDRANT_API_KEY / QDRANT_URL
  REDIS_API_KEY
  MCP_SUPABASE_API_KEY

ИНТЕГРАЦИИ:
  NOTION_API_KEY / NOTION_TOKEN / MCP_MARKET_NOTION_KEY
  MCP_MARKET_API_KEY      — MCP Market  ← shared с OpenClaw
  VERCEL_API_KEY
  YOUGILE_API_KEY
  POSTMYPOST_API_KEY

TELEGRAM:
  TELEGRAM_BOT_TOKEN      — токен Hermes-бота
  TELEGRAM_ALLOWED_USERS  — список разрешённых user ID (1064521326)
```

### Hermes GitHub
```
Репозиторий: https://github.com/Vanquish101101/Hermes-DeepSeek-v4-Telegram.git
Последний коммит: 3845a40 — Видео-пайплайн обёрнут в MCP | version 0.3.17

Восстановление venv на новом диске:
  git clone https://github.com/Vanquish101101/Hermes-DeepSeek-v4-Telegram.git
  cd "Hermes + DeepSeek v4 + Telegram"
  python -m venv venv
  .\venv\Scripts\activate
  pip install -e .
  # затем скопировать .env из E:\BACKUP_GLOBAL\hermes\.env
```

---

## 5. CLAUDE CODE GLOBAL CONFIG

```
КОНФИГ:   C:\Users\<user>\.claude\
БЭКАП:    E:\BACKUP_GLOBAL\.claude\    (~380 MB)
ФАЙЛ:     C:\Users\<user>\.claude.json (~87 KB)
БЭКАП:    E:\BACKUP_GLOBAL\.claude.json
```

### MCP серверы Claude Code (из `~\.claude.json`)

| MCP Сервер | Тип | Команда / URL |
|------------|-----|---------------|
| **supabase** | stdio | `npx @supabase/mcp-server-supabase@latest` |
| **smithery** | http | `https://server.smithery.ai/smithery/mcp` |
| **apify** | stdio | `npx @apify/actors-mcp-server` |
| **perplexity** | stdio | `npx server-perplexity-ask` |
| **firecrawl** | stdio | `npx firecrawl-mcp` |
| **whisper** | stdio | `node` (локальный) |
| **n8n** | http | `https://vanquish.app.n8n.cloud/mcp-server/http` |
| **knowledge-factory** | stdio | `E:\Digital brain\Цифровой мозг\...python.exe -m kf.mcp_server` |

### Telegram канал Claude Code

| Параметр | Значение |
|----------|----------|
| Токен файл | `~\.claude\channels\telegram\.env` (TELEGRAM_BOT_TOKEN) |
| Access file | `~\.claude\channels\telegram\access.json` |
| Bot username | @foresight_project_claudecode_bot |
| Работающий режим | Legacy bridge (Scheduled Task "Claude Code Telegram Bot") |
| ⚠️ Проблема | Токен намеренно убран из `.env` во избежание 409 Conflict — реальный токен в `Claude code + Telegram Telemost\.claude-telegram\.env` |

### Связанный проект
```
C:\Users\Unknown\Documents\Projects\Claude code + Telegram Telemost\
  .claude-telegram\.env     — TELEGRAM_BOT_TOKEN + ANTHROPIC_API_KEY (рабочий)
  scripts\run-claude-telegram-forever.ps1  — wrapper (вызывается Scheduled Task)
```

---

## 6. СВЯЗАННЫЕ РЕСУРСЫ ВНЕ WINDOWS

### Digital Brain (MCP knowledge-factory)
```
ПУТЬ:   E:\Digital brain\Цифровой мозг (digital-brain)\
VENV:   E:\Digital brain\Цифровой мозг (digital-brain)\.venv\Scripts\python.exe
MCP:    python -m kf.mcp_server
```
⚠️ При переезде: путь прописан в `~\.claude.json` → обновить после смены диска

### n8n Cloud
```
URL:    https://vanquish.app.n8n.cloud/mcp-server/http
Тип:    облачный — не нужно переносить, но токен должен быть в Claude .env
```

### MCP Market
```
URL toolkit:  https://link.mcpmarket.com/vfvf6462/toolkits/my-toolkit/mcp
URL miro:     https://link.mcpmarket.com/vfvf6462/miro/mcp
Токен:        ~\.openclaw\secrets\mcp-market-token.txt (скопирован на E:)
```

---

## 7. TELEGRAM БОТЫ — ПОЛНЫЙ РЕЕСТР

| Бот | Username | Токен хранится | User ID | Статус |
|-----|----------|----------------|---------|--------|
| OpenClaw | @foresight_project_openclaw_bot | `~\.openclaw\secrets\telegram-bot-token.txt` | 1064521326 | ✅ |
| Claude Code | @foresight_project_claudecode_bot | `Projects\Claude code + Telegram Telemost\.claude-telegram\.env` | — | ✅ |
| Hermes | (не указан) | `%LOCALAPPDATA%\hermes\.env` → TELEGRAM_BOT_TOKEN | 1064521326 | ✅ |

### Проверка Telegram после переезда
```powershell
# 1. OpenClaw
openclaw message send --channel telegram --target 1064521326 --message "Тест с нового диска"

# 2. Hermes
hermes send --to telegram "Тест с нового диска"

# 3. Claude — написать напрямую в Telegram @foresight_project_claudecode_bot

# Диагностика 409 Conflict (два процесса на один токен):
# Убить все процессы → подождать 15 сек → запустить один
```

---

## 8. ПОРЯДОК ВОССТАНОВЛЕНИЯ (новый диск)

```
1. Установить Node.js 24.x
2. npm install -g openclaw @anthropic-ai/claude-code
3. powershell -c "irm bun.sh/install.ps1|iex"
4. Скопировать E:\BACKUP_GLOBAL\.openclaw  → ~\.openclaw
5. Скопировать E:\BACKUP_GLOBAL\.claude    → ~\.claude
6. Скопировать E:\BACKUP_GLOBAL\.claude.json → ~\.claude.json
7. Скопировать E:\BACKUP_GLOBAL\hermes (конфиги) → %LOCALAPPDATA%\hermes
8. git clone Hermes с GitHub → pip install
9. Скопировать E:\Projects\* → новый диск\Projects\*
10. Запустить update-scheduled-task-to-E.ps1 от Администратора
    (или создать задачи заново с новыми путями)
11. Проверить: openclaw status, hermes gateway status
12. Тест Telegram всем трём ботам
```

---

## 9. РАЗМЕРЫ БЭКАПА НА E:

| Папка | Размер | Файлов |
|-------|--------|--------|
| `E:\BACKUP_GLOBAL\.openclaw` | 20.5 MB | 90 |
| `E:\BACKUP_GLOBAL\.claude` | ~380 MB | 7983 |
| `E:\BACKUP_GLOBAL\hermes` | 116 MB | 6222 |
| `E:\BACKUP_GLOBAL\.claude.json` | 87 KB | 1 |
| `E:\Projects\OpenClaw + DeepSeek v4 + Telegram` | 0.06 MB | 17 |
| **ИТОГО** | **~517 MB** | **~14 313** |

> Hermes venv (~2 GB) и state.db (~15 MB) намеренно исключены — восстанавливаются с GitHub

---

> 📎 Связан с: MIGRATION.md, SESSION-RESTORE.md  
> 📎 Скрипт восстановления задачи: `scripts\update-scheduled-task-to-E.ps1`  
> 📎 Бэкап секретов: `E:\BACKUP_GLOBAL\.openclaw\secrets\`
