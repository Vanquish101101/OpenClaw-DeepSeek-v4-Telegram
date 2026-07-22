# OpenClaw + DeepSeek v4 + Telegram

Lokalniy assistent OpenClaw s modelyu DeepSeek v4 Pro, podklyuchennyy k Telegram.

## Kak rabotayet

- **OpenClaw** - lokalniy AI-assistent (komanda `openclaw`)
- **Model** - `deepseek/deepseek-v4-pro` (cherez DeepSeek API)
- **Kanal** - Telegram (token v `~\.openclaw\secrets\telegram-bot-token.txt`)
- **Gateway** - WebSocket server na portu `18789` (`ws://127.0.0.1:18789`)

## Kornevye papki

| Komponent | Put' |
|-----------|------|
| Etot proekt (skripty) | `C:\Users\Unknown\Documents\OpenClaw + DeepSeek v4 + Telegram` |
| OpenClaw system root | `C:\Users\Unknown\.openclaw` |
| Glavnyy konfig | `C:\Users\Unknown\.openclaw\openclaw.json` |
| Telegram token | `C:\Users\Unknown\.openclaw\secrets\telegram-bot-token.txt` |
| DeepSeek API key | `C:\Users\Unknown\.openclaw\secrets\deepseek-api-key.txt` |
| DeepSeek API key (.env) | `C:\Users\Unknown\.openclaw\.env` |
| Workspace | `C:\Users\Unknown\.openclaw\workspace` |
| Sessions | `C:\Users\Unknown\.openclaw\agents\main\sessions` |
| Sistemnye logi | `C:\Users\Unknown\.openclaw\logs` |

## Bystraya proverka

```powershell
.\scripts\check-status.ps1
```

## Zapusk gateway

```powershell
.\scripts\start-openclaw-gateway.ps1
```

Ili napryamuyu:

```powershell
openclaw gateway run --force
```

## Proverka gateway

```powershell
openclaw gateway status
openclaw status
openclaw channels status
```

Dashboard posle zapuska: `http://127.0.0.1:18789/`

## Nastroyka Telegram-kanala

Esli token ne nastroyen ili nuzhen novyy bot:

```powershell
.\scripts\configure-openclaw-telegram.ps1
```

Ili napryamuyu cherez CLI:

```powershell
openclaw channels add --channel telegram --token-file <temp-token-file>
```

## Dostup k Telegram

Razreshennyye Telegram user ID nastroyeny v `openclaw.json`:

```json
"channels": {
  "telegram": {
    "enabled": true,
    "allowFrom": ["1064521326"]
  }
}
```

## MCP servery

Podklyuchennyye MCP servery (v `openclaw.json`):

| Server | URL |
|--------|-----|
| mcp-market | `https://link.mcpmarket.com/vfvf6462/toolkits/my-toolkit/mcp` |
| miro | `https://link.mcpmarket.com/vfvf6462/miro/mcp` |

Proverka:

```powershell
openclaw mcp list
openclaw mcp probe
```

## Diagnostika

```powershell
openclaw doctor
.\scripts\check-status.ps1
```

## Esli chto-to ne rabotayet

1. Gateway ne zapushchen: `.\scripts\start-openclaw-gateway.ps1`
2. Telegram token ne nastroyen: `.\scripts\configure-openclaw-telegram.ps1`
3. Proverit' logi: `Get-Content "$env:LOCALAPPDATA\Temp\openclaw\openclaw-$(Get-Date -Format 'yyyy-MM-dd').log" -Tail 50`
4. Port 18789 zanyat: `openclaw gateway stop`, zatem povtorniy zapusk

## Pravila bezopasnosti

- Sekrety khranit' tol'ko v `~/.openclaw/secrets/` ili `~/.openclaw/.env`
- Token Telegram ne vstavlyat' v README, skripty ili git
