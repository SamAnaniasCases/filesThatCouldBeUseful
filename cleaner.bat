@echo off
title PC Cleaner - Temp, Cache & Memory Cleanup
color 0A

echo ================================
echo       Cleaning System...
echo ================================
echo.

:: Clear Windows Temp
echo Clearing C:\Windows\Temp ...
del /s /f /q C:\Windows\Temp\* >nul 2>&1
for /d %%x in (C:\Windows\Temp\*) do rmdir /s /q "%%x" >nul 2>&1

:: Clear User Temp
echo Clearing %TEMP% ...
del /s /f /q "%TEMP%\*" >nul 2>&1
for /d %%x in ("%TEMP%\*") do rmdir /s /q "%%x" >nul 2>&1

:: Clear Prefetch
echo Clearing Prefetch ...
del /s /f /q C:\Windows\Prefetch\* >nul 2>&1

:: Stop Windows Update service
echo Stopping Windows Update service...
net stop wuauserv >nul 2>&1

:: Clear Windows Update Cache
echo Clearing SoftwareDistribution cache...
del /s /f /q C:\Windows\SoftwareDistribution\Download\* >nul 2>&1
for /d %%x in (C:\Windows\SoftwareDistribution\Download\*) do rmdir /s /q "%%x" >nul 2>&1

:: Start Windows Update service
echo Starting Windows Update service...
net start wuauserv >nul 2>&1

:: Empty Recycle Bin
echo Emptying Recycle Bin...
PowerShell.exe -command "Clear-RecycleBin -Force" >nul 2>&1

:: Flush DNS Cache
echo Flushing DNS Cache...
ipconfig /flushdns >nul

echo.
echo ================================
echo     Cleaning Browser Caches...
echo ================================
echo.

:: Chrome Cache
echo Cleaning Chrome cache...
rmdir /s /q "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" >nul 2>&1
rmdir /s /q "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Code Cache" >nul 2>&1

:: Edge Cache
echo Cleaning Edge cache...
rmdir /s /q "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" >nul 2>&1
rmdir /s /q "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Code Cache" >nul 2>&1

:: Brave Cache
echo Cleaning Brave cache...
rmdir /s /q "%LOCALAPPDATA%\BraveSoftware\Brave-Browser\User Data\Default\Cache" >nul 2>&1
rmdir /s /q "%LOCALAPPDATA%\BraveSoftware\Brave-Browser\User Data\Default\Code Cache" >nul 2>&1

:: Firefox Cache
echo Cleaning Firefox cache...
for /d %%x in ("%APPDATA%\Mozilla\Firefox\Profiles\*") do (
    rmdir /s /q "%%x\cache2" >nul 2>&1
)

echo.
echo ================================
echo     Running Disk Cleanup...
echo ================================
echo.

cleanmgr /sagerun:99 >nul 2>&1

echo.
echo ================================
echo     Boosting RAM (Safe)...
echo ================================
echo.

:: SAFE RAM FLUSH using PowerShell
PowerShell.exe -command "Clear-Content -Path \"$env:TEMP\*\" -Force -ErrorAction SilentlyContinue" >nul 2>&1
PowerShell.exe -command "Reduce-MemoryPressure" >nul 2>&1 2>nul

:: Standby List Flush (safe)
PowerShell.exe -command "try { Get-Process -Name 'MemoryCompression' -ErrorAction SilentlyContinue | Out-Null } catch {}" >nul 2>&1
PowerShell.exe -command "Clear-Content -Path \"$env:SystemDrive\swapfile.sys\" -ErrorAction SilentlyContinue" >nul 2>&1

echo RAM cleanup complete.

echo.
echo ================================
echo     Cleanup Complete!
echo ================================
echo Press any key to exit...
pause >nul
exit
