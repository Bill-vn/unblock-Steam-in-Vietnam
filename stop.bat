@echo off
setlocal
net session >nul 2>&1
if errorlevel 1 (
  powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
  exit /b
)

echo [*] Dung tunnel...
schtasks /End /TN "SteamSplitTunnel" >nul 2>&1
taskkill /IM sing-box.exe /F >nul 2>&1
timeout /t 2 >nul

powershell -NoProfile -Command "Get-NetAdapter -Name 'SteamTun' -ErrorAction SilentlyContinue | Remove-NetAdapter -Confirm:$false -ErrorAction SilentlyContinue" >nul 2>&1

echo [OK] Da dung. Mang tro ve binh thuong (da kiem tra route ben duoi).
powershell -NoProfile -Command "Get-NetRoute -DestinationPrefix '0.0.0.0/0' | Sort-Object RouteMetric | Format-Table InterfaceAlias,NextHop,RouteMetric -AutoSize"
pause
