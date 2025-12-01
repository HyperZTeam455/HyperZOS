@echo off
title HyperZOS v0.1.1
color 0a
mode con: cols=110 lines=30
setlocal enabledelayedexpansion

rem ===============================
rem Boot Splash Screen
rem ===============================
cls
echo ================================================================
echo                       H Y P E R Z O S
echo ================================================================
echo.
echo                       Version 0.1.1
echo.
echo             Loading HyperZOS Operating System...
echo.
timeout /t 2 >nul
echo Boot complete!
timeout /t 1 >nul

rem ---------- HyperZOS Root ----------
set "ROOT=%~dp0HyperZFS"
rem ---------- SELECTION MODE ----------
set "SELECTION_MODE=arrow"

rem ---------- LOAD THEME ----------
if exist "%ROOT%\Themes\current.txt" (
    set /p THEME=<"%ROOT%\Themes\current.txt"
    color !THEME!
) else (
    color 0a
)

rem ---------- INIT FILESYSTEM ----------
if not exist "%ROOT%" (
    mkdir "%ROOT%"
    mkdir "%ROOT%\Documents"
    mkdir "%ROOT%\Programs"
    mkdir "%ROOT%\Themes"
    echo Welcome to HyperZOS v0.1.1 > "%ROOT%\Documents\welcome.txt"
    echo 0a > "%ROOT%\Themes\current.txt"
)

rem Ensure Themes folder exists
if not exist "%ROOT%\Themes" mkdir "%ROOT%\Themes"

rem Ensure current.txt exists with default theme
if not exist "%ROOT%\Themes\current.txt" echo 0a > "%ROOT%\Themes\current.txt"

rem ===============================
rem Menu variables
rem ===============================
set sel=0
set opts[0]=File Manager
set opts[1]=Games
set opts[2]=HyperZShell
set opts[3]=HyperZPad
set opts[4]=Network Scanner
set opts[5]=HyperZDecimal
set opts[6]=Themes
set opts[7]=Exit HyperZOS

:menu
cls
echo ================================================================
echo                     HyperZOS Operating System
echo            Version 0.1.1 - %date% - %time%
echo ================================================================
echo.

rem Check selection mode
if "!SELECTION_MODE!"=="number" goto menu_number_mode

rem ---------- ARROW KEY MODE ----------
rem Draw menu with highlight
for /L %%i in (0,1,7) do (
    if !sel! EQU %%i (
        echo  ^>^> !opts[%%i]!
    ) else (
        echo     !opts[%%i]!
    )
)
echo.
echo Use Up/Down arrows to navigate, Enter to select, T to switch modes.

rem Clear previous key value
set "key="

rem Read key from PowerShell
for /f %%K in ('powershell -noprofile -command "$k=$host.ui.rawui.readkey('NoEcho,IncludeKeyDown');if($k.Character -eq 't' -or $k.Character -eq 'T'){Write-Output 84}else{Write-Output $k.virtualkeycode}" 2^>nul') do set "key=%%K"

rem If PowerShell failed (older systems), auto-switch to number mode
if not defined key (
    set "SELECTION_MODE=number"
    goto menu
)

rem Check for T key (ASCII 84)
if "%key%"=="84" goto toggle_selection_mode

rem Handle arrow keys
if "%key%"=="38" (
    set /a sel-=1
    if !sel! LSS 0 set sel=7
)
if "%key%"=="40" (
    set /a sel+=1
    if !sel! GTR 7 set sel=0
)
if "%key%"=="13" goto select_option

goto menu

:select_option
if !sel! EQU 0 goto fileman
if !sel! EQU 1 goto games_menu
if !sel! EQU 2 goto run_hyperzshell
if !sel! EQU 3 goto hyperzpad
if !sel! EQU 4 goto network_scanner
if !sel! EQU 5 goto hyperzDecimal
if !sel! EQU 6 goto themes
if !sel! EQU 7 goto exitos
goto menu

rem ---------- NUMBER SELECTION MODE ----------
:menu_number_mode
cls
echo ================================================================
echo                     HyperZOS Operating System
echo            Version 0.1.1 - %date% - %time%
echo ================================================================
echo.
echo [Number Selection Mode - Compatible with all systems]
echo.

rem Draw menu with numbers
for /L %%i in (0,1,7) do (
    set /a display_num=%%i+1
    echo  !display_num!. !opts[%%i]!
)
echo.
echo Enter number (1-8) or T to switch modes: 
set /p "menu_input="

rem Check if empty input
if not defined menu_input goto menu_number_mode

rem Check if T pressed
if /i "!menu_input!"=="T" goto toggle_selection_mode

rem Validate number input
set "valid_input=0"
for %%n in (1 2 3 4 5 6 7 8) do (
    if "!menu_input!"=="%%n" set "valid_input=1"
)

if "!valid_input!"=="0" (
    echo Invalid selection!
    timeout /t 1 >nul
    goto menu_number_mode
)

rem Convert to zero-based index
set /a sel=!menu_input!-1
goto select_option

rem ---------- TOGGLE SELECTION MODE ----------
:toggle_selection_mode
cls
echo ================================================================
echo                   Selection Mode Toggle
echo ================================================================
echo.
if "!SELECTION_MODE!"=="arrow" (
    echo Current Mode: Arrow Key Navigation
    echo.
    echo Switch to Number Selection Mode?
    echo ^(Compatible with Windows 2000, Linux/Wine, macOS^)
) else (
    echo Current Mode: Number Selection
    echo.
    echo Switch to Arrow Key Navigation Mode?
    echo ^(Requires Windows XP+ with PowerShell^)
)
echo.
choice /c YN /n /m "Y - Yes, N - No: "

if errorlevel 2 goto menu
if errorlevel 1 (
    if "!SELECTION_MODE!"=="arrow" (
        set "SELECTION_MODE=number"
        echo.
        echo Switched to Number Selection Mode!
    ) else (
        set "SELECTION_MODE=arrow"
        echo.
        echo Switched to Arrow Key Mode!
    )
    timeout /t 2 >nul
    goto menu
)

rem ===========================
rem Themes Manager
rem ===========================
:themes
cls
echo ================================================================
echo                        Themes Manager
echo ================================================================
echo.
echo Current Theme: 
if exist "%ROOT%\Themes\current.txt" (
    set /p CURRENT_THEME=<"%ROOT%\Themes\current.txt"
    echo Text Color: !CURRENT_THEME:~1,1!
)
echo.
echo Select Theme (1-15):
echo.
echo 1. Blue
echo 2. Green
echo 3. Aqua
echo 4. Red
echo 5. Purple
echo 6. Yellow
echo 7. White
echo 8. Gray
echo 9. Light Blue
echo 10. Light Green
echo 11. Light Aqua
echo 12. Light Red
echo 13. Light Purple
echo 14. Light Yellow
echo 15. Bright White
echo.
echo Type 'back' to return to menu
echo.
set /p text_color=Enter text color: 

if /i "%text_color%"=="back" goto menu
if not defined text_color goto themes

rem Convert number to hex color code
if "%text_color%"=="1" set "hex_color=1"
if "%text_color%"=="2" set "hex_color=2"
if "%text_color%"=="3" set "hex_color=3"
if "%text_color%"=="4" set "hex_color=4"
if "%text_color%"=="5" set "hex_color=5"
if "%text_color%"=="6" set "hex_color=6"
if "%text_color%"=="7" set "hex_color=7"
if "%text_color%"=="8" set "hex_color=8"
if "%text_color%"=="9" set "hex_color=9"
if "%text_color%"=="10" set "hex_color=a"
if "%text_color%"=="11" set "hex_color=b"
if "%text_color%"=="12" set "hex_color=c"
if "%text_color%"=="13" set "hex_color=d"
if "%text_color%"=="14" set "hex_color=e"
if "%text_color%"=="15" set "hex_color=f"

if not defined hex_color (
    echo Invalid: Must be 1-15
    timeout /t 2 >nul
    goto themes
)

rem Build theme code (0 + text color)
set "new_theme=0!hex_color!"

rem Apply and save theme
color !new_theme!
if errorlevel 1 (
    echo Invalid color code!
    timeout /t 2 >nul
    goto themes
)

echo !new_theme! > "%ROOT%\Themes\current.txt"

echo.
echo Theme applied and saved!
timeout /t 2 >nul
goto menu
rem ===========================
rem Network Scanner
rem ===========================
:network_scanner
cls
echo ================================================================
echo                      Network Scanner
echo ================================================================
echo.
echo 1. Quick Scan (Hostname + IP Config)
echo 2. Full Network Scan (All Commands)
echo 3. Ping Test (8.8.8.8)
echo 4. ARP Table
echo 5. NetBIOS Status
echo 6. MAC Address
echo 7. Network Statistics
echo 8. Export Results to File
echo 9. Back to Main Menu
echo.
set /p netscan_choice=Select option (1-9): 

if "%netscan_choice%"=="1" goto netscan_quick
if "%netscan_choice%"=="2" goto netscan_full
if "%netscan_choice%"=="3" goto netscan_ping
if "%netscan_choice%"=="4" goto netscan_arp
if "%netscan_choice%"=="5" goto netscan_nbtstat
if "%netscan_choice%"=="6" goto netscan_mac
if "%netscan_choice%"=="7" goto netscan_netstat
if "%netscan_choice%"=="8" goto netscan_export
if "%netscan_choice%"=="9" goto menu
goto network_scanner

