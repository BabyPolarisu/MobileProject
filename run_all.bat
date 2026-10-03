@echo off
chcp 65001 > nul
title UniMarket Full-Stack Launcher

echo ========================================================
echo   UniMarket Full-Stack Launcher (Django + Flutter)
echo ========================================================
echo.
echo [1/2] Starting Backend in new window...
start "UniMarket Backend" cmd /k "%~dp0run_backend.bat"

echo.
echo Waiting 3 seconds for backend to initialize...
timeout /t 3 /nobreak > nul

echo.
echo [2/2] Starting Frontend on Chrome Port 50000...
call "%~dp0run_frontend.bat" chrome

pause
