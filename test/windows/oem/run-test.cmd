@echo off
rem Prefer the live copy on Z: so edits to run-test.ps1 don't need a new golden image.
set "SCRIPT=Z:\test\windows\oem\run-test.ps1"
if not exist "%SCRIPT%" set "SCRIPT=C:\OEM\run-test.ps1"
powershell.exe -NoProfile -ExecutionPolicy Bypass -NoExit -File "%SCRIPT%" %*
