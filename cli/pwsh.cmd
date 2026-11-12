@echo off
REM Shim for environments without PowerShell 7 (pwsh)
powershell.exe -NoProfile -ExecutionPolicy Bypass %*

