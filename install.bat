@echo off
setlocal
cd /d "%~dp0"

net session >nul 2>&1
if errorlevel 1 (
  echo [*] Can quyen Administrator - dang mo lai bang UAC...
  powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
  exit /b
)

set "TARGET=C:\steam-tunnel"
echo [*] Cai vao %TARGET%
if not exist "%TARGET%\bin" mkdir "%TARGET%\bin"

copy /Y "%~dp0bin\sing-box.exe" "%TARGET%\bin\sing-box.exe" >nul
copy /Y "%~dp0bin\wintun.dll"    "%TARGET%\bin\wintun.dll"    >nul
copy /Y "%~dp0config.json"       "%TARGET%\config.json"       >nul
copy /Y "%~dp0start-hidden.vbs"  "%TARGET%\start-hidden.vbs"  >nul
copy /Y "%~dp0stop.bat"          "%TARGET%\stop.bat"          >nul
copy /Y "%~dp0status.bat"        "%TARGET%\status.bat"        >nul
copy /Y "%~dp0uninstall.bat"     "%TARGET%\uninstall.bat"     >nul
copy /Y "%~dp0README.md"         "%TARGET%\README.md"         >nul

schtasks /Create /TN "SteamSplitTunnel" /TR "wscript.exe C:\steam-tunnel\start-hidden.vbs" /SC ONLOGON /RL HIGHEST /F >nul
if errorlevel 1 (
  echo [!] Tao scheduled task that bai.
  pause
  exit /b 1
)

schtasks /Run /TN "SteamSplitTunnel" >nul
echo [*] Dang khoi dong, cho 4 giay...
timeout /t 4 >nul

call "%~dp0status.bat" nopause
echo.
echo [*] Cai dat xong. Hay TAT Steam (thoat han) roi mo lai, sau do thu store.
echo     Log: %TARGET%\sing-box.log
pause
