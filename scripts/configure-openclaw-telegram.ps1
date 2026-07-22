$ErrorActionPreference = "Stop"

$openclaw = Get-Command openclaw -ErrorAction Stop
Write-Host "OpenClaw: $($openclaw.Source)" -ForegroundColor Cyan

$secureToken = Read-Host "Paste Telegram Bot Token from @BotFather" -AsSecureString
$bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureToken)
$token = $null
$tmp = $null

try {
  $token = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
  if ([string]::IsNullOrWhiteSpace($token)) {
    throw "Telegram token is empty."
  }

  $tmp = New-TemporaryFile
  Set-Content -LiteralPath $tmp.FullName -Value $token -NoNewline

  openclaw channels add --channel telegram --token-file $tmp.FullName

  Write-Host "`nTelegram channel saved in OpenClaw. Checking status..." -ForegroundColor Green
  openclaw channels status
}
finally {
  if ($bstr -ne [IntPtr]::Zero) {
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
  }
  if ($tmp -and (Test-Path -LiteralPath $tmp.FullName)) {
    Remove-Item -LiteralPath $tmp.FullName -Force
  }
}

