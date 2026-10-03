@echo off
chcp 65001 > nul
title UniMarket Frontend (Flutter)

echo ========================================================
echo        UniMarket Frontend (Flutter Multi-Platform)
echo ========================================================
echo.

cd /d "%~dp0unimarket_flutter"

echo [1/2] Fetching Flutter dependencies
call flutter pub get

if /i "%1"=="chrome" goto run_chrome

echo.
echo ========================================================
echo   Connected Devices:
echo ========================================================
call flutter devices
echo ========================================================
echo.
echo Select target device:
echo   [1] Google Chrome (Web Port 50000 - Recommended for OIDC)
echo   [2] Windows Desktop (.exe)
echo   [3] Microsoft Edge (Web Port 50000)
echo   [4] Enter custom Device ID from the list above
echo.
set choice=1
set /p choice=Select device number (Default [1] Chrome): 

if "%choice%"=="2" goto run_windows
if "%choice%"=="3" goto run_edge
if "%choice%"=="4" goto run_custom
goto run_chrome

:run_windows
echo [2/2] Launching UniMarket on Windows Desktop...
flutter run -d windows
goto end

:run_edge
echo [2/2] Launching UniMarket on Edge (Port 50000 for OIDC)...
flutter run -d edge --web-port 50000
goto end

:run_custom
echo.
set /p devid=Enter Device ID: 
flutter run -d %devid%
goto end

:run_chrome
echo [2/2] Launching UniMarket on Chrome (Port 50000 for OIDC)...
flutter run -d chrome --web-port 50000
goto end

:end
pause
