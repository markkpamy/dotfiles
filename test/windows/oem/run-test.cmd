@echo off
rem Desktop launcher for the dotfiles install test.
rem   dockur/windows: the host checkout is shared as Z:.
rem   Hyper-V: vm.ps1 pushes the repo in as C:\dotfiles-src.zip; unpack it first.
if exist "C:\dotfiles-src.zip" (
    echo Unpacking C:\dotfiles-src.zip ...
    if exist "C:\dotfiles-src" rmdir /S /Q "C:\dotfiles-src"
    mkdir "C:\dotfiles-src"
    "%SystemRoot%\System32\tar.exe" -xf "C:\dotfiles-src.zip" -C "C:\dotfiles-src" || (echo Unpacking failed. & pause & exit /b 1)
    del "C:\dotfiles-src.zip"
)

rem Prefer the live copy of run-test.ps1 so edits don't need a new base image.
set "SCRIPT=C:\OEM\run-test.ps1"
if exist "C:\dotfiles-src\test\windows\oem\run-test.ps1" set "SCRIPT=C:\dotfiles-src\test\windows\oem\run-test.ps1"
if exist "Z:\test\windows\oem\run-test.ps1" set "SCRIPT=Z:\test\windows\oem\run-test.ps1"
powershell.exe -NoProfile -ExecutionPolicy Bypass -NoExit -File "%SCRIPT%" %*