:netscan_quick
cls
echo ================================================================
echo                      Quick Network Scan
echo ================================================================
echo.
echo [*] Retrieving Hostname...
echo.
hostname
echo.
echo ================================================================
echo [*] IP Configuration:
echo ================================================================
echo.
ipconfig | findstr /i "IPv4 Subnet Gateway"
echo.
echo ================================================================
echo Press any key to return...
pause >nul
goto network_scanner

:netscan_full
cls
echo ================================================================
echo                   Full Network Scan
echo ================================================================
echo.
echo [1/7] Getting Hostname...
echo ================================================================
hostname
echo.
timeout /t 2 >nul

echo [2/7] IP Configuration...
echo ================================================================
ipconfig /all
echo.
timeout /t 2 >nul

echo [3/7] Pinging Google DNS (8.8.8.8)...
echo ================================================================
ping 8.8.8.8 -n 4
echo.
timeout /t 2 >nul

echo [4/7] ARP Cache Table...
echo ================================================================
arp -a
echo.
timeout /t 2 >nul

echo [5/7] NetBIOS Status...
echo ================================================================
nbtstat -n
echo.
timeout /t 2 >nul

echo [6/7] MAC Address...
echo ================================================================
getmac /v
echo.
timeout /t 2 >nul

echo [7/7] Network Statistics...
echo ================================================================
netstat -e
echo.
echo ================================================================
echo Scan Complete!
echo ================================================================
pause
goto network_scanner

:netscan_ping
cls
echo ================================================================
echo                   Ping Test - 8.8.8.8
echo ================================================================
echo.
echo Testing connection to Google DNS...
echo.
ping 8.8.8.8 -n 10
echo.
echo ================================================================
pause
goto network_scanner

:netscan_arp
cls
echo ================================================================
echo                      ARP Table
echo ================================================================
echo.
echo Displaying Address Resolution Protocol cache...
echo.
arp -a
echo.
echo ================================================================
pause
goto network_scanner

:netscan_nbtstat
cls
echo ================================================================
echo                   NetBIOS Status
echo ================================================================
echo.
echo Local NetBIOS Name Table:
echo.
nbtstat -n
echo.
echo ================================================================
echo.
echo Do you want to query a remote computer? (Y/N)
set /p nbt_remote=
if /i "%nbt_remote%"=="Y" (
    echo.
    set /p remote_ip=Enter IP address or computer name: 
    echo.
    echo Querying !remote_ip!...
    echo.
    nbtstat -A !remote_ip! 2>nul
    if errorlevel 1 nbtstat -a !remote_ip!
    echo.
)
echo ================================================================
pause
goto network_scanner

:netscan_mac
cls
echo ================================================================
echo                    MAC Addresses
echo ================================================================
echo.
getmac /v /fo table
echo.
echo ================================================================
pause
goto network_scanner

:netscan_netstat
cls
echo ================================================================
echo                  Network Statistics
echo ================================================================
echo.
echo 1. Active Connections
echo 2. Ethernet Statistics
echo 3. Routing Table
echo 4. Listening Ports
echo 5. Back
echo.
set /p netstat_opt=Select option (1-5): 

if "%netstat_opt%"=="1" (
    cls
    echo Active Connections:
    echo ================================================================
    netstat -an | more
    pause
    goto netscan_netstat
)
if "%netstat_opt%"=="2" (
    cls
    echo Ethernet Statistics:
    echo ================================================================
    netstat -e
    pause
    goto netscan_netstat
)
if "%netstat_opt%"=="3" (
    cls
    echo Routing Table:
    echo ================================================================
    netstat -r | more
    pause
    goto netscan_netstat
)
if "%netstat_opt%"=="4" (
    cls
    echo Listening Ports:
    echo ================================================================
    netstat -an | findstr "LISTENING"
    pause
    goto netscan_netstat
)
if "%netstat_opt%"=="5" goto network_scanner
goto netscan_netstat

:netscan_export
cls
echo ================================================================
echo                   Export Scan Results
echo ================================================================
echo.
echo Exporting network scan to file...
echo.

set "EXPORT_FILE=%ROOT%\Documents\NetworkScan_%date:~-4%%date:~4,2%%date:~7,2%_%time:~0,2%%time:~3,2%%time:~6,2%.txt"
set "EXPORT_FILE=%EXPORT_FILE: =0%"

echo ================================================================ > "%EXPORT_FILE%"
echo           HyperZOS Network Scan Report >> "%EXPORT_FILE%"
echo                 %date% %time% >> "%EXPORT_FILE%"
echo ================================================================ >> "%EXPORT_FILE%"
echo. >> "%EXPORT_FILE%"

echo [*] Hostname: >> "%EXPORT_FILE%"
hostname >> "%EXPORT_FILE%"
echo. >> "%EXPORT_FILE%"

echo [*] IP Configuration: >> "%EXPORT_FILE%"
ipconfig /all >> "%EXPORT_FILE%"
echo. >> "%EXPORT_FILE%"

echo [*] Ping Test (8.8.8.8): >> "%EXPORT_FILE%"
ping 8.8.8.8 -n 4 >> "%EXPORT_FILE%"
echo. >> "%EXPORT_FILE%"

echo [*] ARP Cache: >> "%EXPORT_FILE%"
arp -a >> "%EXPORT_FILE%"
echo. >> "%EXPORT_FILE%"

echo [*] NetBIOS: >> "%EXPORT_FILE%"
nbtstat -n >> "%EXPORT_FILE%"
echo. >> "%EXPORT_FILE%"

echo [*] MAC Addresses: >> "%EXPORT_FILE%"
getmac /v >> "%EXPORT_FILE%"
echo. >> "%EXPORT_FILE%"

echo [*] Network Statistics: >> "%EXPORT_FILE%"
netstat -e >> "%EXPORT_FILE%"
echo. >> "%EXPORT_FILE%"

echo ================================================================ >> "%EXPORT_FILE%"
echo                    End of Report >> "%EXPORT_FILE%"
echo ================================================================ >> "%EXPORT_FILE%"

echo Export complete!
echo File saved to: %EXPORT_FILE%
echo.
echo. Press any key to continue.
pause >nul
notepad "%EXPORT_FILE%"
goto network_scanner

rem ===========================
rem HyperZDecimal Encoder/Decoder
rem ===========================
:hyperzDecimal
cls
echo ================================================================
echo                      HyperZDecimal
echo              Morse Code Encryption System
echo ================================================================
echo.
echo 1. Encode Text to HyperZDecimal
echo 2. Decode HyperZDecimal to Text
echo 3. Back to Main Menu
echo.
set /p hzd_choice=Select option (1-3): 

if "%hzd_choice%"=="1" goto hzd_encoder
if "%hzd_choice%"=="2" goto hzd_decoder
if "%hzd_choice%"=="3" goto menu
goto hyperzDecimal

rem ===========================
rem HyperZDecimal Encoder
rem ===========================
:hzd_encoder
cls
echo ================================================================
echo                 HyperZDecimal Encoder
echo ================================================================
echo.
set /p "input=Enter text to encode (or 'back' to return): "

if /i "!input!"=="back" goto hyperzDecimal
if "!input!"=="" goto hzd_encoder

:: Frame marker
set FRAME=88888

:: Initialize final_text with starting frame
set "final_text=%FRAME%"

:: Add each character with random number
set i=0
:hzd_enc_loop
set "ch=!input:~%i%,1!"
if "!ch!"=="" goto hzd_add_end_frame

:: Convert to uppercase (preserve case)
set "ch_upper=!ch!"
if "!ch!"=="a" set "ch_upper=A"
if "!ch!"=="b" set "ch_upper=B"
if "!ch!"=="c" set "ch_upper=C"
if "!ch!"=="d" set "ch_upper=D"
if "!ch!"=="e" set "ch_upper=E"
if "!ch!"=="f" set "ch_upper=F"
if "!ch!"=="g" set "ch_upper=G"
if "!ch!"=="h" set "ch_upper=H"
if "!ch!"=="i" set "ch_upper=I"
if "!ch!"=="j" set "ch_upper=J"
if "!ch!"=="k" set "ch_upper=K"
if "!ch!"=="l" set "ch_upper=L"
if "!ch!"=="m" set "ch_upper=M"
if "!ch!"=="n" set "ch_upper=N"
if "!ch!"=="o" set "ch_upper=O"
if "!ch!"=="p" set "ch_upper=P"
if "!ch!"=="q" set "ch_upper=Q"
if "!ch!"=="r" set "ch_upper=R"
if "!ch!"=="s" set "ch_upper=S"
if "!ch!"=="t" set "ch_upper=T"
if "!ch!"=="u" set "ch_upper=U"
if "!ch!"=="v" set "ch_upper=V"
if "!ch!"=="w" set "ch_upper=W"
if "!ch!"=="x" set "ch_upper=X"
if "!ch!"=="y" set "ch_upper=Y"
if "!ch!"=="z" set "ch_upper=Z"

:: Add random number
set /a rnd=!random! %% 10
set "final_text=!final_text!!ch_upper!!rnd!"
set /a i+=1
goto hzd_enc_loop

:hzd_add_end_frame
:: Add ending frame marker
set "final_text=!final_text!!FRAME!"

:: Convert to Morse inline
set "output="
set i=0
:hzd_convert
set "c=!final_text:~%i%,1!"
if "!c!"=="" goto hzd_done_convert

