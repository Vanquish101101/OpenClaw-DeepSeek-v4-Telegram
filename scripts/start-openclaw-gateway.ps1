$ErrorActionPreference = "Continue"

$port          = 18789
$configPath    = "$env:USERPROFILE\.openclaw\openclaw.json"
$tokenFilePath = "$env:USERPROFILE\.openclaw\secrets\telegram-bot-token.txt"
$logDir        = "$env:LOCALAPPDATA\Temp\openclaw"
$logFile       = "$logDir\openclaw-$(Get-Date -Format 'yyyy-MM-dd').log"

if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }

Write-Host ""
Write-Host "=== OpenClaw startup check ===" -ForegroundColor Cyan

# 1. Token file must not be empty when Telegram is enabled
$tokenContent = (Get-Content $tokenFilePath -ErrorAction SilentlyContinue) -join ""
$hasTelegramToken = -not [string]::IsNullOrWhiteSpace($tokenContent)
if ($hasTelegramToken) {
    Write-Host "[OK]  Token file OK." -ForegroundColor Green
} else {
    Write-Host "[WARN] OpenClaw Telegram token file is missing or empty." -ForegroundColor Yellow
    Write-Host "       Create a separate OpenClaw bot and run: .\scripts\import-project-settings.ps1 -ConfigureOpenClawTelegram" -ForegroundColor Yellow
}

# 2+3. Config policy:
# DO NOT rewrite openclaw.json from PowerShell. The previous
# ConvertFrom-Json | ConvertTo-Json round-trip dropped empty objects and shrank
# the 11KB config, tripping OpenClaw's config-io guard (size-drop -> rejected,
# generating openclaw.json.rejected.* files). OpenClaw must own its own config.
# Edit channels/plugins via the native CLI instead, e.g.:
#   openclaw config set channels.telegram.enabled true
#   openclaw channels add --channel telegram --token-file "<path>"
# Here we only READ to report current state — never write.
try {
    $cfg = Get-Content $configPath -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
    $tgState = if ($cfg.channels -and $cfg.channels.telegram) { [bool]$cfg.channels.telegram.enabled } else { $false }
    Write-Host "[INFO] openclaw.json read OK. channels.telegram.enabled = $tgState (left unchanged)." -ForegroundColor Cyan
    if ($hasTelegramToken -and -not $tgState) {
        Write-Host "[HINT] Token file present but Telegram channel is off. Enable via native CLI:" -ForegroundColor Yellow
        Write-Host "       openclaw channels add --channel telegram --token-file `"$tokenFilePath`"" -ForegroundColor Yellow
    }
} catch {
    Write-Host "[WARN] Could not read openclaw.json: $_" -ForegroundColor Red
}

# 4. Stop if running, then start fresh
$listener = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue
if ($listener) {
    Write-Host "[..] Gateway running - restarting to apply config." -ForegroundColor Yellow
    openclaw gateway stop 2>&1 | Out-Null
    Start-Sleep -Seconds 2
}

Write-Host "[..] Starting gateway..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-NonInteractive -Command `"openclaw gateway run --force`"" -WindowStyle Hidden
Start-Sleep -Seconds 15

# 5. Verify gateway
try {
    $probe = openclaw gateway status 2>&1
    if ($probe -match "Connectivity probe: ok") {
        Write-Host "[OK]  Gateway is up and reachable." -ForegroundColor Green
    } else {
        Write-Host "[WARN] Gateway probe not confirmed yet. Run: openclaw gateway status" -ForegroundColor Yellow
    }
} catch {
    Write-Host "[WARN] Could not check gateway status: $_" -ForegroundColor Red
}

if ($hasTelegramToken) {
    # 6. Verify Telegram channel in logs
    try {
        $tgLog = Select-String -Path $logFile -Pattern "starting provider" -ErrorAction SilentlyContinue | Select-Object -Last 1
        if ($tgLog) {
            Write-Host "[OK]  Telegram channel started." -ForegroundColor Green
        } else {
            Write-Host "[WARN] Telegram not confirmed in logs. Run: openclaw channels status" -ForegroundColor Yellow
        }
    } catch {}
} else {
    Write-Host "[INFO] OpenClaw Telegram remains disabled until a separate token file is configured." -ForegroundColor Cyan
}

Write-Host ""
Write-Host "=== Done. OpenClaw gateway check complete. ===" -ForegroundColor Cyan
Write-Host ""
