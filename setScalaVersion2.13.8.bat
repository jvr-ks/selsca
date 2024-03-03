@rem setScalaVersion2.13.8.bat

@echo off

call curl http://localhost:65501/selsca?version=(Scala-2.13.8)


rem update environment variables
call %~dp0resetvars.vbs
call %TEMP%\resetvars.bat