:: Letters
if /i "!c!"=="A" set "morse=.-"
if /i "!c!"=="B" set "morse=-..."
if /i "!c!"=="C" set "morse=-.-."
if /i "!c!"=="D" set "morse=-.."
if /i "!c!"=="E" set "morse=."
if /i "!c!"=="F" set "morse=..-."
if /i "!c!"=="G" set "morse=--."
if /i "!c!"=="H" set "morse=...."
if /i "!c!"=="I" set "morse=.."
if /i "!c!"=="J" set "morse=.---"
if /i "!c!"=="K" set "morse=-.-"
if /i "!c!"=="L" set "morse=.-.."
if /i "!c!"=="M" set "morse=--"
if /i "!c!"=="N" set "morse=-."
if /i "!c!"=="O" set "morse=---"
if /i "!c!"=="P" set "morse=.--."
if /i "!c!"=="Q" set "morse=--.-"
if /i "!c!"=="R" set "morse=.-."
if /i "!c!"=="S" set "morse=..."
if /i "!c!"=="T" set "morse=-"
if /i "!c!"=="U" set "morse=..-"
if /i "!c!"=="V" set "morse=...-"
if /i "!c!"=="W" set "morse=.--"
if /i "!c!"=="X" set "morse=-..-"
if /i "!c!"=="Y" set "morse=-.--"
if /i "!c!"=="Z" set "morse=--.."

:: Numbers
if "!c!"=="0" set "morse=-----"
if "!c!"=="1" set "morse=.----"
if "!c!"=="2" set "morse=..---"
if "!c!"=="3" set "morse=...--"
if "!c!"=="4" set "morse=....-"
if "!c!"=="5" set "morse=....."
if "!c!"=="6" set "morse=-...."
if "!c!"=="7" set "morse=--..."
if "!c!"=="8" set "morse=---.."
if "!c!"=="9" set "morse=----."

:: Append to output
set "output=!output!!morse! "
set /a i+=1
goto hzd_convert

:hzd_done_convert
cls
echo ================================================================
echo                 HyperZDecimal Encoder
echo ================================================================
echo.
echo Original Text:
echo !input!
echo.
echo ================================================================
echo Encoded HyperZDecimal (Morse):
echo ================================================================
echo !output!
echo.
echo ================================================================
echo.
echo Options:
echo 1. Save to file
echo 2. Encode another message
echo 3. Back to HyperZDecimal menu
echo.
set /p enc_action=Select option: 

if "%enc_action%"=="1" goto hzd_save_encoded
if "%enc_action%"=="2" goto hzd_encoder
if "%enc_action%"=="3" goto hyperzDecimal
goto hzd_done_convert

:hzd_save_encoded
set "ENC_FILE=%ROOT%\Documents\HyperZEncoded_%date:~-4%%date:~4,2%%date:~7,2%_%time:~0,2%%time:~3,2%%time:~6,2%.txt"
set "ENC_FILE=%ENC_FILE: =0%"
echo !output! > "%ENC_FILE%"
echo.
echo Encoded message saved to:
echo %ENC_FILE%
echo.
pause
goto hzd_encoder

rem ===========================
rem HyperZDecimal Decoder
rem ===========================
:hzd_decoder
cls
echo ================================================================
echo                 HyperZDecimal Decoder
echo ================================================================
echo.
echo Enter HyperZDecimal Morse code (or 'back' to return):
echo (Paste the encoded morse string)
echo.
set /p "input="

if /i "!input!"=="back" goto hyperzDecimal
if "!input!"=="" goto hzd_decoder

:: Initialize decoded string
set "decoded="

:: Split input by spaces into tokens
for %%A in (!input!) do (
    set "token=%%A"
    
    :: Skip frame marker (8 in morse = ---..)
    if "!token!"=="---.." set "token="
    
    if defined token (
        set "char="
        
        :: Letters
        if "!token!"==".-" set "char=A"
        if "!token!"=="-..." set "char=B"
        if "!token!"=="-.-." set "char=C"
        if "!token!"=="-.." set "char=D"
        if "!token!"=="." set "char=E"
        if "!token!"=="..-." set "char=F"
        if "!token!"=="--." set "char=G"
        if "!token!"=="...." set "char=H"
        if "!token!"==".." set "char=I"
        if "!token!"==".---" set "char=J"
        if "!token!"=="-.-" set "char=K"
        if "!token!"==".-.." set "char=L"
        if "!token!"=="--" set "char=M"
        if "!token!"=="-." set "char=N"
        if "!token!"=="---" set "char=O"
        if "!token!"==".--." set "char=P"
        if "!token!"=="--.-" set "char=Q"
        if "!token!"==".-." set "char=R"
        if "!token!"=="..." set "char=S"
        if "!token!"=="-" set "char=T"
        if "!token!"=="..-" set "char=U"
        if "!token!"=="...-" set "char=V"
        if "!token!"==".--" set "char=W"
        if "!token!"=="-..-" set "char=X"
        if "!token!"=="-.--" set "char=Y"
        if "!token!"=="--.." set "char=Z"
        
        :: Numbers
        if "!token!"=="-----" set "char=0"
        if "!token!"==".----" set "char=1"
        if "!token!"=="..---" set "char=2"
        if "!token!"=="...--" set "char=3"
        if "!token!"=="....-" set "char=4"
        if "!token!"=="....." set "char=5"
        if "!token!"=="-...." set "char=6"
        if "!token!"=="--..." set "char=7"
        if "!token!"=="---.." set "char=8"
        if "!token!"=="----." set "char=9"
        
        set "decoded=!decoded!!char!"
    )
)

:: Remove only random numbers (keep letters)
set "original="
set len=0
:hzd_strip_loop
set "c=!decoded:~%len%,1!"
if "!c!"=="" goto hzd_done_strip

for %%L in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    if /i "!c!"=="%%L" set "original=!original!!c!"
)
set /a len+=1
goto hzd_strip_loop

:hzd_done_strip
cls
echo ================================================================
echo                 HyperZDecimal Decoder
echo ================================================================
echo.
echo Encoded Input:
echo !input!
echo.
echo ================================================================
echo Decoded Text:
echo ================================================================
echo !original!
echo.
echo ================================================================
echo.
echo Options:
echo 1. Decode another message
echo 2. Back to HyperZDecimal menu
echo.
set /p dec_action=Select option: 

if "%dec_action%"=="1" goto hzd_decoder
if "%dec_action%"=="2" goto hyperzDecimal
goto hzd_done_strip

rem ===========================
rem File Manager
rem ===========================
:fileman
cls
echo --- File Manager ---
set "CURDIR=%ROOT%"
:fm_loop
cls
echo --- Folder: %CURDIR% ---
echo.
dir "%CURDIR%" /b /a 2>nul
if errorlevel 1 echo (Empty or error reading directory)
echo.
echo Commands: (type filename to open/run, "view filename" to view text, "BACK" to go up)
echo          ("del filename" to delete, "new filename" to create)
echo          ("rename oldname newname" to rename, "move filename foldername" to move)
set /p item=Enter command: 

rem Check for delete command
if /i "!item:~0,4!"=="del " (
    set "delitem=!item:~4!"
    set "DELPATH=%CURDIR%\!delitem!"
    goto delete_file
)

rem Check for rename command
if /i "!item:~0,7!"=="rename " (
    set "renameargs=!item:~7!"
    for /f "tokens=1,*" %%a in ("!renameargs!") do (
        set "oldname=%%a"
        set "newname=%%b"
    )
    if not defined newname (
        echo Usage: rename oldname newname
        pause
        goto fm_loop
    )
    set "OLDPATH=%CURDIR%\!oldname!"
    set "NEWPATH=%CURDIR%\!newname!"
    if not exist "!OLDPATH!" (
        echo Error: File not found.
        pause
        goto fm_loop
    )
    ren "!OLDPATH!" "!newname!"
    if errorlevel 1 (
        echo Error: Could not rename file.
    ) else (
        echo File renamed successfully.
    )
    pause
    goto fm_loop
)

rem Check for move command
if /i "!item:~0,5!"=="move " (
    set "moveargs=!item:~5!"
    for /f "tokens=1,*" %%a in ("!moveargs!") do (
        set "movefile=%%a"
        set "movefolder=%%b"
    )
    if not defined movefolder (
        echo Usage: move filename foldername
        pause
        goto fm_loop
    )
    set "MOVESRC=%CURDIR%\!movefile!"
    
    rem Try to find the folder - check current directory first
    set "MOVEDST="
    for /f "delims=" %%F in ('dir "%CURDIR%" /b /ad 2^>nul') do (
        if /i "%%F"=="!movefolder!" set "MOVEDST=%CURDIR%\%%F"
    )
    
    rem If not found in current dir, check parent directory
    if not defined MOVEDST (
        for %%I in ("%CURDIR%") do set "PARENTDIR=%%~dpI"
        set "PARENTDIR=!PARENTDIR:~0,-1!"
        for /f "delims=" %%F in ('dir "!PARENTDIR!" /b /ad 2^>nul') do (
            if /i "%%F"=="!movefolder!" set "MOVEDST=!PARENTDIR!\%%F"
        )
    )
    
    if not exist "!MOVESRC!" (
        echo Error: File "!movefile!" not found.
        pause
        goto fm_loop
    )
    if not defined MOVEDST (
        echo Error: Destination folder "!movefolder!" not found in current or parent directory.
        pause
        goto fm_loop
    )
    move "!MOVESRC!" "!MOVEDST!\" >nul 2>&1
    if errorlevel 1 (
        echo Error: Could not move file.
    ) else (
        echo File moved successfully to !movefolder!
    )
    pause
    goto fm_loop
)

