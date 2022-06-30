# Selsca  
(**Sel**ect **Sca**la)  
    
## Caution
**Windows only**  
**This tool changes the Windows (System)-PATH environment variable of your Windows.**  
**Please do not use it, if you cannot handle System-PATH environment variable problems!**   
  
* **Removes System-PATH entries:**  
* * All entries containing the characters "\\scala\\bin"     
  
The System-PATH is logged to the file "_thePathBackup.txt" before.  
(The last 10 values).
  
#### [-> Latest changes / bug fixes](latest_changes.md)
  
Tip: On Windows/Linux you can start a [selection of apps](https://github.com/coursier/apps) with a selected Scala-version using [Coursier](https://get-coursier.io/) also.  
Examples:  
cs launch ammonite \--scala-version 2.13.5  
cs launch dotty-repl \--scala-version 2.13.5 
   
#### App status
Start of development: 2021/04/17  
**Files use UTF-8 encoding (no BOM).**    
  
**Beta!**  
Usable, but development has not finished yet. ...   
  
### HINT
* **Remember: An already running shell (console) must be reopened to reflect the changes of the Scala-Path!**  
* If used with SBT add "ThisBuild / autoScalaLibrary := false" to the "build.sbt"-file!  
(But this tool is intendet to be used with scala-scripts, so if you use sbt, it is a good idea to select Scala-version  
with an entry of scalaVersion := "..." in the SBT build-file).   

#### Files needed to run Selsca / Download
(Right-click ... save as ... to download)  
* [selsca.exe](https://github.com/jvr-ks/selsca/raw/master/selsca.exe) App   
  
* [selsca.ini](https://github.com/jvr-ks/selsca/raw/master/selsca.ini) Configuration-file, created if not existent  
  
* [selsca.txt](https://github.com/jvr-ks/selsca/raw/master/selsca.txt) Definitions-file  
  
* [selscaLinkList.txt](https://github.com/jvr-ks/selsca/raw/master/selscaLinkList.txt) (optional)  

Virus check see below.  
  
#### Description   
This simple tool can switch among different scala runtime versions.  
Uses a Powershell command to set the System-Path (64 bit Powershell must be available),  
must be **run as an administrator** therefor!  
  
Right click "selsca.exe", select "Run as administrator", 
   
or  
  
Prepare once: Right click, select "Create Shortcut".  
Right click on the Shortcut "selsca.lnk", -> "Advanced..." -> Select "Run as Administrator".    
  
Then allways click on "selsca.lnk" to start selsca.
  
or  

use the batch-file: "create_selsca_exe_link_with_hidewindow.bat" once to create an autostart entry.  
Selsca ist started in the background then. Use the hotkey to show the menu.  


Call from a batch-file or command-line via selection-name:  
**selsca.lnk (Scala-2.13.6)**
  
**Blanks are NOT allowed in the selection-name!**  
  
  
With a \[Click] on an entry in the list:  
1. All PATH entries containing the following characters:  
"\\scala\\bin" 
are removed!   
  
The Scala bin-directory is prepended to the path then.  
  
2. The "SCALA_HOME" environment-variable is set accordingly.  

If the Selsca window loses the focus (or by a click on the window minimize button),  
Selsca goes to the background an can be activated again via the hotkey (default is: \[ALT + p]).    
  
**Other click-operations currently defined:**  
  
Click-modifier | Operation
------------ | -------------
\[Shift] | edit selected entry
\[Ctrl] | open the path with the default filemanager

#### Configuration 
Configuration is done by a few config-files,  
use [Notepad++](https://notepad-plus-plus.org/) to edit the config-files.  
  
Definitions-file:  
**"selsca.txt"**,  
contains on each line delimited by a comma or a tab:  

Entry 1 | Entry 2 | Entry 3
------------ | ------------- | -------------
Any name, | path of the Scala directory, | path of the Scala bin-directory *)  
  

The name: What ever name you want :-)  
Path of the Scala directory: The path to the Scala-Installation.   

*)
Path of the Scala bin-directory: In allmost very cases the \bin subdirectory of the Scala-Installation.  
Three points "..." is a shortcut of the Path of the Scala-Installation directory!  
  
**Attention: Remove any trailing "\\" from the path!**  

Configuration-file:
**"selsca.ini"**, 
hotkey configurations etc.  
  
Default hot key is: 
* **\[ALT + p]** open menu  
* **\[SHIFT + ALT + p]** remove app from memory.   
  
#### Hotkeys
**Hotkeys are configurable** by editing the config-file "selsca.ini".  
Use [Notepad++](https://notepad-plus-plus.org/) to edit the config-file.  
[Hotkey modifier symbols](https://www.autohotkey.com/docs/Hotkeys.htm).
Only simple Hotkey modifications are reflected in the menu.  
(Parsing is limited to \[CTRL], \[ALT], \[WIN], \[SHIFT]).  


#### RestApi
If Selsca is running it listens to commands of the form:  
curl http://localhost:65501/selsca?version=(Scala-2.13.6)  
(With curl brackets must be escaped, will change selsca to use round brackests soon!)  
or URL in a browser:  
http://localhost:65501/selsca?version=(Scala-2.13.6)  
  
** Setting via the server takes a few seconds!  **
  
The port-number is defined in the Configuration-file: "selscaRestPort=65501" (65501 is default) 
  
Use "restapioff" start-parameter to disable the RestApi server.  
   
Can set the Scala-version (the Windows-Path) inside a batch-file now, without being an admin,  
but a batch-process gets its environment at the start (and inherits it to any subprocess).    

Using the Visual Basic script, "resetvars.vbs", which generates a batchfile "resetvars.bat" in the temporary directory,    
environment variables can be reread, example batchfile,    
(needs curl and installed Scala 2.10.7 + Scala-2.13.6):  

```@rem restApiTest.bat

@echo off
echo Version is:
call scala -version
echo.
timeout /t 5

@rem activate "old" version
call curl http://localhost:65501/selsca?version=(Scala-2.10.7)
echo.

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

@rem reread environment variables
call %~dp0resetvars.vbs
call %TEMP%\resetvars.bat

echo.
echo Version now is:
call scala -version
echo.

pause


```
  
("resetvars.vbs" must be in the Windows-Path)  
  
** Besides that, the purpose of "selsca" is NOT to temporary switch the Scala-version in a batch-file,     
because this can be done with path=scalapathXYZ;%path% and "set SCALA_HOME= ..." etc. !** 
  
#### Requirements
* Windows 10 or later only.

#### Sourcecode
Github URL [github](https://github.com/jvr-ks/selsca).
[Autohotkey format](https://www.autohotkey.com)

#### Hotkeys
[Overview of all default Hotkeys used by my Autohotkey "tools"](https://github.com/jvr-ks/cmdlinedev/blob/master/hotkeys.md)
 
#### scalaVersion
"scalaVersion.exe" shows (at the cursor and top-left) the current active (in the path) Scala version.  
  
* [scalaVersion.exe](https://github.com/jvr-ks/selsca/raw/master/scalaVersion.exe)    
  
#### License: MIT
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sub-license, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANT-ABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Copyright (c) 2020 J. v. Roos

#### TODO
"scala3"

<a name="virusscan">


##### Virus check at Virustotal 
[Check here](https://www.virustotal.com/gui/url/c042a156149865089c2242d6d79d7a4dfd6d668a55d4d4d6436f1143eb597c3a/detection/u-c042a156149865089c2242d6d79d7a4dfd6d668a55d4d4d6436f1143eb597c3a-1656587281
)  
Use [CTRL] + Click to open in a new window! 
