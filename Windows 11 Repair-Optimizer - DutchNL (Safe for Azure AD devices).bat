@echo off
:: Set a friendly color: Black background (0) with Aqua text (B)
color 0B

:: Initialize variables
set AUTO=0

title Windows 11 Repair/Optimizer - Dutch/NL (Safe for Azure AD devices)
echo ===================================================================================
echo -     Windows 11 Repair/Optimizer - Dutch/NL                                      -
echo -         (Safe for Azure AD devices)                                          -
echo -                                                                                 -
echo -                                                    Ontwikkeld door ambry/kubaam -
echo -                                                      Aangepast door Sander Behr -
echo ===================================================================================
echo.
echo WAARSCHUWING:
Echo Dit script wijzigt systeeminstellingen en registersleutels.
echo Automatisch systeemherstelpunt wordt daarom voor u gemaakt
echo.
:: Controleer op beheerdersrechten
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Dit script moet als beheerder worden uitgevoerd.
    pause
    exit /b
)
    echo [INFO] Herstelpunt maken... Sluit powershell na aanmaken herstelpunt
start powershell -ExecutionPolicy Bypass -NoExit -Command "Checkpoint-Computer -Description 'Windows 11 repair/optimizer' -RestorePointType 'MODIFY_SETTINGS'"
    timeout /t 20 >nul
)

:MainMenu
cls
echo ============================================================
echo         Windows 11 Tweaks Main Menu
echo ============================================================
echo.
echo 1. Beschadigde Windows-systeembestanden repareren
echo 2. Windows update problemen oplossen
echo 3. Microsoft Store repareren en apps opnieuw registreren
echo 4. Maximale Prestatie toepassen
echo 5. Vooraf geinstalleerde windows apps (bloatware) verwijderen
echo 6. Netwerk problemen oplossen
echo 7. Herstart Systeem (Advies!)
echo 8. Exit
echo.
set /p option="Enter your choice (1-8): "

if "%option%"=="1" goto SFC_DISM
if "%option%"=="2" goto WindowsUpdateReset
if "%option%"=="3" goto StoreRepair
if "%option%"=="4" goto PerformanceTweaks
if "%option%"=="5" goto RemovePreApps
if "%option%"=="6" goto NetworkFixes
if "%option%"=="7" goto RebootSystem
if "%option%"=="8" goto ExitScript
echo Invalid option.
pause
goto MainMenu

:SFC_DISM
cls
echo ============================================================
echo       Beschadigde Windows-systeembestanden repareren
echo ============================================================
echo.
call :ConfirmMode
if "%AUTO%"=="0" (
    call :AskAndRun "Running System File Checker (SFC /scannow)" "sfc /scannow"
    call :AskAndRun "Running DISM scanhealth" "dism /online /cleanup-image /scanhealth"
    call :AskAndRun "Running DISM checkhealth" "dism /online /cleanup-image /checkhealth"
    call :AskAndRun "Running DISM restorehealth" "dism /online /cleanup-image /restorehealth"
) else (
    echo [INFO] Beschadigde Windows-systeembestanden repareren...
    sfc /scannow
    echo [INFO] Running DISM scanhealth...
    dism /online /cleanup-image /scanhealth
    echo [INFO] Running DISM checkhealth...
    dism /online /cleanup-image /checkhealth
    echo [INFO] Running DISM restorehealth...
    dism /online /cleanup-image /restorehealth
)
echo [INFO] Windows is gecontroleerd op corrupte bestanden, automatisch gerepareerd waarnodig.
pause
goto MainMenu

