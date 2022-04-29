@rem restApiTest.bat


@echo off
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
call curl http://localhost:65501/selsca?version=(Scala-2.13.6)
echo.
timeout /t 3

@rem reread environment variables
call %~dp0resetvars.vbs
call %TEMP%\resetvars.bat

echo.
echo Version now is:
call scala -version
echo.

pause



