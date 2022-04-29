@rem compile.bat

@echo off

@cd %~dp0

@net session >nul 2>&1
@if NOT %ERRORLEVEL% == 0 goto noadmin

@call selsca.exe remove

@call "C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe" /in selsca.ahk /out selsca.exe /icon selsca.ico /bin "C:\Program Files\AutoHotkey\Compiler\Unicode 64-bit.bin"

@goto end


:noadmin
@echo Fehler, Script muss als Administrator ausgefuehrt werden...Abbruch!
@echo.
@pause
@goto end


:end
exit