:WindowsUpdateReset
cls
echo ============================================================
echo	Windows update problemen oplossen
echo ============================================================
call :ConfirmMode
if "%AUTO%"=="0" (
    call :AskAndRun "Stopping Windows Update services" "net stop wuauserv >nul 2>&1 && net stop cryptSvc >nul 2>&1 && net stop bits >nul 2>&1 && net stop msiserver >nul 2>&1"
    call :AskAndRun "Deleting SoftwareDistribution folder" "rd /s /q %systemroot%\SoftwareDistribution >nul 2>&1"
    call :AskAndRun "Deleting catroot2 folder" "rd /s /q %systemroot%\system32\catroot2 >nul 2>&1"
    call :AskAndRun "Restarting Windows Update services" "net start wuauserv >nul 2>&1 && net start cryptSvc >nul 2>&1 && net start bits >nul 2>&1 && net start msiserver >nul 2>&1"
) else (
    echo [INFO] Stopping Windows Update services...
    net stop wuauserv >nul 2>&1
    net stop cryptSvc >nul 2>&1
    net stop bits >nul 2>&1
    net stop msiserver >nul 2>&1
    echo [INFO] Deleting SoftwareDistribution folder...
    rd /s /q %systemroot%\SoftwareDistribution >nul 2>&1
    echo [INFO] Deleting catroot2 folder...
    rd /s /q %systemroot%\system32\catroot2 >nul 2>&1
    echo [INFO] Restarting Windows Update services...
    net start wuauserv >nul 2>&1
    net start cryptSvc >nul 2>&1
    net start bits >nul 2>&1
    net start msiserver >nul 2>&1
)
echo [INFO] Windows update problemen opgelost.
pause
goto MainMenu

:StoreRepair
cls
echo ============================================================
echno	Microsoft Store repareren en opnieuw registreren
echo ============================================================
call :ConfirmMode
if "%AUTO%"=="0" (
    call :AskAndRun "Re-registering Microsoft Store" "powershell -NoProfile -ExecutionPolicy Bypass -command \"Get-AppxPackage *WindowsStore* | Foreach-Object {Add-AppxPackage -DisableDevelopmentMode -Register \\\"$($_.InstallLocation)\\\\AppxManifest.xml\\\"}\""
    call :AskAndRun "Re-registering apps for all users" "powershell -NoProfile -ExecutionPolicy Bypass -command \"Get-AppxPackage -AllUsers | Foreach-Object {Add-AppxPackage -DisableDevelopmentMode -Register \\\"$($_.InstallLocation)\\\\AppxManifest.xml\\\"}\""
) else (
    echo [INFO] Re-registering Microsoft Store...
    powershell -NoProfile -ExecutionPolicy Bypass -command "Get-AppxPackage *WindowsStore* | Foreach-Object {Add-AppxPackage -DisableDevelopmentMode -Register \"$($_.InstallLocation)\\AppxManifest.xml\"}"
    echo [INFO] Re-registering apps for all users...
    powershell -NoProfile -ExecutionPolicy Bypass -command "Get-AppxPackage -AllUsers | Foreach-Object {Add-AppxPackage -DisableDevelopmentMode -Register \"$($_.InstallLocation)\\AppxManifest.xml\"}"
)
echo [INFO] Microsoft Store gerepareerd.
pause
goto MainMenu

:PerformanceTweaks
cls
echo ============================================================
echo		Maximale Prestatie toepassen
echo ============================================================
echo.
call :ConfirmMode
if "%AUTO%"=="0" (
    :: Use safe registry update for performance-related keys.
    call :SafeRegAdd "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" "StartupDelayInMSec" REG_DWORD 0 "Disabling startup delay"
    call :SafeRegAdd "HKLM\SYSTEM\CurrentControlSet\Control" "WaitToKillServiceTimeout" REG_SZ 2000 "Speeding up shutdown (WaitToKillServiceTimeout = 2000ms)"
    call :SafeRegAdd "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" "SystemResponsiveness" REG_DWORD 10 "Prioritizing foreground apps (SystemResponsiveness = 10)"
    call :SafeRegAdd "HKCU\Control Panel\Desktop" "MenuShowDelay" REG_SZ 100 "Reducing menu show delay (MenuShowDelay = 100)"
    call :SafeRegAdd "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" "NetworkThrottlingIndex" REG_DWORD 4294967295 "Disabling network throttling"
    call :AskAndRun "Optimizing HPET and dynamic tick settings" "bcdedit /deletevalue useplatformclock >nul 2>&1 && bcdedit /set disabledynamictick yes >nul 2>&1"
) else (
    echo [INFO] Disabling startup delay...
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" /v StartupDelayInMSec /t REG_DWORD /d 0 /f >nul
    echo [INFO] Speeding up shutdown...
    reg add "HKLM\SYSTEM\CurrentControlSet\Control" /v WaitToKillServiceTimeout /t REG_SZ /d 2000 /f >nul
    echo [INFO] Prioritizing foreground apps...
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v SystemResponsiveness /t REG_DWORD /d 10 /f >nul
    echo [INFO] Reducing menu show delay...
    reg add "HKCU\Control Panel\Desktop" /v MenuShowDelay /t REG_SZ /d 100 /f >nul
    echo [INFO] Disabling network throttling...
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v NetworkThrottlingIndex /t REG_DWORD /d 4294967295 /f >nul
    echo [INFO] Optimizing HPET and dynamic tick settings...
    bcdedit /deletevalue useplatformclock >nul 2>&1
    bcdedit /set disabledynamictick yes >nul 2>&1
)
echo [INFO] Maximale Prestatie toegepast.
pause
goto MainMenu

