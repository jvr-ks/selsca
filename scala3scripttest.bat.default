@rem scala3scripttest.bat

@rem Download Scala from:
@rem https://github.com/lampepfl/dotty/releases

@echo off

cd %~dp0

rem Select Scala Scala3-3.2.2
call curl http://localhost:65501/selsca?version=(Scala3-3.2.2)

echo.
echo.
@rem update environment variables
call %~dp0resetvars.vbs
call %TEMP%\resetvars.bat

call scala -version

timeout /T 5
echo.

call scala scala3scripttest.scala


rem Select Scala Scala-2.13.8 again
call curl http://localhost:65501/selsca?version=(Scala-2.13.8)

echo.
echo.
echo finished!

pause
