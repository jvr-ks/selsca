@rem testDirectCall.bat


@echo off

cd %~dp0

net session >nul 2>&1
if NOT %ERRORLEVEL% == 0 goto noadmin

selsca.exe remove

timeout /t 3


start selsca.exe hidewindow (Scala-2.11.12)

echo Next Scala version should be: Scala-2.11.12
pause

rem reread environment variables
call resetvars.vbs
call %TEMP%\resetvars.bat

call scala -version

pause

start selsca.exe hidewindow (Scala-2.13.8)

echo Next Scala version should be: Scala-2.13.8
pause

rem reread environment variables
call resetvars.vbs
call %TEMP%\resetvars.bat

call scala -version

pause

start selsca.exe hidewindow (Scala3-3.2.2)

echo Next Scala version should be: Scala3-3.2.2
pause

rem reread environment variables
call resetvars.vbs
call %TEMP%\resetvars.bat

call scala -version

goto :EOF

:noadmin
echo Error, run batch as an admin!
echo.
pause




