@rem testRestApi.bat

@echo off

cd %~dp0

net session >nul 2>&1
if NOT %ERRORLEVEL% == 0 goto noadmin

start selsca hidewindow


echo Version is:
call scala -version
echo.
timeout /t 5

@rem activate "old" version
call curl http://localhost:65501/selsca?version=(Scala-2.10.7)
echo.
timeout /t 3

@rem reread environment variables
call %~dp0resetvars.vbs
call %TEMP%\resetvars.bat

echo.
echo Version now is:
call scala -version
echo.

timeout /t 5

@rem back to actual version
call curl http://localhost:65501/selsca?version=(Scala-2.13.8)
echo.
timeout /t 3

@rem reread environment variables
call %~dp0resetvars.vbs
call %TEMP%\resetvars.bat

echo.
echo Version now is:
call scala -version
echo.

echo.
echo Call of scalaVersion.exe shows Scala version on the top of the screen
echo.

call scalaVersion

echo.
echo Finished!
pause
goto :EOF

:noadmin
echo Error, run batch as an admin!
echo.
pause