:RemovePreApps
cls
echo ==========================================================================
echo         Vooraf geinstalleerde windows apps (bloatware) verwijderen
echo ==========================================================================
echo Met deze sectie kunt u een aantal vooraf geinstalleerde apps verwijderen (bijv. Xbox, Bing Nieuws, enz.).
echo WAARSCHUWING: Met deze opdrachten worden apps permanent verwijderd.
echo Wilt u doorgaan? (J/N)
set /p removeapps=
if /i not "%removeapps%"=="Y" (
    echo [INFO] Skipping removal of preinstalled apps.
    pause
    goto MainMenu
)
call :ConfirmMode
if "%AUTO%"=="0" (
    call :AskAndRun "Removing Xbox app" "powershell -NoProfile -ExecutionPolicy Bypass -command \"Get-AppxPackage *xboxapp* | Remove-AppxPackage\""
    call :AskAndRun "Removing Bing News" "powershell -NoProfile -ExecutionPolicy Bypass -command \"Get-AppxPackage *bingnews* | Remove-AppxPackage\""
    call :AskAndRun "Removing Bing Weather" "powershell -NoProfile -ExecutionPolicy Bypass -command \"Get-AppxPackage *bingweather* | Remove-AppxPackage\""
    call :AskAndRun "Removing Zune Video" "powershell -NoProfile -ExecutionPolicy Bypass -command \"Get-AppxPackage *zunevideo* | Remove-AppxPackage\""
    call :AskAndRun "Removing Solitaire Collection" "powershell -NoProfile -ExecutionPolicy Bypass -command \"Get-AppxPackage *solitairecollection* | Remove-AppxPackage\""
) else (
    echo [INFO] Removing preinstalled apps...
    powershell -NoProfile -ExecutionPolicy Bypass -command "Get-AppxPackage *xboxapp* | Remove-AppxPackage"
    powershell -NoProfile -ExecutionPolicy Bypass -command "Get-AppxPackage *bingnews* | Remove-AppxPackage"
    powershell -NoProfile -ExecutionPolicy Bypass -command "Get-AppxPackage *bingweather* | Remove-AppxPackage"
    powershell -NoProfile -ExecutionPolicy Bypass -command "Get-AppxPackage *zunevideo* | Remove-AppxPackage"
    powershell -NoProfile -ExecutionPolicy Bypass -command "Get-AppxPackage *solitairecollection* | Remove-AppxPackage"
)
echo [INFO] geïnstalleerde windows apps (bloatware) verwijderd.
pause
goto MainMenu

