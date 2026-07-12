========================================================================
                     PC CLEANER & SYSTEM HEALTH CHECK
                             Usage Instructions
========================================================================

This tool is a safe, lightweight, and comprehensive utility script 
designed to clean temporary files, flush network caches, clear browser 
junk, and verify Windows system files for optimal performance.

------------------------------------------------------------------------
   IMPORTANT PRECAUTIONS (BEFORE RUNNING)
------------------------------------------------------------------------

1. CHECK YOUR RECYCLE BIN: 
   Phase 5 will empty your Recycle Bin. Please double-check and restore 
   any files you deleted by mistake before running the script.

2. CLOSE YOUR BROWSERS:
   Close Google Chrome, Microsoft Edge, Brave, and Mozilla Firefox. 
   If they are open, the script will warn you and ask if you want to 
   automatically close them or skip browser cleanup.

3. RUN AS ADMINISTRATOR:
   Many system cleaning commands (like SFC, DISM, Prefetch deletion, 
   and Disk Defragmentation) require administrator rights to run.

------------------------------------------------------------------------
   HOW TO USE
------------------------------------------------------------------------

1. Locate "cleaner.bat" in this directory.
2. Right-click "cleaner.bat" and select "Run as administrator".
3. The interactive menu will open:

   [A] Run ALL phases (Recommended for a full maintenance cycle)
   -------------------------------------------------------------
   [1] Clean Temporary Files
   [2] Clean Windows Update Cache (Resets update services)
   [3] Clean Browser Caches (Frees space from web storage)
   [4] Flush Network Caches & DNS (Fixes connection issues)
   [5] Disk Cleanup & Empty Recycle Bin (Runs Windows Cleanmgr)
   [6] System Health Check (Scans & repairs corrupted Windows files)
   -------------------------------------------------------------
   [0] Exit

4. Press the corresponding key on your keyboard to make your choice.
5. If running a single phase, you will be prompted at the end of the 
   phase to return to the Main Menu [M] or Exit [0].
6. Once the cleanup is complete, restart your computer for the changes
   to take effect.

------------------------------------------------------------------------
   WHAT EACH PHASE DOES
------------------------------------------------------------------------

* PHASE 1: Temporary Files Cleanup
  Cleans Windows and User Temp directories, system Prefetch files, 
  error reports, thumbnail database cache, system log files, and 
  recent file shortcuts.

* PHASE 2: Windows Update Cache
  Temporarily stops the Windows Update and BITS services to clear out 
  corrupted update download files, then safely restarts the services.

* PHASE 3: Browser Caches
  Wipes temporary page resources, GPU caches, and code caches for major 
  browsers. Does NOT delete your personal data, passwords, or bookmarks.

* PHASE 4: Network Cache & DNS
  Flushes DNS records, NetBIOS name cache, and resets your network 
  interface tables to help resolve intermittent internet dropouts.

* PHASE 5: Disk Cleanup & Recycle Bin
  Configures and runs Microsoft's built-in Disk Cleanup utility (`cleanmgr`)
  with targeted profile flags and empties the Recycle Bin.

* PHASE 6: System Health Check (SFC, DISM, Optimize)
  - SFC (System File Checker): Checks system file integrity and repairs
    any damaged system components.
  - DISM: Checks the system image for corruption and repairs the local 
    component store using Windows Update servers.
  - Defrag / Optimize: Runs a TRIM command on SSDs or defragments HDDs 
    based on what drive type your computer uses.
========================================================================
