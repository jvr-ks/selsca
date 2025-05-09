# Selsca  
(**Sel**ect **Sca**la)  

Set the default scala version for use in a scala-script.  

If using [scala-cli](https://scala-cli.virtuslab.org/) you may set the scalaversion with:  
  
````  
//> using scala "3.6.4"  
````
to make a scala-script now!  
Read:  [What is the difference between Scala runner and Scala CLI](https://virtuslab.com/blog/scala/scala-cli-the-new-scala-runner/) too.  

file test.scala  
````
//> using scala "3.6.4"  

@main def hello() = println("Hello, World")
````
  
scala-cli test.scala
````
Compiling project (Scala 3.6.3, JVM (23))
Compiled project (Scala 3.6.3, JVM (23))
Picked up JAVA_TOOL_OPTIONS: -Dfile.encoding=UTF8
Hello, World
````
ufb!  

  
## Caution
**Windows only**  
**This tool changes the Windows (System)-PATH environment variable of your Windows.**  
**Please do not use it, if you cannot handle System-PATH environment variable problems!**   
  
* **Removes System-PATH entries:**  
* * All entries containing the characters "\\scala\\bin"     
  
The System-PATH is logged to the file "_thePathBackup.txt" before.  
(The last 10 values).
  
#### Download via Updater (preferred method)
Portable, run from any directory, but running from a subdirectory of the windows programm-directories   
(C:\Program Files, C:\Program Files (x86) etc.)  
requires admin-rights and is not recommended!  
**Installation-directory (is created by the Updater) must be writable by the app!** 
  
To download **selsca.exe** 64 bit Windows from Github please use:  
  
[updater.exe 64bit](https://github.com/jvr-ks/selsca/raw/main/updater.exe)  
  
(Updater viruscheck please look at the [Updater repository](https://github.com/jvr-ks/updater)) 

* From time to time there are some false positiv virus detections
[Virusscan](#virusscan) at Virustotal see below.  
  
The default installation-directory is:  
C:\jvrde\selsca
  
Open this directory with your filemanger.  
"selsca.exe" does the work (stays running as a service).  
The "scalaVersion.exe" shows the actual selected Scala version (does nothing more than a "scala -version" command).  
There are some batch-files to play with:
- "restApiTest.bat"
- "consoleTest.bat"

  
#### Description   
This simple tool can switch among different scala runtime versions.  
Uses a Powershell command to set the System-Path (64 bit Powershell must be available),  
must be **run as an administrator** therefor!  
  
Selsca must be run as an administrator.  
If not started from an admin console, the UAC-Request popsup.  
  
#### Using Selsca  
Start Selsca and click on an entry in the Scala-version list, 
(if the window loses the focus, Selsca keeps running in the background, reactivate it with the Hotkey: \[ALT + p])  
or  
Use Selsca on the commandline or inside a batch script \*1),
example:  
selsca.exe (Scala-2.13.8)  
or  
Set the scala version via a REST-Api call (Selsca already running in the background),  
example using "curl":  
call curl http://localhost:65501/selsca?version=(Scala3-3.2.2)  
example using your **browser**,  
[Select Scala-2.13.8](http://localhost:65501/selsca?version=\(Scala-2.13.8\))  
  
You may use the included extra app "scalaVersion.exe" to check the actual Scala-version. 
(Just executes a "scala -version"-command).
  
#### Selsca operation
With a \[Click] on an entry in the list:  
- All PATH entries containing the following characters:  
"\\scala\\bin" are removed!   
- The Scala bin-directory is prepended to the path.  
- The "SCALA_HOME" environment-variable is set accordingly.  
  
#### Scala-version list click-modifiers
  
Click-modifier | Operation
------------ | -------------
\[Shift] | edit selected entry
\[Ctrl] | open the scala-path with the default filemanager
  
#### Configuration-file  
The Configuration-file ("selsca_<ComputerName>.ini") is generated automatically, if it doesn't already exist.  
There is a menu-button to edit the Configuration-file.  
  
Section [hotkeys]:  
Hotkeys can be set to "off" by adding the word "off" to the definition.  
The two app-hotkeys defaults are:  
menuhotkey="!p", i.e. \[ALT] + \[p] to show the app-window  
exithotkey="+!p", i.e. \[SHIFT] + \[ALT] + \[p] to exit the app and remove it from memory  
(you may use the button "Kill the app" also)  
  
Primary hotkey modifiers:  
Hotkey prefix | Modifier Key |  Remark
------------ | ------------- | ------------- 
! | \[ALT] |
^ | \[CTRL] |
\# | \[WIN] |
\+ | \[SHIFT] |  
    
Other [Autohotkey Hotkeys](https://www.autohotkey.com/docs/Hotkeys.htm) hotkeys-characters are usable,  
but are untested.  
Only simple hotkeys are good to remember!  
  
#### HINT 
Check scala version in a running REPL:  
println(scala.util.Properties.versionString)  

#### Definitions-file:  
**"selsca.txt"**,  
contains on each line delimited by a comma or a tab:  

Entry 1 | Entry 2 | Entry 3  
------------ | ------------- | -------------  
Any name, | path of the Scala directory, | path of the Scala bin-directory *)  
  
The name: What ever name you want :-)  
Path of the Scala directory: The path to the Scala-Installation.   
  
*)  
Path of the Scala bin-directory: the \bin subdirectory of the Scala-Installation,  
use "..." as a shortcut of the scala-installation directory-path!  
  
**Attention: Remove any trailing "\\" from the path!**  
  
  
#### Hotkeys  
**Hotkeys are configurable** by editing the Configuration-file "selsca_<ComputerName>.ini".  
Use [Notepad++](https://notepad-plus-plus.org/) to edit the Configuration-file.  
[Hotkey modifier symbols](https://www.autohotkey.com/docs/Hotkeys.htm).
Only simple Hotkey modifications are reflected in the menu.  
(Parsing is limited to \[CTRL], \[ALT], \[WIN], \[SHIFT]).  


#### RestApi  
If Selsca is running it listens to commands of the form:  
URL: http://localhost:65501/selsca?version=(<Scala-version> | <remove>)  
Can be use with curl:  
curl http://localhost:65501/selsca?version=(Scala-2.13.6)  
or a browser:  
[Select Scala-2.13.8](http://localhost:65501/selsca?version=\(Scala-2.13.8\))  
[Remove Selsca from memory](http://localhost:65501/selsca?version=remove) 
  
** Setting via the server takes a few seconds!  **
  
The port-number is defined in the Configuration-file: "selscaRestPort=65501" (65501 is default) 
  
Use "restapioff" start-parameter to disable the RestApi server.  
   
#### Inside a batch-file  
If environment variables are changed during a batch-file execution,  
they must be reread to get the new values.
This can be done via the Visual Basic script, "resetvars.vbs".  
The script generates a batchfile "resetvars.bat" in the temporary directory, 
call this batchfile to reread the environment variables then.  
Example:  
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
  
  
#### Requirements
* Windows 10

#### Sourcecode
Github URL [github](https://github.com/jvr-ks/selsca).
[Autohotkey format](https://www.autohotkey.com)

#### Hotkeys
[Overview of all default Hotkeys used by my Autohotkey "tools"](https://github.com/jvr-ks/cmdlinedev/blob/main/hotkeys.md)
 
#### scalaVersion
"[scalaVersion.exe](https://github.com/jvr-ks/selsca/raw/main/scalaVersion.exe)" shows the current active (in the path) Scala version.  
  
#### Latest changes
  
Version (>=)| Change
------------ | -------------
0.035 | Updater integration
0.031 | File "mime.type" created auto., if not existent
0.030 | UAC request integrated
  
#### Known issues / bugs 
Issue / Bug | Type | fixed in version
------------ | ------------- | -------------
- | bug | -
  
  
#### License: MIT  
Permission is hereby granted, free of charge,  
to any person obtaining a copy of this software and associated documentation files (the "Software"),  
to deal in the Software without restriction,  
including without limitation the rights to use,  
copy, modify, merge, publish, distribute, sub license, and/or sell copies of the Software,  
and to permit persons to whom the Software is furnished to do so, subject to the following conditions:  
  
The above copyright notice and this permission notice shall be included in all copies  
or substantial portions of the Software.  
  
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,  
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,  
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,  
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,  
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE  
OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.  
  
Copyright (c) 2020 J. v. Roos  
  
Start of development: 2021/04/17 


<a name="virusscan">


##### Virusscan at Virustotal 
[Virusscan at Virustotal, selsca.exe 64bit-exe, Check here](https://www.virustotal.com/gui/url/bf89ffe0f4f09bca2fd35f696f2c28716cd5107c2dcff1070621a002909bcca8/detection/u-bf89ffe0f4f09bca2fd35f696f2c28716cd5107c2dcff1070621a002909bcca8-1746787052
)  
Use [CTRL] + Click to open in a new window! 
