@echo off
REM Runs the VidyaSethu public website (Angular) at http://localhost:4300 - independent of the PVS API and app
cd /d "%~dp0..\Frontend\VidyaSethuWeb"
if not exist node_modules (
    echo Installing packages - first run only...
    call npx -y npm@11 install
)
call npx ng serve --open
pause
