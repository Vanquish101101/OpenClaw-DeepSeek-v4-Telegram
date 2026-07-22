$ErrorActionPreference = "Continue"

Write-Host "=== OpenClaw + DeepSeek v4 + Telegram: Status Check ===" -ForegroundColor Cyan

Write-Host "`n-- openclaw command --" -ForegroundColor Yellow
Get-Command openclaw -ErrorAction SilentlyContinue | Select-Object Name, Source, Version | Format-Table -AutoSize

Write-Host "-- OpenClaw process --" -ForegroundColor Yellow
Get-Process | Where-Object { $_.ProcessName -match "openclaw" } |
  Select-Object ProcessName, Id, Path | Format-Table -AutoSize

Write-Host "-- Port 18789 (gateway) --" -ForegroundColor Yellow
$port = Get-NetTCPConnection -LocalPort 18789 -ErrorAction SilentlyContinue
if ($port) {
    $port | Select-Object LocalAddress, LocalPort, State, OwningProcess | Format-Table -AutoSize
} else {
    Write-Host "Port 18789 is NOT listening. Run: .\scripts\start-openclaw-gateway.ps1" -ForegroundColor Red
}

Write-Host "-- openclaw status --" -ForegroundColor Yellow
openclaw status

Write-Host "-- openclaw channels --" -ForegroundColor Yellow
openclaw channels status

Write-Host "-- Telegram token file --" -ForegroundColor Yellow
$tokenFile = "$env:USERPROFILE\.openclaw\secrets\telegram-bot-token.txt"
if (Test-Path $tokenFile) {
    $content = (Get-Content $tokenFile -Raw).Trim()
    if ($content.Length -gt 10) {
        Write-Host "Token file OK (length: $($content.Length) chars)" -ForegroundColor Green
    } else {
        Write-Host "Token file exists but looks empty or too short!" -ForegroundColor Red
    }
} else {
    Write-Host "Token file NOT FOUND: $tokenFile" -ForegroundColor Red
    Write-Host "Run: .\scripts\configure-openclaw-telegram.ps1" -ForegroundColor Yellow
}

Write-Host "-- DeepSeek API key --" -ForegroundColor Yellow
$deepseekKey = "$env:USERPROFILE\.openclaw\secrets\deepseek-api-key.txt"
if (Test-Path $deepseekKey) {
    Write-Host "DeepSeek key file: OK" -ForegroundColor Green
} else {
    Write-Host "DeepSeek key file not found: $deepseekKey" -ForegroundColor Red
}

Write-Host "-- openclaw.json model --" -ForegroundColor Yellow
try {
    $cfg = Get-Content "$env:USERPROFILE\.openclaw\openclaw.json" -Raw | ConvertFrom-Json
    Write-Host "Primary model: $($cfg.agents.defaults.model.primary)" -ForegroundColor Green
    Write-Host "Telegram enabled: $($cfg.channels.telegram.enabled)" -ForegroundColor Green
    Write-Host "Telegram plugin: $($cfg.plugins.entries.telegram.enabled)" -ForegroundColor Green
} catch {
    Write-Host "Could not parse openclaw.json: $_" -ForegroundColor Red
}

Write-Host "`n=== Check complete ===" -ForegroundColor Cyan
