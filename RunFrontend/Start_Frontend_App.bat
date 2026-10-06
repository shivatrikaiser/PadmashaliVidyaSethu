@echo off
REM Runs the Flutter app on the first available device (start an Android emulator first)
cd /d "%~dp0..\Frontend\padmashali_vidya_setu"
flutter run --dart-define-from-file=config/development.json
pause
