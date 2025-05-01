@rem restart.bat
@rem !file is overwritten by update process!

@cd %~dp0


@echo 
@echo.
@echo Please press a key to restart selsca (%1 bit)!
@echo.
@pause

@echo off

@set version=%1
@if [%1]==[64] set version=

@if [%2]==[noupdate] goto noupdate

@copy /Y selsca.exe.tmp selsca%version%.exe

:noupdate
@del selsca.exe.tmp
@start selsca%version%.exe showwindow

:end
@exit