rem Check for view command
if /i "!item:~0,5!"=="view " (
    set "viewitem=!item:~5!"
    set "FILEPATH=%CURDIR%\!viewitem!"
    if not exist "!FILEPATH!" (
        echo File not found.
        pause
        goto fm_loop
    )
    goto view_txt_file
)

rem Check for new file command
if /i "!item:~0,4!"=="new " (
    set "newitem=!item:~4!"
    set "NEWPATH=%CURDIR%\!newitem!"
    echo.>"%NEWPATH%"
    echo File created: !newitem!
    pause
    goto fm_loop
)

rem Check for delete command
if /i "!item:~0,4!"=="del " (
    set "delitem=!item:~4!"
    set "DELPATH=%CURDIR%\!delitem!"
    goto delete_file
)

if /i "%item%"=="BACK" (
    if "%CURDIR%"=="%ROOT%" goto menu
    for %%I in ("%CURDIR%") do set "CURDIR=%%~dpI"
    set "CURDIR=!CURDIR:~0,-1!"
    goto fm_loop
)

if "%item%"=="" goto fm_loop

rem Set the full path
set "FULLPATH=%CURDIR%\%item%"

rem Check if item exists
if not exist "%FULLPATH%" (
    echo Not found.
    pause
    goto fm_loop
)

rem Use dir /ad to check if it's a directory
dir /ad "%FULLPATH%" >nul 2>&1
if errorlevel 1 (
    rem It's a FILE, not a directory
    rem Check if it's an executable file type - RUN IT
    if /i "%item:~-4%"==".bat" (
        start "" "%FULLPATH%"
        goto fm_loop
    )
    if /i "%item:~-4%"==".exe" (
        start "" "%FULLPATH%"
        goto fm_loop
    )
    if /i "%item:~-3%"==".py" (
        start "" "%FULLPATH%"
        goto fm_loop
    )
    if /i "%item:~-3%"==".js" (
        start "" "%FULLPATH%"
        goto fm_loop
    )
    rem For text files, view them
    if /i "%item:~-4%"==".txt" (
        set "FILEPATH=%FULLPATH%"
        goto view_txt_file
    )
    rem For any other file type, open with default program
    start "" "%FULLPATH%"
    goto fm_loop
) else (
    rem It's a DIRECTORY, navigate into it
    set "CURDIR=%FULLPATH%"
    goto fm_loop
)

rem ===========================
rem Delete File
rem ===========================
:delete_file
if not exist "!DELPATH!" (
    echo Error: File/folder not found.
    pause
    goto fm_loop
)

rem Check if it's a directory
dir /ad "!DELPATH!" >nul 2>&1
if errorlevel 1 (
    rem It's a FILE - delete it
    echo.
    echo Are you sure you want to delete: !delitem! ?
    echo Type "yes" to confirm or anything else to cancel.
    set /p confirm=
    
    if /i "!confirm!"=="yes" (
        del "!DELPATH!" 2>nul
        if errorlevel 1 (
            echo Error: Could not delete file.
        ) else (
            echo File deleted successfully.
        )
    ) else (
        echo Delete cancelled.
    )
) else (
    rem It's a DIRECTORY - delete folder and contents
    echo.
    echo Are you sure you want to delete the folder: !delitem! and all its contents?
    echo Type "yes" to confirm or anything else to cancel.
    set /p confirm=
    
    if /i "!confirm!"=="yes" (
        rmdir /s /q "!DELPATH!" 2>nul
        if errorlevel 1 (
            echo Error: Could not delete folder.
        ) else (
            echo Folder deleted successfully.
        )
    ) else (
        echo Delete cancelled.
    )
)
pause
goto fm_loop

rem ===========================
rem View Text File
rem ===========================
:view_txt_file
cls
echo ================================================================
echo                    File Viewer - %item%
echo ================================================================
echo.
type "!FILEPATH!"
echo.
echo ================================================================
echo Press any key to continue...
pause >nul
goto fm_loop

rem ===========================
rem Games Menu
rem ===========================
:games_menu
cls
echo ================================================================
echo                         Games Menu
echo ================================================================
echo.
echo 1. Tic Tac Toe
echo 2. Rock Paper Scissors
echo 3. Snake
echo 4. Codebreaker
echo 5. Hacker Simulator
echo 6. Back to Main Menu
echo.
set /p game_choice=Select a game (1-6): 

if "%game_choice%"=="1" goto tictactoe
if "%game_choice%"=="2" goto rps
if "%game_choice%"=="3" goto snake
if "%game_choice%"=="4" goto codebreaker
if "%game_choice%"=="5" goto hacker_sim
if "%game_choice%"=="6" goto menu
goto games_menu

rem ===========================
rem Snake Game
rem ===========================
:snake
cls
echo Initializing Snake Game...
set "board_size=16"
set "snake_length=3"
set "score=0"
set "direction=d"
set "game_over=0"

rem Clear any old snake data
for /l %%i in (0,1,50) do (
    set "snake_x_%%i="
    set "snake_y_%%i="
)

rem Initialize snake starting position (middle of board)
set "snake_x_0=8"
set "snake_y_0=8"
set "snake_x_1=7"
set "snake_y_1=8"
set "snake_x_2=6"
set "snake_y_2=8"

echo Spawning food...
rem Spawn first food
call :spawn_food

echo Starting game loop...
timeout /t 1 >nul

:snake_loop
cls
echo ================================================================
echo                    Snake Game - Score: !score!
echo ================================================================
echo.

rem Draw top border
set "border=+"
for /l %%i in (1,1,16) do set "border=!border!--"
set "border=!border!+"
echo !border!

rem Draw board
for /l %%Y in (0,1,15) do (
    set "row=^| "
    for /l %%X in (0,1,15) do (
        set "cell=. "
        
        rem Check if food
        if %%X==!food_x! if %%Y==!food_y! set "cell=@ "
        
        rem Check each snake segment up to snake_length
        set /a check_max=!snake_length!-1
        for /l %%S in (0,1,!check_max!) do (
            if %%X==!snake_x_%%S! if %%Y==!snake_y_%%S! set "cell=O "
        )
        
        set "row=!row!!cell!"
    )
    echo !row!^|
)

rem Draw bottom border
echo !border!
echo.
echo Controls: W=Up  S=Down  A=Left  D=Right  P=Quit
echo Direction: !direction!  Length: !snake_length!
echo Head: (!snake_x_0!,!snake_y_0!)  Seg1: (!snake_x_1!,!snake_y_1!)  Seg2: (!snake_x_2!,!snake_y_2!)
echo.

rem Get input - use choice command (wait for actual keypress)
choice /c wasdp /n >nul
set input=!errorlevel!

rem Process input and set direction + calculate new position
if !input!==5 goto games_menu

rem Set direction and calculate new head position
set /a new_head_x=!snake_x_0!
set /a new_head_y=!snake_y_0!

if !input!==1 (
    if not "!direction!"=="s" (
        set direction=w
        set /a new_head_y=!new_head_y!-1
    ) else (
        rem Can't go opposite direction, continue in current direction
        if "!direction!"=="s" set /a new_head_y=!new_head_y!+1
    )
)
if !input!==2 (
    if not "!direction!"=="d" (
        set direction=a
        set /a new_head_x=!new_head_x!-1
    ) else (
        rem Can't go opposite direction, continue in current direction
        if "!direction!"=="d" set /a new_head_x=!new_head_x!+1
    )
)
if !input!==3 (
    if not "!direction!"=="w" (
        set direction=s
        set /a new_head_y=!new_head_y!+1
    ) else (
        rem Can't go opposite direction, continue in current direction
        if "!direction!"=="w" set /a new_head_y=!new_head_y!-1
    )
)
if !input!==4 (
    if not "!direction!"=="a" (
        set direction=d
        set /a new_head_x=!new_head_x!+1
    ) else (
        rem Can't go opposite direction, continue in current direction
        if "!direction!"=="a" set /a new_head_x=!new_head_x!-1
    )
)

rem Check wall collision
if !new_head_x! LSS 0 goto snake_game_over
if !new_head_y! LSS 0 goto snake_game_over
if !new_head_x! GTR 15 goto snake_game_over
if !new_head_y! GTR 15 goto snake_game_over

rem Check self collision (skip head at position 0)
for /l %%S in (1,1,50) do (
    if defined snake_x_%%S (
        if defined snake_y_%%S (
            if !new_head_x!==!snake_x_%%S! if !new_head_y!==!snake_y_%%S! goto snake_game_over
        )
    )
)

rem Check food collision
set "ate_food=0"
if !new_head_x!==!food_x! if !new_head_y!==!food_y! (
    set "ate_food=1"
    set /a "score+=10"
    set /a "snake_length+=1"
    call :spawn_food
)

rem Move snake body - shift segments BEFORE setting new head
set /a last_seg=!snake_length!-1

rem Shift from tail to head
if !last_seg! GEQ 2 (
    for /l %%S in (!last_seg!,-1,2) do (
        set /a prev=%%S-1
        for %%P in (!prev!) do (
            set "snake_x_%%S=!snake_x_%%P!"
            set "snake_y_%%S=!snake_y_%%P!"
        )
    )
)
rem Always move segment 1
set "snake_x_1=!snake_x_0!"
set "snake_y_1=!snake_y_0!"

rem NOW set new head position
set "snake_x_0=!new_head_x!"
set "snake_y_0=!new_head_y!"

goto snake_loop