:NetworkFixes
cls
echo ============================================================
echo		Netwerk problemen oplossen
echo ============================================================
echo WAARSCHUWING: De netwerkinstellingen worden gereset en de verbinding kan tijdelijk verloren gaan.
call :ConfirmMode
if "%AUTO%"=="0" (
    call :AskAndRun "Resetting TCP/IP stack" "netsh int ip reset >nul"
    call :AskAndRun "Flushing DNS" "ipconfig /flushdns >nul"
    call :AskAndRun "Resetting Winsock" "netsh winsock reset >nul"
    call :AskAndRun "Releasing IP address" "ipconfig /release >nul"
    call :AskAndRun "Renewing IP address" "ipconfig /renew >nul"
) else (
    echo [INFO] Resetting TCP/IP stack...
    netsh int ip reset >nul
    echo [INFO] Flushing DNS...
    ipconfig /flushdns >nul
    echo [INFO] Resetting Winsock...
    netsh winsock reset >nul
    echo [INFO] Releasing IP address...
    ipconfig /release >nul
    echo [INFO] Renewing IP address...
    ipconfig /renew >nul
)
echo [INFO] Netwerk problemen opgelost.
pause
goto MainMenu

:RebootSystem
cls
echo ============================================================
echo             Rebooting System
echo ============================================================
echo Herstart in 5 seconden...
timeout /t 5 >nul
shutdown /r /t 0
goto ExitScript

:ExitScript
echo.
echo Script wordt afgesloten. Bedankt voor het gebruik van Windows 11 Ultimate Fix and Tweaks.
echo Ontwikkeld door ambry/kubaam, aangepast door Sander Behr
pause
exit /b

:: ------------------------------------------------------
:: Subroutine: ConfirmMode
:: Vraagt ​​of de gebruiker alle aanpassingen automatisch wil toepassen (A)
:: of elke aanpassing afzonderlijk wil bevestigen (I).
:ConfirmMode
echo.
echo Wilt u alle aanpassingen in deze categorie automatisch toepassen (A)
echo of elke aanpassing afzonderlijk bevestigen (I)?
choice /C AI /M "Kies [A/I]: "
if errorlevel 2 (
    set "AUTO=0"
) else (
    set "AUTO=1"
)
goto :EOF

:: ------------------------------------------------------
:: Subroutine: AskAndRun
:: %1 = Tweak description
:: %2 = Command to execute
:AskAndRun
echo [INFO] Starting: %~1
if "%AUTO%"=="0" (
    set /p confirm="Wilt u deze aanpassing doen?? (Y/N): "
    if /i not "%confirm%"=="Y" goto :AskAndRunEnd
) else (
    echo [INFO] Automatically applying tweak: %~1
)
setlocal enabledelayedexpansion
set "TWEAK_CMD=%~2"
echo [INFO] Executing: !TWEAK_CMD!
cmd /s /c !TWEAK_CMD!
if errorlevel 1 echo [WARNING] Command failed: !TWEAK_CMD!
endlocal
:AskAndRunEnd
goto :EOF

:: ------------------------------------------------------
:: Subroutine: SafeRegAdd
:: Safely updates a registry value by first querying the current setting.
:: Parameters:
::   %1 = Registry key (e.g., HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize)
::   %2 = Value name (e.g., StartupDelayInMSec)
::   %3 = Type (e.g., REG_DWORD, REG_SZ, REG_BINARY)
::   %4 = Data to set (e.g., 0, 2000, 90120000)
::   %5 = Description of the tweak
:SafeRegAdd
echo.
echo [INFO] %~5
echo [INFO] Querying current value of %~1\%~2 ...
reg query "%~1" /v %~2 >temp_reg.txt 2>nul
if errorlevel 1 (
    echo [INFO] Value does not exist; it will be created.
) else (
    for /f "tokens=2,*" %%A in ('findstr /r /c:"%~2" temp_reg.txt') do (
        set "CURRENT=%%B"
    )
    echo [INFO] Current value: %CURRENT%
)
del temp_reg.txt
set /p safeconfirm="Do you want to update this registry value? (Y/N): "
if /i not "%safeconfirm%"=="Y" goto :EOF
echo [INFO] Updating registry...
reg add "%~1" /v %~2 /t %~3 /d %~4 /f
if errorlevel 1 (
   echo [WARNING] Failed to update registry value %~2 in %~1.
) else (
   echo [INFO] Updated registry value %~2 in %~1.
)
goto :EOF