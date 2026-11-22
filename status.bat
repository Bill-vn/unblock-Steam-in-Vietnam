@echo off
echo === Process sing-box ===
tasklist /FI "IMAGENAME eq sing-box.exe" 2>nul | find /I "sing-box.exe" || echo   (khong chay)
echo.
echo === Adapter SteamTun ===
powershell -NoProfile -Command "Get-NetAdapter -Name SteamTun -ErrorAction SilentlyContinue | Format-Table Name,Status,LinkSpeed,ifIndex -AutoSize"
echo === Scheduled task ===
schtasks /Query /TN "SteamSplitTunnel" /FO LIST 2>nul | findstr /I "TaskName Status"
echo.
echo === Default route (3 cai dau) ===
powershell -NoProfile -Command "Get-NetRoute -DestinationPrefix '0.0.0.0/0' | Sort-Object RouteMetric | Select-Object -First 3 InterfaceAlias,NextHop,RouteMetric | Format-Table -AutoSize"
echo === Log (8 dong cuoi) ===
powershell -NoProfile -Command "Get-Content 'C:\steam-tunnel\sing-box.log' -Tail 8 -ErrorAction SilentlyContinue"
if /I not "%~1"=="nopause" pause
