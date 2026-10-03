@echo off
chcp 65001 > nul
title UniMarket Backend (Django API)

echo ========================================================
echo        🚀 UniMarket Backend (Django REST API)
echo ========================================================
echo.

if exist "%~dp0backend" (
    cd /d "%~dp0backend"
) else if exist "%~dp0..\backend" (
    cd /d "%~dp0..\backend"
)

echo [1/3] Syncing uv dependencies and checking migrations...
uv sync
uv run manage.py migrate

echo [2/3] Checking OIDC keys and initial seed data...
uv run manage.py seed_data

echo [3/3] Starting Django API server at http://127.0.0.1:8000 ...
echo [INFO] Press Ctrl+C to stop the backend.
echo.

uv run manage.py runserver 127.0.0.1:8000

pause
