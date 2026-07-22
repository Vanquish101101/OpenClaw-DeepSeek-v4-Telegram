$ErrorActionPreference = "Continue"

$containerName = "openclaw-bot"
$chatId        = "1064521326"
$tokenFile     = "$env:USERPROFILE\.openclaw\secrets\telegram-bot-token.txt"
$token         = (Get-Content $tokenFile -Raw -ErrorAction SilentlyContinue).Trim()

if (-not $token) {
    Write-Host "[ERROR] Telegram token not found" -ForegroundColor Red
    exit 1
}

$dockerRunning = $false
try {
    docker info 2>&1 | Out-Null
    $dockerRunning = ($LASTEXITCODE -eq 0)
} catch { }

if (-not $dockerRunning) {
    $msg = "Docker Desktop ne zapushen!`n`nZapusti Docker Desktop, zatem:`ncd docker`ndocker-compose up -d"
    Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/sendMessage" `
        -Method Post -Body @{ chat_id = $chatId; text = $msg } | Out-Null
    Write-Host "[ALERT] Docker not running - Telegram notified" -ForegroundColor Red
    exit 0
}

$status = docker inspect --format="{{.State.Running}}" $containerName 2>&1
if ($status -ne "true") {
    $msg = "Konteyner openclaw-bot ne zapushchen!`n`nDlya zapuska:`ncd docker`ndocker-compose up -d"
    Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/sendMessage" `
        -Method Post -Body @{ chat_id = $chatId; text = $msg } | Out-Null
    Write-Host "[ALERT] Container not running - Telegram notified" -ForegroundColor Red
} else {
    Write-Host "[OK] openclaw-bot is running" -ForegroundColor Green
}