:spawn_food
rem Spawn food at random location not occupied by snake
:retry_food
set /a "food_x=!random! %% 16"
set /a "food_y=!random! %% 16"
for /l %%S in (0,1,50) do (
    if defined snake_x_%%S (
        if defined snake_y_%%S (
            if !food_x!==!snake_x_%%S! if !food_y!==!snake_y_%%S! goto retry_food
        )
    )
)
exit /b

:snake_game_over
cls
echo ================================================================
echo                       GAME OVER!
echo ================================================================
echo.
echo                   Final Score: !score!
echo                   Snake Length: !snake_length!
echo.
echo ================================================================
pause
goto games_menu

rem ===========================
rem Hacker Simulator Game
rem ===========================
:hacker_sim
cls
echo ================================================================
echo                    Hacker Simulator
echo ================================================================
echo.
echo Welcome to the virtual hacking simulation!
echo Mine virtual Bitcoin by accessing simulated computers.
echo.
timeout /t 2 >nul

rem Initialize game variables
set "bitcoin=0.000"
set "power=1"
set "power_cost=0.5"
set "password_length=4"
set "computers_hacked=0"
set "current_password="

rem Generate first password
call :generate_password

:hs_main
cls
echo ================================================================
echo                    Hacker Simulator
echo ================================================================
echo.
echo Bitcoin: !bitcoin! BTC
echo Computer Power: !power!
echo Computers Hacked: !computers_hacked!
echo.
echo Target Computer Password Length: !password_length! characters
echo.
echo ================================================================
echo.
echo 1. Enter Password
echo 2. Crack Password (Takes time based on length)
echo 3. Upgrade Power (!power_cost! BTC - Computers Hacked x2 BTC)
echo 4. Collect Bitcoin
echo 5. Exit to Games Menu
echo.
set /p hs_choice=Select option: 

if "%hs_choice%"=="1" goto hs_enter_password
if "%hs_choice%"=="2" goto hs_crack_password
if "%hs_choice%"=="3" goto hs_upgrade_power
if "%hs_choice%"=="4" goto hs_collect
if "%hs_choice%"=="5" goto games_menu
goto hs_main

:hs_enter_password
cls
echo ================================================================
echo                    Enter Password
echo ================================================================
echo.
set /p entered_pass=Enter password: 

if "!entered_pass!"=="!current_password!" (
    echo.
    echo [SUCCESS] Access granted!
    echo Injecting miner...
    timeout /t 2 >nul
    set /a computers_hacked+=1
    set /a password_length+=1
    call :generate_password
    echo Miner installed successfully!
    timeout /t 2 >nul
) else (
    echo.
    echo [FAILED] Incorrect password!
    timeout /t 2 >nul
)
goto hs_main

:hs_crack_password
cls
echo ================================================================
echo                    Cracking Password...
echo ================================================================
echo.
echo Target length: !password_length! characters
echo Computer Power: !power!

rem Calculate crack time
if !power! EQU 1 (
    set "crack_time_display=!password_length!.00"
) else (
    rem Formula: password_length / (1.2 ^ (power - 1))
    set /a "power_calc=!power! - 1"
    rem Get precise time with 2 decimals
    for /f "tokens=* delims=" %%a in ('powershell -command "[math]::Max(0.01, [math]::Round(!password_length! / [math]::Pow(1.2, !power_calc!), 2))"') do set "crack_time_display=%%a"
)

echo Estimated time: !crack_time_display! seconds...
echo.
echo Cracking Password....

rem Wait for crack time with decimal precision using PowerShell
powershell -command "Start-Sleep -Seconds !crack_time_display!" >nul 2>&1

echo.
echo [SUCCESS] Password cracked: !current_password!
echo.
pause
goto hs_enter_password

:hs_upgrade_power
cls
echo ================================================================
echo                    Upgrade Power
echo ================================================================
echo.
echo Current Power: !power!
echo Cost: !power_cost! BTC
echo Your Bitcoin: !bitcoin! BTC
echo.

rem Check if enough bitcoin
for /f "tokens=1 delims=." %%a in ("!bitcoin!") do set "btc_whole=%%a"
for /f "tokens=2 delims=." %%b in ("!bitcoin!") do set "btc_decimal=%%b"

rem Simple comparison (assuming bitcoin < 10)
set "can_afford=0"
if !btc_whole! GTR 0 set "can_afford=1"
if !bitcoin! GEQ !power_cost! set "can_afford=1"

if !can_afford! EQU 0 (
    echo Not enough Bitcoin!
    timeout /t 2 >nul
    goto hs_main
)

rem Subtract cost and increase power
set /a power+=1
for /f "tokens=* delims=" %%a in ('powershell -command "[math]::Round(!bitcoin! - !power_cost!, 3)"') do set "bitcoin=%%a"
for /f "tokens=* delims=" %%a in ('powershell -command "!power_cost! + 0.1"') do set "power_cost=%%a"

echo.
echo Power upgraded! New power: !power!
timeout /t 2 >nul
goto hs_main

:hs_collect
cls
echo ================================================================
echo                    Collecting Bitcoin...
echo ================================================================
echo.
echo Computers hacked: !computers_hacked!
echo Mining power: !power!
echo.

if !computers_hacked! EQU 0 (
    echo No computers hacked yet!
    timeout /t 2 >nul
    goto hs_main
)

rem Calculate bitcoin earned (0.001 * computers * power)
for /f "tokens=* delims=" %%a in ('powershell -command "!computers_hacked! * !power! * 0.001"') do set "earned=%%a"
for /f "tokens=* delims=" %%a in ('powershell -command "[math]::Round(!bitcoin! + !earned!, 3)"') do set "bitcoin=%%a"

echo Collected !earned! BTC!
echo Total: !bitcoin! BTC
timeout /t 2 >nul
goto hs_main

:generate_password
set "chars=ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
set "current_password="
for /l %%i in (1,1,!password_length!) do (
    set /a "rand=!random! %% 36"
    for %%r in (!rand!) do (
        set "current_password=!current_password!!chars:~%%r,1!"
    )
)
exit /b

rem ===========================
rem Codebreaker Game
rem ===========================
:codebreaker
cls
echo ================================================================
echo                        Codebreaker
echo ================================================================
echo.
echo Guess the 4-digit code! (Each digit: 0-6)
echo You have 10 attempts.
echo.
timeout /t 2 >nul

rem Generate random 4-digit code (0-6 for each digit)
set /a "code1=!random! %% 7"
set /a "code2=!random! %% 7"
set /a "code3=!random! %% 7"
set /a "code4=!random! %% 7"

set "attempts=0"
set "max_attempts=10"

:cb_loop
cls
echo ================================================================
echo                        Codebreaker
echo ================================================================
echo.
echo Attempts: !attempts! / !max_attempts!
echo.
echo Previous Guesses:
echo.

rem Show previous guesses
for /l %%i in (1,1,!attempts!) do (
    echo Guess %%i: !guess_%%i! - !result_%%i!
)

echo.
set /p guess=Enter your 4-digit guess (or Q to quit): 

if /i "!guess!"=="Q" goto games_menu

rem Validate input
if not "!guess:~3,1!"=="" if "!guess:~4,1!"=="" (
    set "valid=1"
) else (
    echo Invalid! Must be exactly 4 digits.
    timeout /t 2 >nul
    goto cb_loop
)

rem Check each digit
set "g1=!guess:~0,1!"
set "g2=!guess:~1,1!"
set "g3=!guess:~2,1!"
set "g4=!guess:~3,1!"

rem Validate digits are 0-6
set "valid=1"
for %%d in (!g1! !g2! !g3! !g4!) do (
    if %%d GTR 6 set "valid=0"
    if %%d LSS 0 set "valid=0"
)

if !valid! EQU 0 (
    echo Invalid! Each digit must be 0-6.
    timeout /t 2 >nul
    goto cb_loop
)

rem Increment attempts
set /a attempts+=1

rem Check if correct
set "result="
if !g1! EQU !code1! (set "result=!result![1:Z]") else (set "result=!result![1:X]")
if !g2! EQU !code2! (set "result=!result! [2:Z]") else (set "result=!result! [2:X]")
if !g3! EQU !code3! (set "result=!result! [3:Z]") else (set "result=!result! [3:X]")
if !g4! EQU !code4! (set "result=!result! [4:Z]") else (set "result=!result! [4:X]")

rem Save guess and result
set "guess_!attempts!=!guess!"
set "result_!attempts!=!result!"

rem Check if won
if "!guess!"=="!code1!!code2!!code3!!code4!" goto cb_win

rem Check if out of attempts
if !attempts! GEQ !max_attempts! goto cb_lose

goto cb_loop

:cb_win
cls
echo ================================================================
echo                     YOU WIN!
echo ================================================================
echo.
echo You cracked the code: !code1!!code2!!code3!!code4!
echo Attempts used: !attempts! / !max_attempts!
echo.
echo ================================================================
pause
goto games_menu

:cb_lose
cls
echo ================================================================
echo                     GAME OVER!
echo ================================================================
echo.
echo You ran out of attempts!
echo The code was: !code1!!code2!!code3!!code4!
echo.
echo ================================================================
pause
goto games_menu

rem ===========================
rem Rock Paper Scissors Game
rem ===========================
:rps
cls
echo ================================================================
echo                    Rock Paper Scissors
echo ================================================================
echo.
echo 1. Quick Match (1 Round)
echo 2. Best of 3
echo 3. Best of 5
echo 4. Back to Games Menu
echo.
set /p rps_mode=Select mode (1-4): 

