@rem create_selsca_exe_link_with_hidewindow.bat
@rem parameter: hidewindow

@set app=selsca

@cd %~dp0

@powershell "$s=(New-Object -COM WScript.Shell).CreateShortcut('%~dp0\%app%.lnk');$s.TargetPath='%~dp0\%app%.exe';$s.Arguments='hidewindow';$s.Save()"



