@rem setScala3Version.3.2.2.bat

@echo off

call curl http://localhost:65501/selsca?version=(Scala3-3.2.2)


rem update environment variables
call %~dp0resetvars.vbs
call %TEMP%\resetvars.bat