if "%rps_mode%"=="1" set "rps_rounds=1" & goto rps_difficulty
if "%rps_mode%"=="2" set "rps_rounds=3" & goto rps_difficulty
if "%rps_mode%"=="3" set "rps_rounds=5" & goto rps_difficulty
if "%rps_mode%"=="4" goto games_menu
goto rps

:rps_difficulty
cls
echo ================================================================
echo                    Select Difficulty
echo ================================================================
echo.
echo 1. Easy   - Random choices, fair game
echo 2. Medium - Smart tactics, cycles forward/backward based on wins
echo 3. Hard   - IMPOSSIBLE - Bot always wins!
echo 4. Back
echo.
set /p rps_diff=Select difficulty (1-4): 

if "%rps_diff%"=="1" (
    set "rps_difficulty=1"
    goto rps_start
)
if "%rps_diff%"=="2" (
    set "rps_difficulty=2"
    goto rps_start
)
if "%rps_diff%"=="3" (
    set "rps_difficulty=3"
    goto rps_start
)
if "%rps_diff%"=="4" goto rps
goto rps_difficulty

:rps_start
cls
echo Starting game with difficulty !rps_difficulty! and !rps_rounds! rounds...
timeout /t 1 >nul
set "player_score=0"
set "bot_score=0"
set "round=1"
set /a "wins_needed=(!rps_rounds!+1)/2"
set "last_result="
set "medium_next=1"

:rps_round
cls
echo ================================================================
echo Rock Paper Scissors - Round !round! / !rps_rounds!
if "!rps_difficulty!"=="1" echo                    (Easy Mode)
if "!rps_difficulty!"=="2" echo                   (Medium Mode)
if "!rps_difficulty!"=="3" echo                    (Hard Mode)
echo ================================================================
echo.
echo                 You: !player_score!  ^|  Bot: !bot_score!
echo.
echo ================================================================
echo.
echo 1. Rock     (beats Scissors)
echo 2. Paper    (beats Rock)
echo 3. Scissors (beats Paper)
echo 4. Quit to Menu
echo.
set /p player_choice=Your choice (1-4): 

if "%player_choice%"=="4" goto games_menu
if "%player_choice%"=="" goto rps_round

rem Validate input
set "valid=0"
for %%i in (1 2 3) do if "%player_choice%"=="%%i" set "valid=1"
if "!valid!"=="0" (
    echo Invalid choice!
    timeout /t 1 >nul
    goto rps_round
)

rem Bot makes choice based on difficulty
if "!rps_difficulty!"=="1" goto rps_easy_bot
if "!rps_difficulty!"=="2" goto rps_medium_bot
if "!rps_difficulty!"=="3" goto rps_hard_bot
rem Fallback to easy if something went wrong
goto rps_easy_bot

:rps_easy_bot
rem Easy - Random choice
set /a "bot_choice=!random! %% 3 + 1"
goto rps_show_result

:rps_medium_bot
rem Medium - Tactical cycling
rem Start with Rock (1), then cycle forward if win, backward if lose
if "!last_result!"=="" set "bot_choice=1" & goto rps_show_result
if "!last_result!"=="win" (
    rem Bot won - go forward: Rock->Paper->Scissors->Rock
    set /a "bot_choice=!medium_next!+1"
    if !bot_choice! GTR 3 set "bot_choice=1"
) else if "!last_result!"=="lose" (
    rem Bot lost - go backward: Rock->Scissors->Paper->Rock
    set /a "bot_choice=!medium_next!-1"
    if !bot_choice! LSS 1 set "bot_choice=3"
) else (
    rem Draw - pick randomly forward or backward
    set /a "random_dir=!random! %% 2"
    if !random_dir! EQU 0 (
        rem Go forward
        set /a "bot_choice=!medium_next!+1"
        if !bot_choice! GTR 3 set "bot_choice=1"
    ) else (
        rem Go backward
        set /a "bot_choice=!medium_next!-1"
        if !bot_choice! LSS 1 set "bot_choice=3"
    )
)
goto rps_show_result

:rps_hard_bot
rem Hard - IMPOSSIBLE MODE - Bot always counters you
rem Rock=1, Paper=2, Scissors=3
rem To beat: Rock->Paper, Paper->Scissors, Scissors->Rock
if "%player_choice%"=="1" set "bot_choice=2"
if "%player_choice%"=="2" set "bot_choice=3"
if "%player_choice%"=="3" set "bot_choice=1"
goto rps_show_result

:rps_show_result
rem Convert choices to names
set "p_name=Rock"
set "b_name=Rock"
if "%player_choice%"=="2" set "p_name=Paper"
if "%player_choice%"=="3" set "p_name=Scissors"
if "!bot_choice!"=="2" set "b_name=Paper"
if "!bot_choice!"=="3" set "b_name=Scissors"

rem Display choices
cls
echo ================================================================
echo Rock Paper Scissors - Round !round! / !rps_rounds!
if "!rps_difficulty!"=="1" echo                    (Easy Mode)
if "!rps_difficulty!"=="2" echo                   (Medium Mode)
if "!rps_difficulty!"=="3" echo                    (Hard Mode)
echo ================================================================
echo.
echo                 You: !player_score!  ^|  Bot: !bot_score!
echo.
echo ================================================================
echo.
echo You chose: !p_name!
echo Bot chose: !b_name!
echo.

rem Determine winner
set "result=draw"
set "last_result=draw"
if "%player_choice%"=="!bot_choice!" set "result=draw" & set "last_result=draw"
if "%player_choice%"=="1" if "!bot_choice!"=="3" set "result=win" & set "last_result=lose"
if "%player_choice%"=="2" if "!bot_choice!"=="1" set "result=win" & set "last_result=lose"
if "%player_choice%"=="3" if "!bot_choice!"=="2" set "result=win" & set "last_result=lose"
if "%player_choice%"=="1" if "!bot_choice!"=="2" set "result=lose" & set "last_result=win"
if "%player_choice%"=="2" if "!bot_choice!"=="3" set "result=lose" & set "last_result=win"
if "%player_choice%"=="3" if "!bot_choice!"=="1" set "result=lose" & set "last_result=win"

rem Save medium bot's current choice for draw scenario
set "medium_next=!bot_choice!"

rem Update scores
if "!result!"=="draw" echo It's a DRAW!
if "!result!"=="win" (
    echo You WIN this round!
    set /a player_score+=1
)
if "!result!"=="lose" (
    echo Bot WINS this round!
    set /a bot_score+=1
)

echo.
if "!result!"=="lose" if "!rps_difficulty!"=="3" echo The bot is UNBEATABLE in Hard mode!
timeout /t 2 >nul

rem Check if all rounds are complete
if !round! GEQ !rps_rounds! goto rps_final_result

rem Next round
set /a round+=1
goto rps_round

:rps_player_wins
cls
echo ================================================================
echo                        VICTORY!
echo ================================================================
echo.
echo              Final Score: You !player_score! - !bot_score! Bot
echo.
if !rps_difficulty! EQU 3 (
    echo    IMPOSSIBLE! You beat Hard mode! You're a LEGEND!
) else (
    echo           You defeated the bot! Congratulations!
)
echo.
echo ================================================================
pause
goto games_menu

:rps_bot_wins
cls
echo ================================================================
echo                         DEFEAT!
echo ================================================================
echo.
echo              Final Score: You !player_score! - !bot_score! Bot
echo.
if "!rps_difficulty!"=="3" (
    if !player_score! GEQ !wins_needed! (
        echo    IMPOSSIBLE! You beat Hard mode! You're a LEGEND!
    ) else (
        echo        Hard mode is unbeatable! Try Easy or Medium!
    )
) else (
    if !player_score! GEQ !wins_needed! (
        echo           You defeated the bot! Congratulations!
    ) else (
        echo             Bot wins! Better luck next time!
    )
)
echo.
echo ================================================================
pause
goto games_menu

:rps_final_result
cls
echo ================================================================
echo                      GAME OVER!
echo ================================================================
echo.
echo              Final Score: You !player_score! - !bot_score! Bot
echo.
if !player_score! GTR !bot_score! (
    if "!rps_difficulty!"=="3" (
        echo    WHAT?! You beat HARD mode?! That's INCREDIBLE!
    ) else (
        echo           You WIN the match! Congratulations!
    )
) else if !bot_score! GTR !player_score! (
    if "!rps_difficulty!"=="3" (
        echo        Hard mode is designed to be unbeatable!
    ) else (
        echo             Bot WINS the match! Try again!
    )
) else (
    echo              It's a TIE! Well played!
)
echo.
echo ================================================================
pause
goto games_menu

rem ===========================
rem Tic Tac Toe Game
rem ===========================
:tictactoe
cls
echo ================================================================
echo                       Tic Tac Toe
echo ================================================================
echo.
echo 1. Play with Friend (2 Player)
echo 2. Play with Bot (1 Player)
echo 3. Back to Games Menu
echo.
set /p ttt_mode=Select mode (1-3): 

if "%ttt_mode%"=="1" set "botmode=0" & goto ttt_start
if "%ttt_mode%"=="2" goto ttt_difficulty
if "%ttt_mode%"=="3" goto games_menu
goto tictactoe

:ttt_difficulty
cls
echo ================================================================
echo                    Select Difficulty
echo ================================================================
echo.
echo 1. Easy   - Random moves, beatable
echo 2. Medium - Smart tactics, creates forks
echo 3. Hard   - Nearly impossible, perfect play
echo 4. Back
echo.
set /p difficulty=Select difficulty (1-4): 

