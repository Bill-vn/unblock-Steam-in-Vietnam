@echo off
setlocal
net session >nul 2>&1
if errorlevel 1 (
  echo [*] Can quyen Administrator - dang mo lai bang UAC...
  powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
  exit /b
)

echo [1/4] Dung tunnel...
schtasks /End /TN "SteamSplitTunnel" >nul 2>&1
taskkill /IM sing-box.exe /F >nul 2>&1
timeout /t 2 >nul

echo [2/4] Xoa scheduled task...
schtasks /Delete /TN "SteamSplitTunnel" /F >nul 2>&1

echo [3/4] Xoa adapter SteamTun (neu con)...
powershell -NoProfile -Command "Get-NetAdapter -Name 'SteamTun' -ErrorAction SilentlyContinue | Remove-NetAdapter -Confirm:$false -ErrorAction SilentlyContinue" >nul 2>&1

echo [4/4] Xoa thu muc C:\steam-tunnel...
rmdir /S /Q "C:\steam-tunnel" 2>nul

echo.
echo [OK] Da go hoan toan: khong con task, khong con adapter, khong con file.
echo      Route hien tai:
powershell -NoProfile -Command "Get-NetRoute -DestinationPrefix '0.0.0.0/0' | Sort-Object RouteMetric | Format-Table InterfaceAlias,NextHop,RouteMetric -AutoSize"
pause
