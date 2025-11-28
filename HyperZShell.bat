@echo off
title HyperZShell
setlocal ENABLEDELAYEDEXPANSION

rem Default mode is normal
set "devmode=0"

:main
cls
if !devmode! EQU 1 (
    set /p "cmd=C:\HyperZShellDevMode> "
) else (
    set /p "cmd=C:\HyperZShell> "
)
if /i "%cmd%"=="exit" exit /b

rem --- Built-in commands ---

rem Run game
if /i "%cmd%"=="game" goto game

rem Run bubbles screensaver
if /i "%cmd%"=="bubbles" (
    start "" bubbles.scr /s
    goto main
)

rem Network scan command
if /i "%cmd%"=="networkscan" (
    arp -a
    ipconfig /all
    ping 8.8.8.8 -n 4
    pause
    goto main
)

rem Calculator command
if /i "%cmd%"=="calculator" (
    :calc_loop
    cls
    echo --- HyperZShell Calculator ---
    echo Type 'exit' to return to HyperZShell
    set /p "expr=Enter expression: "
    if /i "!expr!"=="exit" goto main
    set "expr=!expr: =!"
    for /f "delims=" %%r in ('powershell -Command "[math]::Round([double](^& { !expr! }), 10)"') do set "result=%%r"
    echo Result: !result!
    pause
    goto calc_loop
)

rem Run app as admin
echo %cmd% | findstr /b /i "runasadmin " >nul
if not errorlevel 1 (
    set "app=%cmd:~11%"
    if not defined app (
        echo Usage: runasadmin ^<application.exe^>
        goto main
    )
    cmd /min /C "set __COMPAT_LAYER=runasinvoker && start "" "!app!"" 
    goto main
)

rem Activate devmode
if /i "%cmd%"=="devmode" (
    set "devmode=1"
    goto main
)

rem Revert to normal mode
if /i "%cmd%"=="normalmode" (
    set "devmode=0"
    goto main
)

rem ================================
rem        SKYNET COMMAND
rem ================================
if /i "%cmd%"=="skynet" (
    cls
    call :type "Terminator Message"
    echo.
    call :type "Dont be afraid."
    call :type "I am a very kind virus."
    call :type "You have do many works today."
    call :type "So, I will let your computer slow down."
    call :type "Have a nice day,"
    call :type "Goodbye."
    echo.
    call :type "Press a key to continue..."
    pause >nul
    goto main
)

rem ================================

rem Unknown command fallback with pause
if !devmode! EQU 1 (
    powershell -Command "%cmd%"
    pause
) else (
    cmd /c "%cmd%"
    pause
)

goto main


rem ================================
rem          GAME CODE
rem ================================
:game
cls
set "size=8"
set "px=0"
set "py=0"
set /a score=0
set /a hazardCount=0
set /a maxHazards=32

rem Initialize hazards
for /l %%i in (0,1,31) do (
    set "hx%%i=-1"
    set "hy%%i=-1"
)

rem First hazard
call :safe_random hx0 hy0 !size! !px! !py! 0
set /a hazardCount=1

rem First $ safely
call :spawn_dollar

:loop
cls
echo --- HyperZShell Game ---
echo Score: !score!
echo Hazards: !hazardCount! / !maxHazards!
echo.

rem Draw grid
for /l %%Y in (0,1,7) do (
    set "row="
    for /l %%X in (0,1,7) do (
        set "char=."
        if %%X==!px! if %%Y==!py! set "char=@"
        if %%X==!dx! if %%Y==!dy! set "char=$"
        set /a maxH=!hazardCount!-1
        for /l %%H in (0,1,!maxH!) do (
            if %%X==!hx%%H! if %%Y==!hy%%H! set "char=#"
        )
        set "row=!row!!char! "
    )
    echo !row!
)

echo.
echo Controls: W/A/S/D to move, P to pause/quit
echo.

rem --- Key input ---
choice /c wasdp /n >nul
set "key=!errorlevel!"

if "!key!"=="1" set /a py-=1
if "!key!"=="3" set /a py+=1
if "!key!"=="2" set /a px-=1
if "!key!"=="4" set /a px+=1
if "!key!"=="5" goto main

rem Keep player in bounds AFTER moving
if !px! LSS 0 set px=0
if !py! LSS 0 set py=0
set /a maxPos=!size!-1
if !px! GTR !maxPos! set px=!maxPos!
if !py! GTR !maxPos! set py=!maxPos!

rem --- Check collision with hazards FIRST ---
set /a maxH=!hazardCount!-1
for /l %%H in (0,1,!maxH!) do (
    if !px!==!hx%%H! if !py!==!hy%%H! (
        cls
        echo ================================
        echo         GAME OVER
        echo ================================
        echo Final Score: !score!
        echo.
        pause
        goto main
    )
)

rem --- Check collision with $ ---
if !px!==!dx! if !py!==!dy! (
    set /a score+=1
    call :spawn_dollar

    rem Add new hazard every 10 score, max 32
    set /a targetHazards=!score!/10 + 1
    if !targetHazards! GTR !maxHazards! set targetHazards=!maxHazards!
    if !hazardCount! LSS !targetHazards! (
        set /a idx=!hazardCount!
        call :safe_random hx!idx! hy!idx! !size! !px! !py! !hazardCount! dx dy
        set /a hazardCount+=1
    )
)

rem Add a tiny delay for smoother rendering
rem timeout /t 0 >nul 2>&1

goto loop


:spawn_dollar
rem Generate $ safely (not under player or hazards)
:retryDollar
call :random_pos dx !size!
call :random_pos dy !size!
if !dx!==!px! if !dy!==!py! goto retryDollar
set /a maxH=!hazardCount!-1
for /l %%H in (0,1,!maxH!) do (
    if !dx!==!hx%%H! if !dy!==!hy%%H! goto retryDollar
)
exit /b


:safe_random
rem %1=xvar %2=yvar %3=size %4=px %5=py %6=hazardCount [%7=dx %8=dy optional]
:retry
call :random_pos tempX %3
call :random_pos tempY %3
if !tempX!==%4 if !tempY!==%5 goto retry
set /a checkCount=%6-1
for /l %%j in (0,1,!checkCount!) do (
    if !tempX!==!hx%%j! if !tempY!==!hy%%j! goto retry
)
if not "%7"=="" if not "%8"=="" (
    if !tempX!==!%7! if !tempY!==!%8! goto retry
)
set "%1=!tempX!"
set "%2=!tempY!"
exit /b


:random_pos
set /a "%~1=!random! %% %~2"
exit /b


rem ============================================
rem TYPEWRITER TEXT FUNCTION (used by Skynet)
rem ============================================
:type
powershell -NoLogo -NoProfile -Command ^
    "$t='%~1'; foreach($c in $t.ToCharArray()){Write-Host -NoNewline $c; Start-Sleep -Milliseconds 35}; Write-Host ''"
exit /b