if "%difficulty%"=="1" set "botmode=1" & set "botdiff=1" & goto ttt_start
if "%difficulty%"=="2" set "botmode=1" & set "botdiff=2" & goto ttt_start
if "%difficulty%"=="3" set "botmode=1" & set "botdiff=3" & goto ttt_start
if "%difficulty%"=="4" goto tictactoe
goto ttt_difficulty

:ttt_start
cls
echo ================================================================
echo                       Tic Tac Toe
echo ================================================================
echo.

rem Initialize board
for /l %%i in (1,1,9) do set "cell%%i=%%i"
set "player=X"
set "moves=0"

:ttt_loop
cls
if !botmode! EQU 1 (
    if !botdiff! EQU 1 echo ================================================================
    if !botdiff! EQU 1 echo              Tic Tac Toe - You: X  Bot: O (Easy)
    if !botdiff! EQU 1 echo ================================================================
    if !botdiff! EQU 2 echo ================================================================
    if !botdiff! EQU 2 echo             Tic Tac Toe - You: X  Bot: O (Medium)
    if !botdiff! EQU 2 echo ================================================================
    if !botdiff! EQU 3 echo ================================================================
    if !botdiff! EQU 3 echo              Tic Tac Toe - You: X  Bot: O (Hard)
    if !botdiff! EQU 3 echo ================================================================
) else (
    echo ================================================================
    echo                    Tic Tac Toe - Player %player%
    echo ================================================================
)
echo.
echo               !cell1! ^| !cell2! ^| !cell3!
echo              -----------
echo               !cell4! ^| !cell5! ^| !cell6!
echo              -----------
echo               !cell7! ^| !cell8! ^| !cell9!
echo.

rem Bot's turn
if !botmode! EQU 1 if "%player%"=="O" goto bot_move

echo Enter position (1-9) or 'Q' to quit:
set /p move=

if /i "%move%"=="Q" goto games_menu
if "%move%"=="" goto ttt_loop

rem Validate input
set "valid=0"
for %%i in (1 2 3 4 5 6 7 8 9) do if "%move%"=="%%i" set "valid=1"
if "!valid!"=="0" (
    echo Invalid position!
    timeout /t 1 >nul
    goto ttt_loop
)

rem Check if cell is already taken
set "cellvalue=!cell%move%!"
if "!cellvalue!"=="X" goto cell_taken
if "!cellvalue!"=="O" goto cell_taken

rem Make move
set "cell%move%=%player%"
set /a moves+=1

rem Check for winner
call :check_winner
if "!winner!"=="yes" goto ttt_win

rem Check for draw
if !moves! GEQ 9 goto ttt_draw

rem Switch player
if "%player%"=="X" (set "player=O") else (set "player=X")
goto ttt_loop

:bot_move
echo Bot is thinking...
timeout /t 1 >nul

rem EASY MODE - Random moves only
if !botdiff! EQU 1 goto bot_easy

rem MEDIUM MODE - Smart tactics
if !botdiff! EQU 2 goto bot_medium

rem HARD MODE - Perfect play
if !botdiff! EQU 3 goto bot_hard

:bot_easy
rem Pick any random available spot
set /a "randstart=!random! %% 9 + 1"
set "tried=0"
:easy_loop
for /l %%i in (!randstart!,1,9) do (
    set "cellvalue=!cell%%i!"
    if "!cellvalue!" NEQ "X" if "!cellvalue!" NEQ "O" set "move=%%i" & goto bot_make_move
)
for /l %%i in (1,1,!randstart!) do (
    set "cellvalue=!cell%%i!"
    if "!cellvalue!" NEQ "X" if "!cellvalue!" NEQ "O" set "move=%%i" & goto bot_make_move
)
goto bot_make_move

:bot_medium
rem Try to win first
call :bot_find_winning_move O
if "!bot_found!"=="1" goto bot_make_move

rem Block player
call :bot_find_winning_move X
if "!bot_found!"=="1" goto bot_make_move

rem Counter player's first move tactically
if !moves! EQU 1 (
    rem Player took corner - take center
    for %%i in (1 3 7 9) do if "!cell%%i!"=="X" set "move=5" & goto bot_make_move
    rem Player took center - take corner
    if "!cell5!"=="X" set "move=1" & goto bot_make_move
    rem Player took side - take adjacent
    if "!cell2!"=="X" set "move=1" & goto bot_make_move
    if "!cell4!"=="X" set "move=1" & goto bot_make_move
    if "!cell6!"=="X" set "move=3" & goto bot_make_move
    if "!cell8!"=="X" set "move=7" & goto bot_make_move
)

rem Try to create a fork
call :bot_create_fork
if "!bot_found!"=="1" goto bot_make_move

rem Take center
if "!cell5!"=="5" set "move=5" & goto bot_make_move

rem Take corners
for %%i in (1 3 7 9) do (
    set "cellvalue=!cell%%i!"
    if "!cellvalue!"=="%%i" set "move=%%i" & goto bot_make_move
)

rem Take any available
for /l %%i in (1,1,9) do (
    set "cellvalue=!cell%%i!"
    if "!cellvalue!"=="%%i" set "move=%%i" & goto bot_make_move
)
goto bot_make_move

:bot_hard
rem HARD MODE - Minimax-like perfect strategy

rem First move - always take center or corner
if !moves! EQU 0 set "move=5" & goto bot_make_move

rem Try to win
call :bot_find_winning_move O
if "!bot_found!"=="1" goto bot_make_move

rem Block player
call :bot_find_winning_move X
if "!bot_found!"=="1" goto bot_make_move

rem Detect and block player's fork attempts
call :bot_block_fork
if "!bot_found!"=="1" goto bot_make_move

rem Create fork opportunity
call :bot_create_fork
if "!bot_found!"=="1" goto bot_make_move

rem Advanced positioning
rem If player has opposite corners, take side
if "!cell1!"=="X" if "!cell9!"=="X" (
    if "!cell2!"=="2" set "move=2" & goto bot_make_move
    if "!cell4!"=="4" set "move=4" & goto bot_make_move
)
if "!cell3!"=="X" if "!cell7!"=="X" (
    if "!cell2!"=="2" set "move=2" & goto bot_make_move
    if "!cell6!"=="6" set "move=6" & goto bot_make_move
)

rem Take center
if "!cell5!"=="5" set "move=5" & goto bot_make_move

rem Take opposite corner if player has corner
if "!cell1!"=="X" if "!cell9!"=="9" set "move=9" & goto bot_make_move
if "!cell3!"=="X" if "!cell7!"=="7" set "move=7" & goto bot_make_move
if "!cell7!"=="X" if "!cell3!"=="3" set "move=3" & goto bot_make_move
if "!cell9!"=="X" if "!cell1!"=="1" set "move=1" & goto bot_make_move

rem Take any corner
for %%i in (1 3 7 9) do (
    set "cellvalue=!cell%%i!"
    if "!cellvalue!"=="%%i" set "move=%%i" & goto bot_make_move
)

rem Take any side
for %%i in (2 4 6 8) do (
    set "cellvalue=!cell%%i!"
    if "!cellvalue!"=="%%i" set "move=%%i" & goto bot_make_move
)

:bot_make_move
set "cell!move!=O"
set /a moves+=1

rem Check for winner
call :check_winner
if "!winner!"=="yes" goto ttt_win

rem Check for draw
if !moves! GEQ 9 goto ttt_draw

set "player=X"
goto ttt_loop

:bot_create_fork
rem Try to create a fork (two winning opportunities)
set "bot_found=0"

rem Check if we can create fork with corners
if "!cell1!"=="O" if "!cell9!"=="9" if "!cell3!"=="3" set "move=3" & set "bot_found=1" & exit /b
if "!cell1!"=="O" if "!cell9!"=="9" if "!cell7!"=="7" set "move=7" & set "bot_found=1" & exit /b
if "!cell3!"=="O" if "!cell7!"=="7" if "!cell1!"=="1" set "move=1" & set "bot_found=1" & exit /b
if "!cell3!"=="O" if "!cell7!"=="7" if "!cell9!"=="9" set "move=9" & set "bot_found=1" & exit /b

rem Center + corner fork setup
if "!cell5!"=="O" (
    for %%i in (1 3 7 9) do (
        if "!cell%%i!"=="O" (
            rem Find opposite corner
            if %%i EQU 1 if "!cell9!"=="9" set "move=9" & set "bot_found=1" & exit /b
            if %%i EQU 3 if "!cell7!"=="7" set "move=7" & set "bot_found=1" & exit /b
            if %%i EQU 7 if "!cell3!"=="3" set "move=3" & set "bot_found=1" & exit /b
            if %%i EQU 9 if "!cell1!"=="1" set "move=1" & set "bot_found=1" & exit /b
        )
    )
)

exit /b

:bot_block_fork
rem Detect and block player fork attempts
set "bot_found=0"

rem Check if player is setting up corner fork
set /a xcorners=0
for %%i in (1 3 7 9) do if "!cell%%i!"=="X" set /a xcorners+=1

