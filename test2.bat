@rem test2.bat
@rem _switchscala_

@echo off

cd %~dp0

call curl http://localhost:65501/selsca?version=(Scala-2.11.12)  

echo.
echo Please manually check scala version
pause


call curl http://localhost:65501/selsca?version=(Scala-2.13.6)   

echo.
echo Please manually check scala version
pause



