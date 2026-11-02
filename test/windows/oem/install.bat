@echo off
rem Runs once, at the end of the unattended Windows install (dockur/windows /oem hook).
rem Deliberately installs nothing: the golden image must stay a clean Windows.
rem It only drops a launcher on the shared desktop.
copy /Y "C:\OEM\run-test.cmd" "C:\Users\Public\Desktop\Run dotfiles test.cmd"
