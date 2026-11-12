@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0mo.ps1" -Tk %1 %2 %3 %4 %5
if errorlevel 1 pause
