@rem compile_scalaVersion.bat

@cd %~dp0

@echo off

@call "C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe" /in scalaVersion.ahk /out scalaVersion.exe  /icon scalaVersion.ico

@exit
