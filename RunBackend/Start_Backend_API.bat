@echo off
REM Starts the PVS API on http://localhost:5274 (Development: LocalDB, auto-migrate, dev verification code)
cd /d "%~dp0..\Backend\PadmashaliVidyaSetu.Api"
SqlLocalDB start MSSQLLocalDB >nul 2>&1
dotnet run --launch-profile http
pause