if !xcorners! EQU 2 (
    rem Player has two corners - block with side
    if "!cell1!"=="X" if "!cell9!"=="X" (
        if "!cell2!"=="2" set "move=2" & set "bot_found=1" & exit /b
        if "!cell4!"=="4" set "move=4" & set "bot_found=1" & exit /b
    )
    if "!cell3!"=="X" if "!cell7!"=="X" (
        if "!cell2!"=="2" set "move=2" & set "bot_found=1" & exit /b
        if "!cell6!"=="6" set "move=6" & set "bot_found=1" & exit /b
    )
    if "!cell1!"=="X" if "!cell3!"=="X" if "!cell2!"=="2" set "move=2" & set "bot_found=1" & exit /b
    if "!cell1!"=="X" if "!cell7!"=="X" if "!cell4!"=="4" set "move=4" & set "bot_found=1" & exit /b
    if "!cell3!"=="X" if "!cell9!"=="X" if "!cell6!"=="6" set "move=6" & set "bot_found=1" & exit /b
    if "!cell7!"=="X" if "!cell9!"=="X" if "!cell8!"=="8" set "move=8" & set "bot_found=1" & exit /b
)

rem Check center + corner fork
if "!cell5!"=="X" (
    for %%i in (1 3 7 9) do (
        if "!cell%%i!"=="X" (
            rem Block opposite corner
            if %%i EQU 1 if "!cell9!"=="9" set "move=3" & set "bot_found=1" & exit /b
            if %%i EQU 3 if "!cell7!"=="7" set "move=1" & set "bot_found=1" & exit /b
            if %%i EQU 7 if "!cell3!"=="3" set "move=9" & set "bot_found=1" & exit /b
            if %%i EQU 9 if "!cell1!"=="1" set "move=7" & set "bot_found=1" & exit /b
        )
    )
)

exit /b

:bot_find_winning_move
rem %1 = player symbol to check (O for bot win, X for block)
set "bot_found=0"

rem Check rows
for %%r in (1 4 7) do (
    set /a p1=%%r
    set /a p2=%%r+1
    set /a p3=%%r+2
    call :check_line !p1! !p2! !p3! %1
    if "!bot_found!"=="1" exit /b
)

rem Check columns
for %%c in (1 2 3) do (
    set /a p1=%%c
    set /a p2=%%c+3
    set /a p3=%%c+6
    call :check_line !p1! !p2! !p3! %1
    if "!bot_found!"=="1" exit /b
)

rem Check diagonals
call :check_line 1 5 9 %1
if "!bot_found!"=="1" exit /b
call :check_line 3 5 7 %1

exit /b

:check_line
rem %1 %2 %3 = positions, %4 = symbol
set "v1=!cell%1!"
set "v2=!cell%2!"
set "v3=!cell%3!"

rem Two matching symbols and one empty
if "!v1!"=="%4" if "!v2!"=="%4" if "!v3!" NEQ "X" if "!v3!" NEQ "O" set "move=%3" & set "bot_found=1" & exit /b
if "!v1!"=="%4" if "!v3!"=="%4" if "!v2!" NEQ "X" if "!v2!" NEQ "O" set "move=%2" & set "bot_found=1" & exit /b
if "!v2!"=="%4" if "!v3!"=="%4" if "!v1!" NEQ "X" if "!v1!" NEQ "O" set "move=%1" & set "bot_found=1" & exit /b
exit /b

:cell_taken
echo Cell already taken!
timeout /t 1 >nul
goto ttt_loop

:ttt_win
cls
if !botmode! EQU 1 (
    if !botdiff! EQU 1 echo ================================================================
    if !botdiff! EQU 1 echo                       Game Over! (Easy)
    if !botdiff! EQU 1 echo ================================================================
    if !botdiff! EQU 2 echo ================================================================
    if !botdiff! EQU 2 echo                      Game Over! (Medium)
    if !botdiff! EQU 2 echo ================================================================
    if !botdiff! EQU 3 echo ================================================================
    if !botdiff! EQU 3 echo                       Game Over! (Hard)
    if !botdiff! EQU 3 echo ================================================================
) else (
    echo ================================================================
    echo                       Game Over!
    echo ================================================================
)
echo.
echo               !cell1! ^| !cell2! ^| !cell3!
echo              -----------
echo               !cell4! ^| !cell5! ^| !cell6!
echo              -----------
echo               !cell7! ^| !cell8! ^| !cell9!
echo.
if !botmode! EQU 1 (
    if "%player%"=="X" (
        echo You win! Congratulations!
    ) else (
        echo Bot wins! Better luck next time!
    )
) else (
    echo Player %player% wins!
)
echo.
pause
goto games_menu

:ttt_draw
cls
echo ================================================================
echo                       Game Over!
echo ================================================================
echo.
echo               !cell1! ^| !cell2! ^| !cell3!
echo              -----------
echo               !cell4! ^| !cell5! ^| !cell6!
echo              -----------
echo               !cell7! ^| !cell8! ^| !cell9!
echo.
echo It's a draw!
echo.
pause
goto games_menu

:check_winner
set "winner=no"
rem Check rows
if "!cell1!"=="!cell2!" if "!cell2!"=="!cell3!" set "winner=yes"
if "!cell4!"=="!cell5!" if "!cell5!"=="!cell6!" set "winner=yes"
if "!cell7!"=="!cell8!" if "!cell8!"=="!cell9!" set "winner=yes"
rem Check columns
if "!cell1!"=="!cell4!" if "!cell4!"=="!cell7!" set "winner=yes"
if "!cell2!"=="!cell5!" if "!cell5!"=="!cell8!" set "winner=yes"
if "!cell3!"=="!cell6!" if "!cell6!"=="!cell9!" set "winner=yes"
rem Check diagonals
if "!cell1!"=="!cell5!" if "!cell5!"=="!cell9!" set "winner=yes"
if "!cell3!"=="!cell5!" if "!cell5!"=="!cell7!" set "winner=yes"
exit /b

rem ===========================
rem HyperZShell Option
rem ===========================
:run_hyperzshell
cls
set "HZS_PATH="
set "SCRIPT_DIR=%~dp0"

rem Check in same directory as HyperZOS
if exist "%SCRIPT_DIR%HyperZShell\HyperZShell.bat" (
    set "HZS_PATH=%SCRIPT_DIR%HyperZShell\HyperZShell.bat"
    goto launch_hyperzshell
)

rem Check in same directory as HyperZOS (direct file)
if exist "%SCRIPT_DIR%HyperZShell.bat" (
    set "HZS_PATH=%SCRIPT_DIR%HyperZShell.bat"
    goto launch_hyperzshell
)

rem Check in Downloads folder
if exist "%USERPROFILE%\Downloads\HyperZShell\HyperZShell.bat" (
    set "HZS_PATH=%USERPROFILE%\Downloads\HyperZShell\HyperZShell.bat"
    goto launch_hyperzshell
)

rem Check in Downloads (direct file)
if exist "%USERPROFILE%\Downloads\HyperZShell.bat" (
    set "HZS_PATH=%USERPROFILE%\Downloads\HyperZShell.bat"
    goto launch_hyperzshell
)

rem Check parent directory of script
if exist "%SCRIPT_DIR%..\HyperZShell\HyperZShell.bat" (
    set "HZS_PATH=%SCRIPT_DIR%..\HyperZShell\HyperZShell.bat"
    goto launch_hyperzshell
)

rem Check parent directory (direct file)
if exist "%SCRIPT_DIR%..\HyperZShell.bat" (
    set "HZS_PATH=%SCRIPT_DIR%..\HyperZShell.bat"
    goto launch_hyperzshell
)

rem HyperZShell not found
echo HyperZShell not found! 
echo Searched in:
echo  - %SCRIPT_DIR%HyperZShell\
echo  - %SCRIPT_DIR%
echo  - %USERPROFILE%\Downloads\HyperZShell\
echo  - %USERPROFILE%\Downloads\
echo  - %SCRIPT_DIR%..\HyperZShell\
echo  - %SCRIPT_DIR%..
echo.
echo Please ensure HyperZShell.bat is in one of these locations.
pause
goto menu

:launch_hyperzshell
call "%HZS_PATH%"
goto menu

rem ===========================
rem HyperZPad Text Editor
rem ===========================
:hyperzpad
cls
echo --- HyperZPad ---
echo.
set /p filename=Enter file name: 
if "%filename%"=="" goto menu

rem Check if filename contains a dot (extension already provided)
echo %filename% | find "." >nul
if errorlevel 1 (
    rem No extension found, add .txt
    set "filename=%filename%.txt"
)

set "FILEPATH=%ROOT%\Documents\%filename%"

rem If file doesn't exist, create it
if not exist "%FILEPATH%" echo.>"%FILEPATH%"

cls
echo ================================================================
echo                 HyperZPad - Editing %filename%
echo ================================================================
echo.
echo Commands: Type "SAVE" to save and exit, "EXIT" to exit without saving
echo          Type "VIEW" to see current content
echo.

:hzpad_loop
set "line="
set /p line=^> 
if /i "%line%"=="SAVE" goto hzpad_save
if /i "%line%"=="EXIT" goto menu
if /i "%line%"=="VIEW" goto hzpad_view
if not "%line%"=="" >>"%FILEPATH%" echo !line!
goto hzpad_loop

:hzpad_view
cls
echo ================================================================
echo              Current content of %filename%
echo ================================================================
echo.
type "%FILEPATH%" 2>nul
echo.
echo ================================================================
echo.
pause
cls
echo ================================================================
echo                 HyperZPad - Editing %filename%
echo ================================================================
echo.
echo Commands: Type "SAVE" to save and exit, "EXIT" to exit without saving
echo          Type "VIEW" to see current content
echo.
goto hzpad_loop

:hzpad_save
cls
echo File saved to %FILEPATH%.
pause
goto menu

rem ===========================
rem Exit HyperZOS
rem ===========================
:exitos
cls
echo Shutting down HyperZOS...
timeout /t 1 >nul
exit /b
