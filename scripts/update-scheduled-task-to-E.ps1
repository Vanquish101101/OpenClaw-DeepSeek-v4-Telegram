# Запускать от имени Администратора!
# Обновляет Scheduled Task "OpenClaw Telegram Gateway" — путь с C: на E:
#
# Использование:
#   Правой кнопкой на PowerShell → "Запуск от имени администратора"
#   затем:  & "E:\Projects\OpenClaw + DeepSeek v4 + Telegram\scripts\update-scheduled-task-to-E.ps1"

$ErrorActionPreference = "Stop"

$taskName  = "OpenClaw Telegram Gateway"
$newScript = 'E:\Projects\OpenClaw + DeepSeek v4 + Telegram\scripts\start-openclaw-gateway.ps1'

Write-Host "=== Updating Scheduled Task: $taskName ===" -ForegroundColor Cyan

# Check admin
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: Run this script as Administrator!" -ForegroundColor Red
    exit 1
}

# Verify the target script exists on E:
if (-not (Test-Path $newScript)) {
    Write-Host "ERROR: Script not found at E: — copy project first!" -ForegroundColor Red
    exit 1
}

# Remove old task
if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
    Write-Host "[OK] Old task removed" -ForegroundColor Green
}

# Create XML and register
$xml = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Description>Запускает OpenClaw gateway с Telegram при входе в систему (E: drive)</Description>
  </RegistrationInfo>
  <Triggers>
    <LogonTrigger><Enabled>true</Enabled></LogonTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <UserId>$env:USERDOMAIN\$env:USERNAME</UserId>
      <LogonType>InteractiveToken</LogonType>
      <RunLevel>HighestAvailable</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
    <ExecutionTimeLimit>PT0S</ExecutionTimeLimit>
    <Enabled>true</Enabled>
    <RestartOnFailure>
      <Interval>PT1M</Interval>
      <Count>3</Count>
    </RestartOnFailure>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>powershell.exe</Command>
      <Arguments>-NonInteractive -WindowStyle Hidden -ExecutionPolicy Bypass -File "$newScript"</Arguments>
    </Exec>
  </Actions>
</Task>
"@

$xmlPath = "$env:TEMP\openclaw-task-e.xml"
[System.IO.File]::WriteAllText($xmlPath, $xml, [System.Text.Encoding]::Unicode)

$result = schtasks /Create /TN $taskName /XML $xmlPath /F 2>&1
Remove-Item $xmlPath -Force -ErrorAction SilentlyContinue

if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Task created successfully pointing to E:" -ForegroundColor Green
} else {
    Write-Host "[ERROR] $result" -ForegroundColor Red
    exit 1
}

Write-Host "`n=== Verification ===" -ForegroundColor Cyan
schtasks /Query /TN $taskName /FO LIST /V | Select-String "Task To Run|Scheduled Task State|Status"

Write-Host "`nDone. Task will launch from E: on next logon." -ForegroundColor Green
Write-Host "Test now: powershell.exe -File '$newScript'"
