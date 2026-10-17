@echo off
REM Runs the web admin portal (Angular) at http://localhost:4200 - start the API first (RunBackend\Start_Backend_API.bat)
cd /d "%~dp0..\Frontend\AdminWeb"
if not exist node_modules (
    echo Installing packages - first run only...
    call npx -y npm@11 install
)
call npx ng serve --open
pause
