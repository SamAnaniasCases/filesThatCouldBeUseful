@echo off
setlocal enabledelayedexpansion
title PC Cleaner & Health Check
color 0A

:: ============================================================
::  PC Cleaner & Health Check Script
::  - Cleans temp files, caches, and logs
::  - Flushes DNS and resets network cache
::  - Cleans browser caches
::  - Runs Disk Cleanup
::  - Runs system health checks (SFC, DISM)
::  - Optimizes drives (defrag HDD / TRIM SSD)
::  Requires: Run as Administrator
:: ============================================================

:: -----------------------------------------------------------
::  Check for Administrator privileges
:: -----------------------------------------------------------
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo  ============================================
    echo   ERROR: This script must be Run as Admin!
    echo  ============================================
    echo.
    echo   Right-click cleaner.bat and select
    echo   "Run as administrator"
    echo.
    pause
    exit /b 1
)

:: -----------------------------------------------------------
::  Track which phases were run (for summary)
:: -----------------------------------------------------------
set "DID_1=0"
set "DID_2=0"
set "DID_3=0"
set "DID_4=0"
set "DID_5=0"
set "DID_6=0"

:: -----------------------------------------------------------
::  MAIN MENU
:: -----------------------------------------------------------
:menu
cls
color 0A
echo.
echo  =====================================================
echo.
echo       ____  ______   ____  __                        
echo      / __ \/ ____/  / __ \/ /__  ____ _____  ___  _____
echo     / /_/ / /      / /   / / _ \/ __ `/ __ \/ _ \/ ___/
echo    / ____/ /___   / /___/ /  __/ /_/ / / / /  __/ /    
echo   /_/    \____/   \____/_/\___/\__,_/_/ /_/\___/_/     
echo.
echo  =====================================================
echo       PC Cleaner ^& Health Check
echo  =====================================================
echo.
echo   Select an option:
echo.
echo   -----------------------------------------------
echo    [A]  Run ALL phases (full cleanup)
echo   -----------------------------------------------
echo    [1]  Clean Temporary Files
echo    [2]  Clean Windows Update Cache
echo    [3]  Clean Browser Caches
echo    [4]  Flush Network Caches ^& DNS
echo    [5]  Disk Cleanup ^& Empty Recycle Bin
echo    [6]  System Health Check (SFC, DISM, Optimize)
echo   -----------------------------------------------
echo    [0]  Exit
echo   -----------------------------------------------
echo.
choice /c A1234560 /n /m "  Your choice: "

if %errorlevel% equ 1 goto :run_all
if %errorlevel% equ 2 goto :run_1
if %errorlevel% equ 3 goto :run_2
if %errorlevel% equ 4 goto :run_3
if %errorlevel% equ 5 goto :run_4
if %errorlevel% equ 6 goto :run_5
if %errorlevel% equ 7 goto :run_6
if %errorlevel% equ 8 goto :exit_script

:: -----------------------------------------------------------
::  RUN ALL PHASES
:: -----------------------------------------------------------
:run_all
cls
echo.
echo  =============================================
echo       Running Full Cleanup...
echo  =============================================
echo   Started: %date% %time%
echo  =============================================
echo.
call :phase_1
call :phase_2
call :phase_3
call :phase_4
call :phase_5
call :phase_6
goto :summary

:: -----------------------------------------------------------
::  RUN INDIVIDUAL PHASES (then return to menu or summary)
:: -----------------------------------------------------------
:run_1
cls
echo.
call :phase_1
goto :after_single

:run_2
cls
echo.
call :phase_2
goto :after_single

:run_3
cls
echo.
call :phase_3
goto :after_single

:run_4
cls
echo.
call :phase_4
goto :after_single

:run_5
cls
echo.
call :phase_5
goto :after_single

:run_6
cls
echo.
call :phase_6
goto :after_single

:: -----------------------------------------------------------
::  After a single phase: ask to go back or exit
:: -----------------------------------------------------------
:after_single
echo.
echo  -----------------------------------------------
echo   [M] Back to Menu    [0] Exit
echo  -----------------------------------------------
echo.
choice /c M0 /n /m "  Your choice: "
if %errorlevel% equ 1 goto :menu
if %errorlevel% equ 2 goto :summary

:: ============================================================
::  PHASE 1: Temporary Files Cleanup
:: ============================================================
:phase_1
set "DID_1=1"
echo  =============================================
echo   [1/6] Cleaning Temporary Files...
echo  =============================================
echo.

echo   - Clearing Windows Temp...
del /s /f /q "C:\Windows\Temp\*" >nul 2>&1
for /d %%x in ("C:\Windows\Temp\*") do rmdir /s /q "%%x" >nul 2>&1

echo   - Clearing User Temp...
del /s /f /q "%TEMP%\*" >nul 2>&1
for /d %%x in ("%TEMP%\*") do rmdir /s /q "%%x" >nul 2>&1

echo   - Clearing Prefetch...
del /s /f /q "C:\Windows\Prefetch\*" >nul 2>&1

echo   - Clearing Windows Error Reports...
del /s /f /q "%LOCALAPPDATA%\Microsoft\Windows\WER\*" >nul 2>&1
for /d %%x in ("%LOCALAPPDATA%\Microsoft\Windows\WER\*") do rmdir /s /q "%%x" >nul 2>&1

echo   - Clearing Thumbnail Cache...
del /s /f /q "%LOCALAPPDATA%\Microsoft\Windows\Explorer\thumbcache_*.db" >nul 2>&1

echo   - Clearing Windows Log Files...
del /s /f /q "C:\Windows\Logs\CBS\*.log" >nul 2>&1
del /s /f /q "C:\Windows\Logs\DISM\*.log" >nul 2>&1

echo   - Clearing Recent Files List...
del /s /f /q "%APPDATA%\Microsoft\Windows\Recent\*" >nul 2>&1

echo.
echo   [Phase 1] Done.
echo.
goto :eof

:: ============================================================
::  PHASE 2: Windows Update Cache
:: ============================================================
:phase_2
set "DID_2=1"
echo  =============================================
echo   [2/6] Cleaning Windows Update Cache...
echo  =============================================
echo.

echo   - Stopping Windows Update service...
net stop wuauserv >nul 2>&1
net stop bits >nul 2>&1

echo   - Clearing SoftwareDistribution downloads...
del /s /f /q "C:\Windows\SoftwareDistribution\Download\*" >nul 2>&1
for /d %%x in ("C:\Windows\SoftwareDistribution\Download\*") do rmdir /s /q "%%x" >nul 2>&1

echo   - Starting Windows Update service...
net start bits >nul 2>&1
net start wuauserv >nul 2>&1

echo.
echo   [Phase 2] Done.
echo.
goto :eof

:: ============================================================
::  PHASE 3: Browser Caches
:: ============================================================
:phase_3
set "DID_3=1"
echo  =============================================
echo   [3/6] Cleaning Browser Caches...
echo  =============================================
echo.

:: Detect running browsers
set "BROWSER_RUNNING=0"
set "RUNNING_LIST="
tasklist /FI "IMAGENAME eq chrome.exe" 2>nul | find /i "chrome.exe" >nul && (set "BROWSER_RUNNING=1" & set "RUNNING_LIST=!RUNNING_LIST! Chrome")
tasklist /FI "IMAGENAME eq msedge.exe" 2>nul | find /i "msedge.exe" >nul && (set "BROWSER_RUNNING=1" & set "RUNNING_LIST=!RUNNING_LIST! Edge")
tasklist /FI "IMAGENAME eq brave.exe" 2>nul | find /i "brave.exe" >nul && (set "BROWSER_RUNNING=1" & set "RUNNING_LIST=!RUNNING_LIST! Brave")
tasklist /FI "IMAGENAME eq firefox.exe" 2>nul | find /i "firefox.exe" >nul && (set "BROWSER_RUNNING=1" & set "RUNNING_LIST=!RUNNING_LIST! Firefox")

if "!BROWSER_RUNNING!"=="1" (
    echo.
    echo   *** WARNING: The following browsers are open: ***
    echo      !RUNNING_LIST!
    echo.
    echo   Browser cache cleanup works best when browsers
    echo   are closed. Open browsers may lock cache files.
    echo.
    echo   [C] Close browsers and continue cleanup
    echo   [S] Skip browser cache cleanup
    echo   [K] Continue anyway (keep browsers open)
    echo.
    choice /c CSK /n /m "   Your choice: "
    if !errorlevel! equ 1 (
        echo.
        echo   Closing browsers...
        taskkill /f /im chrome.exe >nul 2>&1
        taskkill /f /im msedge.exe >nul 2>&1
        taskkill /f /im brave.exe >nul 2>&1
        taskkill /f /im firefox.exe >nul 2>&1
        timeout /t 2 /nobreak >nul
        echo   Browsers closed.
        echo.
    )
    if !errorlevel! equ 2 (
        echo   Skipping browser cache cleanup.
        echo.
        goto :eof
    )
)

:: Chrome
if exist "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" (
    echo   - Cleaning Chrome cache...
    rmdir /s /q "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" >nul 2>&1
    rmdir /s /q "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Code Cache" >nul 2>&1
    rmdir /s /q "%LOCALAPPDATA%\Google\Chrome\User Data\Default\GPUCache" >nul 2>&1
)

:: Edge
if exist "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" (
    echo   - Cleaning Edge cache...
    rmdir /s /q "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" >nul 2>&1
    rmdir /s /q "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Code Cache" >nul 2>&1
    rmdir /s /q "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\GPUCache" >nul 2>&1
)

:: Brave
if exist "%LOCALAPPDATA%\BraveSoftware\Brave-Browser\User Data\Default\Cache" (
    echo   - Cleaning Brave cache...
    rmdir /s /q "%LOCALAPPDATA%\BraveSoftware\Brave-Browser\User Data\Default\Cache" >nul 2>&1
    rmdir /s /q "%LOCALAPPDATA%\BraveSoftware\Brave-Browser\User Data\Default\Code Cache" >nul 2>&1
    rmdir /s /q "%LOCALAPPDATA%\BraveSoftware\Brave-Browser\User Data\Default\GPUCache" >nul 2>&1
)

:: Firefox
if exist "%APPDATA%\Mozilla\Firefox\Profiles" (
    echo   - Cleaning Firefox cache...
    for /d %%x in ("%APPDATA%\Mozilla\Firefox\Profiles\*") do (
        rmdir /s /q "%%x\cache2" >nul 2>&1
    )
)

echo.
echo   [Phase 3] Done.
echo.
goto :eof

:: ============================================================
::  PHASE 4: Network Cache & DNS
:: ============================================================
:phase_4
set "DID_4=1"
echo  =============================================
echo   [4/6] Flushing Network Caches...
echo  =============================================
echo.

echo   - Flushing DNS resolver cache...
ipconfig /flushdns >nul 2>&1

echo   - Purging ARP cache...
arp -d * >nul 2>&1

echo   - Flushing NetBIOS cache...
nbtstat -R >nul 2>&1

echo.
echo   [Phase 4] Done.
echo.
goto :eof

:: ============================================================
::  PHASE 5: Disk Cleanup & Recycle Bin
:: ============================================================
:phase_5
set "DID_5=1"
echo  =============================================
echo   [5/6] Running Disk Cleanup...
echo  =============================================
echo.

echo   - Emptying Recycle Bin...
PowerShell.exe -NoProfile -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" >nul 2>&1

echo   - Configuring Disk Cleanup profile...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Files" /v StateFlags0099 /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Recycle Bin" /v StateFlags0099 /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Setup Files" /v StateFlags0099 /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Old ChkDsk Files" /v StateFlags0099 /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting Files" /v StateFlags0099 /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Thumbnail Cache" /v StateFlags0099 /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Delivery Optimization Files" /v StateFlags0099 /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Device Driver Packages" /v StateFlags0099 /t REG_DWORD /d 2 /f >nul 2>&1

echo   - Running Disk Cleanup (this may take a moment)...
cleanmgr /sagerun:99 >nul 2>&1

echo.
echo   [Phase 5] Done.
echo.
goto :eof

:: ============================================================
::  PHASE 6: System Health Checks
:: ============================================================
:phase_6
set "DID_6=1"
echo  =============================================
echo   [6/6] Running System Health Checks...
echo  =============================================
echo   This phase may take several minutes.
echo   Please be patient.
echo.

echo   - Running System File Checker (SFC)...
echo     Scanning for corrupted system files...
sfc /scannow 2>nul | findstr /i /c:"verification" /c:"found" /c:"repair" /c:"could not"
echo.

echo   - Running DISM Health Check...
echo     Checking component store health...
DISM /Online /Cleanup-Image /RestoreHealth 2>nul | findstr /i /c:"restore" /c:"error" /c:"component" /c:"successfully"
echo.

echo   - Optimizing drives...
echo     (Defrag for HDD / TRIM for SSD - auto-detected)
defrag %SystemDrive% /O >nul 2>&1
if %errorlevel% equ 0 (
    echo     Drive optimization completed successfully.
) else (
    echo     Drive optimization skipped or not needed.
)

echo.
echo   [Phase 6] Done.
echo.
goto :eof

:: ============================================================
::  SUMMARY
:: ============================================================
:summary
echo.
echo  =============================================
echo       Cleanup Complete!
echo  =============================================
echo   Finished: %date% %time%
echo  =============================================
echo.
echo   What was done:
if "!DID_1!"=="1" echo    [x] Temp files cleared
if "!DID_1!"=="0" echo    [ ] Temp files (skipped)
if "!DID_2!"=="1" echo    [x] Windows Update cache cleared
if "!DID_2!"=="0" echo    [ ] Windows Update cache (skipped)
if "!DID_3!"=="1" echo    [x] Browser caches cleared
if "!DID_3!"=="0" echo    [ ] Browser caches (skipped)
if "!DID_4!"=="1" echo    [x] Network caches flushed
if "!DID_4!"=="0" echo    [ ] Network caches (skipped)
if "!DID_5!"=="1" echo    [x] Disk Cleanup + Recycle Bin emptied
if "!DID_5!"=="0" echo    [ ] Disk Cleanup (skipped)
if "!DID_6!"=="1" echo    [x] System health check (SFC, DISM, Optimize)
if "!DID_6!"=="0" echo    [ ] System health check (skipped)
echo.
echo  =============================================
echo   TIP: Restart your PC for best results.
echo  =============================================
echo.
echo  Press any key to exit...
pause >nul

:exit_script
endlocal
exit
