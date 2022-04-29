@rem test1.bat

@echo off

cd %~dp0

@net session >nul 2>&1
@if NOT %ERRORLEVEL% == 0 goto noadmin

start selsca.exe (Scala-2.11.12)
echo Please manually check scala version (Scala-2.11.12) with scalaVersion.exe
pause


start selsca.exe (Scala-2.13.6)

echo Please manually check scala version (Scala-2.13.6) with scalaVersion.exe
pause

@goto end

:noadmin
@echo Fehler, Script muss als Administrator ausgefuehrt werden...Abbruch!
@echo.
@pause
@goto end


:end
exit



