/*
 *********************************************************************************
 * 
 * selsca.ahk
 * 
 * use UTF-8 (no BOM)
 * 
 * Version -> appVersion
 * 
 * Copyright (c) 2020 jvr.de. All rights reserved.
 *
 *
 *********************************************************************************
*/

/*
 *********************************************************************************
 * 
 * MIT License
 * 
 * 
 * Copyright (c) 2020 jvr.de. All rights reserved.
 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sub-license, and/or sell copies 
 * of the Software, and to permit persons to whom the Software is furnished to do
 * so, subject to the following conditions:

 * The above copyright notice and this permission notice shall be included in all 
 * copies or substantial portions of the Software.

 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANT-ABILITY, 
 * FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE 
 * UTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN 
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
  *********************************************************************************
*/

#NoEnv
#Warn
#SingleInstance force
#Persistent

#Include %A_ScriptDir%

; https://github.com/zhamlin/AHKhttp
#include, Lib\AHKhttp.ahk

; http://www.autohotkey.com/forum/viewtopic.php?p=355775
#include, Lib\AHKsock.ahk


;auto-include Lib\..
;hkToDescription.ahk
;hotkeyToText.ahk
;ScrollBox.ahk


; force admin rights
full_command_line := DllCall("GetCommandLine", "str")
allparams := ""
for keyGL, valueGL in A_Args {
  allparams .= valueGL . " "
}
    
if (!A_IsAdmin) {
  if (A_IsCompiled){
    if (!RegExMatch(full_command_line, "\/restart")) {
      Run *RunAs %A_ScriptFullPath% /restart %allparams%
      ExitApp
    } else {
      msgbox, SEVERE ERROR, failed to restart as an Admin!
    }
  } else {
    if (!RegExMatch(full_command_line, "\/restart")) {
      Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%" %allparams%
      ExitApp
    } else {
      msgbox, SEVERE ERROR, failed to restart as an Admin!
    }
  }
}

; comment out to use default speed
;SetBatchLines, -1

selscaRestPortDefault := 65501
selscaRestPort := selscaRestPortDefault

SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

FileEncoding, UTF-8-RAW

wrkDir := A_ScriptDir . "\"

appName := "Selsca"
appnameLower := "selsca"
extension := ".exe"
appVersion := "0.048"

bit := (A_PtrSize=8 ? "64" : "32")

if (!A_IsUnicode)
  bit := "A" . bit

bitName := (bit="64" ? "" : bit)

app := appName . " " . appVersion . " (" . bit . " bit)"

configFile := appnameLower . "_" . A_ComputerName . ".ini"

selscaFileDefault := "selsca.txt"
selscaFile := selscaFileDefault

linkListFileDefault := "selscaLinkList.txt"
linkListFile := linkListFileDefault

toolsFileDefault := "selscaTools.txt"
toolsFile := toolsFileDefault

listWidthDefault := 800
listWidth := listWidthDefault

fontDefault := "Segoe UI"
font := fontDefault

fontsizeDefault := 9
fontsize := fontsizeDefault

linesInListMaxDefault := 30
linesInListMax := linesInListMaxDefault

notepadPathDefault := "C:\Program Files\Notepad++\notepad++.exe"
notepadpath := notepadPathDefault

menuhotkeyDefault := "!p"
exitHotkeyDefault := "+!p"
menuHotkey := menuhotkeyDefault
exitHotkey := exitHotkeyDefault

selscaEntriesArr := []
linkListArr := {}

autoconfirm := false

createMime()

pathBackup := "_thePathBackup.txt"

;------------------------------- Gui parameter -------------------------------
activeWin := 0
windowPosXDefault := 0
windowPosYDefault := 0
clientWidthDefault := 800
clientHeightDefault := 600

windowPosX := windowPosXDefault
windowPosY := windowPosYDefault
clientWidth := clientWidthDefault
clientHeight := clientHeightDefault

borderLeft := 2
borderRight := 2
borderTop := 40 ; reserve statusbar space


;------------------------------ Default values ------------------------------
localVersionFileDefault := "version.txt"
serverURLDefault := "https://github.com/jvr-ks/"
serverURLExtensionDefault := "/raw/main/"

localVersionFile := localVersionFileDefault
serverURL := serverURLDefault
serverURLExtension := serverURLExtensionDefault

updateServer := serverURL . appnameLower . serverURLExtension

;-------------------------------- read param --------------------------------
hasParams := A_Args.Length()
autoSelectName := ""
starthidden := false
restapi := true

if (hasParams != 0){
  Loop % hasParams
  {
    if(eq(A_Args[A_index],"remove")){
      showHint("Selsca removed!", 2000)
      sleep,2000
      ExitApp,0
    }

    if(eq(A_Args[A_index],"hidewindow")){
      starthidden := true
    }

    if(eq(A_Args[A_index],"restapioff")){
      restapi := false
    }

    FoundPos := RegExMatch(A_Args[A_index],"\([\w.-]+?\)", found)
    
    If (FoundPos > 0){
      autoSelectName := found
      showHint(app . " selected entry: " . autoSelectName, 3000)
    }
  }
}

prepare()

;-------------------------------- serverHttp --------------------------------
paths := {}
paths["/selsca"] := Func("selscaRest")

if (restApi){
  serverHttp := new HttpServer()
  serverHttp.LoadMimes(A_ScriptDir . "/mime.types")
  serverHttp.SetPaths(paths)
  serverHttp.Serve(selscaRestPort)
}

if (starthidden){
  hktext := hotkeyToText(menuHotkey)
  tipScreenTopTime("Started " . app . ", Hotkey is: " . hktext, 4000)
}

mainWindow(starthidden)

if (autoSelectName != "")
  autoSelect(autoSelectName)


return

;-------------------------------- selscaRest --------------------------------
selscaRest(ByRef req, ByRef res) {
; request example -> curl http://localhost:65501/selsca?version=(Scala-2.13.5)
  v := req.queries["version"]
  res.SetBodyText("Setting Scala version to: " . v)
  autoSelect(v)
  res.status := 200
  
  return
}
;------------------------------ registerWindow ------------------------------
registerWindow(){
  global activeWin
  
  activeWin := WinActive("A")

  return
}
;-------------------------------- checkFocus --------------------------------
checkFocus(){
  global hMain

  h := WinActive("A")
  if (hMain != h){
    hideWindow()
  }
    
  return
}
;-------------------------------- mainWindow --------------------------------
mainWindow(hide := false) {
  global hMain, font, fontsize
  global windowPosX, windowPosY, clientWidth, clientHeight
  global selscaEntriesArr, selscaFile, toolsFile, configFile, LinkListFile, pathBackup
  global app, appName, appVersion
  global menuHotkey, exitHotkey
  global listWidth, LV1
  global linesInListMax, linesInListMaxDefault

  Menu, Tray, UseErrorLevel   ; This affects all menus, not just the tray.

  Menu, MainMenu, DeleteAll
  Menu, MainMenuEdit, DeleteAll
  Menu, MainMenuInternet, DeleteAll
  Menu, MainMenuUpdate, DeleteAll
  Menu, MainMenuTools, DeleteAll
  
  Menu, MainMenuEdit,Add, Edit Selsca-file: "%selscaFile%" with Notepad++,editselscaFile
  Menu, MainMenuEdit,Add, Edit Tools-file: "%toolsFile%" with Notepad++,edittoolsFile
  Menu, MainMenuEdit,Add, Edit Config-file: "%configFile%" with Notepad++,editConfigFile
  Menu, MainMenuEdit,Add, Edit Linklist-file: "%LinkListFile%" with Notepad++,editLinkListFile
  Menu, MainMenuEdit,Add, Edit PathBackup-file: "%pathBackup%" with Notepad++,editPathBackupFile
  
  Menu, MainMenuInternet,Add, Open %appName% Github webpage,openGithubPage
 
  Menu, MainMenuInternet,Add, Open Scala 3/2 Windows download webpage (scala-lang), openScala3WindowsDownload
  Menu, MainMenuInternet,Add, Open Scala 3 Linux download webpage (maven.org), openScala3LinuxDownload
  Menu, MainMenuInternet,Add, Open Scala 3 download installer etc. (Github), openScala3GithubDownload
  Menu, MainMenuInternet,Add, Download Scala 3 Windows (Github) known version, downloadScala3
  Menu, MainMenuInternet,Add, Download Scala 2 Windows (Typesafe) known version, downloadScala2
  
  Menu, MainMenuUpdate,Add, Check if new version is available, startCheckUpdate
  Menu, MainMenuUpdate,Add, Start updater, startUpdate
  
  Menu, MainMenuTools,Add, Windows Environment Tool,windowsEnvTool
  
  Menu, MainMenu, NoDefault  
  Menu, MainMenu, Add, Edit,:MainMenuEdit
  Menu, MainMenu, Add, Show Path,showPath
  Menu, MainMenu, Add, Tools,:MainMenuTools
  Menu, MainMenu, Add, Update,:MainMenuUpdate
  Menu, MainMenu, Add, Internet resources,:MainMenuInternet
  Menu, MainMenu, Add, Kill app,exit
  
  Gui,guiMain:New, +OwnDialogs +LastFound MaximizeBox hwndhMain +Resize, %app% [%configFile%]
  
  Gui, guiMain:Font, s%fontsize%, %font%

  xStart := 8
  yStart := 5
  linesInList := Min(linesInListMax, selscaEntriesArr.length())
  
  Gui, Add, ListView, x%xStart% y%yStart% r%linesInList% w%listWidth% GguiMainListViewClick vLV1 AltSubmit -Multi Grid, |Name|Scala-path|Scala-bin-path

  for index, element in selscaEntriesArr
  {
    elementArr := StrSplit(element,",")
    LV_Add("",index,elementArr[1], elementArr[2], elementArr[3])
  }
  
  LV_ModifyCol(1,"Auto Integer")
  LV_ModifyCol(2,"Auto Text")
  LV_ModifyCol(3,"Auto Text")
  LV_ModifyCol(4,"Auto Text")
  LV_ModifyCol(5,"Auto Text")
  
  Gui, guiMain:Add, StatusBar
  
  showMessageSelsca()
  
  Gui, guiMain:Menu, MainMenu
  
  Gui, guiMain:Show, x%windowPosX% y%windowPosY% w%clientWidth% h%clientHeight%
  setTimer,registerWindow,-500
    
  if (!hide){
    setTimer,checkFocus,3000
  } else {
    Gui, guiMain:Hide
  }
  
  ; OnMessage(0x200, "WM_MOUSEMOVE")
  ; OnMessage(0x2a3, "WM_MOUSELEAVE")
  OnMessage(0x03,"WM_MOVE")
  
  return
}
;---------------------------------- WM_MOVE ----------------------------------
WM_MOVE(wParam, lParam){
  global hMain, windowPosX, windowPosY, 

  WinGetPos, windowPosX, windowPosY,,, ahk_id %hMain%
  
  return
}
;------------------------------ guiMainGuiSize ------------------------------
guiMainGuiSize(){
  global hMain, windowPosX, windowPosY, clientWidth, clientHeight
  global windowPosXDefault, windowPosYDefault, clientWidthDefault, clientHeightDefault
  global borderLeft, borderRight, borderTop, LV1

  if (A_EventInfo != 1) {
    ; not minimized
    
    clientWidth := A_GuiWidth
    clientHeight := A_GuiHeight

    width := clientWidth - borderLeft - borderRight
    height := clientHeight - borderTop
    guicontrol, guiMain:move, LV1, x%borderLeft% w%width% h%height%
    
  }
  
  return
}
;-------------------------------- iniReadSave --------------------------------
iniReadSave(name, section, defaultValue){
  global configFile
  
  r := ""
  IniRead, r, %configFile%, %section%, %name%, %defaultValue%
  if (r == "" || r == "ERROR")
    r := defaultValue
    
  return r
}
;-------------------------------- readConfig --------------------------------
readConfig(){
  global configFile
  global menuhotkeyDefault, menuHotkey, exitHotkeyDefault, exitHotkey
  global notepadpath, notepadPathDefault
  global fontDefault, font, fontsizeDefault, fontsize
  global listWidthDefault, listWidth
  global linesInListMax, linesInListMaxDefault
  global selscaRestPortDefault, selscaRestPort

; read Hotkey definition
  IniRead, menuHotkey, %configFile%, hotkeys, menuhotkey , %menuhotkeyDefault%
  Hotkey, %menuHotkey%, showWindowRefreshed
  
  IniRead, exitHotkey, %configFile%, hotkeys, exitHotkey , %exitHotkeyDefault%
  Hotkey, %exitHotkey%, exit
  
  IniRead, notepadpath, %configFile%, external, notepadpath, %notepadPathDefault%
  
  IniRead, font, %configFile%, config, font, %fontDefault%
  IniRead, fontsize, %configFile%, config, fontsize, %fontsizeDefault%
  
  IniRead, listWidth, %configFile%, config, listWidth, %listWidthDefault%
  IniRead, linesInListMax, %configFile%, config, linesInListMax, %linesInListMaxDefault%
  
  IniRead, selscaRestPort, %configFile%, config, selscaRestPort, %selscaRestPortDefault%

  return
}
;------------------------------- createConfig -------------------------------
createConfig(fn){
  
  content := "
(
[hotkeys]
menuhotkey=""!p""
exithotkey=""+!p""

[config]
listWidth=800
font=""Segoe UI""
fontsize=9
selscaRestPort=65501
linesInListMax=30

[external]
notepadpath=""C:\Program Files\Notepad++\notepad++.exe""
linkListFile=""selscaLinkList.txt""


[gui]
windowPosX=0
windowPosY=0
clientWidth=503
clientHeight=271

)"

  FileAppend, %content%, %fn%, UTF-8-RAW

  return
}
;-------------------------------- readGuiData --------------------------------
readGuiData(){
  global configFile, windowPosX, windowPosY, clientWidth, clientHeight
  global windowPosXDefault, windowPosYDefault, clientWidthDefault, clientHeightDefault

  windowPosX := iniReadSave("windowPosX", "gui", windowPosXDefault)
  windowPosY := iniReadSave("windowPosY", "gui", windowPosYDefault)
  clientWidth := iniReadSave("clientWidth", "gui", clientWidthDefault)
  clientHeight := iniReadSave("clientHeight", "gui", clientHeightDefault)
  
  windowPosX := max(windowPosX,-50)
  windowPosY := max(windowPosY,-50)

  return
}
;-------------------------------- saveGuiData --------------------------------
saveGuiData(){
  global hMain, configFile, windowPosX, windowPosY, clientWidth, clientHeight

  if (windowPosX < -100)
    windowPosX := 0
    
  if (windowPosY < -100)
    windowPosY := 0
  
  IniWrite, %windowPosX%, %configFile%, gui, windowPosX
  IniWrite, %windowPosY%, %configFile%, gui, windowPosY
  
  IniWrite, %clientWidth%, %configFile%, gui, clientWidth
  IniWrite, %clientHeight%, %configFile%, gui, clientHeight
  
  return
}
;----------------------------------------------------------------------------
readSelsca(){
  global selscaFile, selscaEntriesArr, param

  selscaEntriesArr := []

  Loop, read, %selscaFile%
  {
    if (A_LoopReadLine != "") {
      selscaEntriesArr.Push(A_LoopReadLine)
    }
  }
  
  return
}
;----------------------------- startCheckUpdate -----------------------------
startCheckUpdate(){

  setTimer,checkFocus,delete
  checkUpdate()
  showWindow()

  return
}
;----------------------------- checkUpdate -----------------------------
checkUpdate(){
  global appname, appnameLower, localVersionFile, updateServer

  localVersion := getLocalVersion(localVersionFile)

  remoteVersion := getVersionFromGithubServer(updateServer . localVersionFile)

  if (remoteVersion != "unknown!" && remoteVersion != "error!"){
    if (remoteVersion > localVersion){
      msg1 := "New version available: (" . localVersion . " -> " . remoteVersion . ")`, please use the Updater (updater.exe) to update " . appname . "!"
      showHint(msg1, 3000)
      
    } else {
      msg2 := "No new version available (" . localVersion . " -> " . remoteVersion . ")"
      showHint(msg2, 3000)
    }
  } else {
    msg := "Update-check failed: (" . localVersion . " -> " . remoteVersion . ")"
    showHint(msg, 3000)
  }

  return
}
;------------------------------ getLocalVersion ------------------------------
getLocalVersion(file){
  
  versionLocal := 0.000
  if (FileExist(file) != ""){
    file := FileOpen(file,"r")
    versionLocal := file.Read()
    file.Close()
  }

  return versionLocal
}
;------------------------ getVersionFromGithubServer ------------------------
getVersionFromGithubServer(url){

  ret := "unknown!"

  whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
  Try
  { 
    whr.Open("GET", url)
    whr.Send()
    status := whr.Status
    if (status == 200){
     ret := whr.ResponseText
    } else {
      msgArr := {}
      msgArr.push("Error while reading actual app version!")
      msgArr.push("Connection to:")
      msgArr.push(url)
      msgArr.push("failed!")
      msgArr.push(" URL -> clipboard")
      msgArr.push("Closing Updater due to an error!")
    
      errorExit(msgArr, url)
    }
  }
  catch e
  {
    ret := "error!"
  }

  return ret
} 
;-------------------------------- startUpdate --------------------------------
startUpdate(){
  global wrkdir, appname, bitName, extension

  updaterExeVersion := "updater" . bitName . extension
  
  if(FileExist(updaterExeVersion)){
    msgbox,Starting "Updater" now, please restart "%appname%" afterwards!
    run, %updaterExeVersion% runMode
    exit()
  } else {
    msgbox, Updater not found!
  }
  
  showWindow()

  return
}
;----------------------------- showMessageSelsca -----------------------------
showMessageSelsca(hk1 := "", hk2 := ""){
  global menuHotkey, exitHotkey

  SB_SetParts(160,300)
  if (hk1 != ""){
    SB_SetText(" " . hk1 , 1, 1)
  } else {
    SB_SetText(" " . "Hotkey: " . hotkeyToText(menuHotkey) , 1, 1)
  }
    
  if (hk2 != ""){
    SB_SetText(" " . hk2 , 2, 1)
  } else {
    SB_SetText(" " . "Exit-hotkey: " . hotkeyToText(exitHotkey) , 2, 1)
  }
   
  memory := "[" . GetProcessMemoryUsage() . " MB]      "
  SB_SetText("`t`t" . memory , 3, 2)

  return
}
;**************************** linkSelectedAction ****************************
linkSelectedAction(){
  global linkListArr

  if (A_GuiEvent = "Normal"){
    selectedEntry := linkListArr[A_EventInfo]
    clipboard := selectedEntry
  
    showHint("Copied to clipboard (you are an admin!): " . selectedEntry,3000)
    sleep, 3000
    showWindow()
  }
  
  return
}
; *********************************** prepare ******************************
prepare() {
  
  readConfig()
  readGuiData()
  readSelsca()

  return
}
;-------------------------------- showWindow --------------------------------
showWindow(){
  global hMain, font, fontsize
  global windowPosX, windowPosY, clientWidth, clientHeight
  
  setTimer,checkFocus, delete
  setTimer,checkFocus,3000
  setTimer,registerWindow,-500
  Gui, guiMain:Show, x%windowPosX% y%windowPosY% w%clientWidth% h%clientHeight%
  
  return
}
;-------------------------------- hideWindow --------------------------------
hideWindow(){

  setTimer,checkFocus,delete
  Gui,guiMain:Hide

  return
}
;---------------------------- showWindowRefreshed ----------------------------
showWindowRefreshed(){
  global menuHotkey

  refreshGui()
  showWindow()
  
  showMessageSelsca()
  
  return
}
;******************************** refreshGui ********************************
refreshGui(){
  global selscaEntriesArr

  prepare()

  LV_Delete()
  
  for index, element in selscaEntriesArr
  {
    elementArr := StrSplit(element,",")
    LV_Add("",index,elementArr[1], elementArr[2], elementArr[3], elementArr[4])
  }
  
  return
}
;--------------------------- guiMainListViewClick ---------------------------
guiMainListViewClick(){
  if (A_GuiEvent = "normal"){
    LV_GetText(rowSelected, A_EventInfo)
    runInDir(rowSelected)
  }

  return
}
;-------------------------------- autoSelect --------------------------------
autoSelect(autoSelectName){
  global selscaEntriesArr, autoconfirm
  
  ;search for the name and get the number
  ln := 0
  
  l := selscaEntriesArr.length()
  Loop, %l%
  {
      selscaEntryArr := StrSplit(selscaEntriesArr[A_Index],",")
      selscaEntryName := selscaEntryArr[1]

    if (eq(autoSelectName,selscaEntryName)){
      ln := A_Index
      autoconfirm := true
      showHint("Selected Scala: " . autoSelectName, 2000)
      sleep,2000
    }
  }

  if(ln != 0)
    runInDir(ln)

  return
}
;--------------------------------- runInDir ---------------------------------
runInDir(lineNumber){
  global wrkDir, pathBackup, selscaFile, selscaEntriesArr
  global toolsArr, setEXE4J, autoconfirm, autoSelectName

  if (lineNumber != 0){

    ks := getKeyboardState()
    switch ks
    {
    case 1:
      ;*** Capslock ***
      showMessageSelsca("Operation inhibited due to [Capslock]!")

    case 2:
      ;*** Alt ***
      showMessageSelsca("Click + [Alt] is not yet used!")
  
    case 4:
      ;*** Ctrl ***
      s := selscaEntriesArr[lineNumber]
      
      setTimer,unselect,-100
      
      entry := StrSplit(s,",")
      
      path := entry[2]
      
      Runwait, %path%
      
      showMessageSelsca()
      
    case 8:
      ;*** Shift = edit ***

      s := selscaEntriesArr[lineNumber]
      
      setTimer,unselect,-100
      InputBox,inp,Edit command,,,,100,,,,,%s%
      
      if (ErrorLevel){
        showHint("Canceled!",2000)
        sleep,2000
        showWindow()
      } else {
        ;save new command
        selscaEntriesArr[lineNumber] := inp
        
        content := ""
        
        l := selscaEntriesArr.Length()
        
        Loop, % l
        {
          content := content . selscaEntriesArr[A_Index] . "`n"
        }

        FileDelete, %selscaFile%
        FileAppend, %content%, %selscaFile%, UTF-8-RAW
      
        showWindowRefreshed()
      }
    default:
      ; selscaEntriesArr[lineNumber][1] is the name, which is used as a marker only
      
      selscaEntryArr := StrSplit(selscaEntriesArr[lineNumber],",")
      scalaPath := envVariConvert(selscaEntryArr[2])
      scalaPathBin := StrReplace(envVariConvert(selscaEntryArr[3]),"...",scalaPath)
      
      MAXQ := 10 ; may 10 path-cmds in log
      que := ""
      
      dir := inWorkDir(pathBackup)
      if FileExist(dir){
        FileRead,que,%dir%
        FileDelete, %dir%
        if (ErrorLevel){
          msgbox, Severe error deleting %dir%
          exit()
        }
      }
       
      RegRead, thePathRead,HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment,Path
      
      thePath := strReplace(thePathRead,";;",";")
      
      Que := StrQ( Que, thePath, MAXQ, "`n`n`n" ) ; add a new item to Que 
      
      FormatTime, dateTime 
      
      out := dateTime . ":`n`n" . Que
      FileAppend, %out%, %dir%, UTF-8-RAW
      if (ErrorLevel){
        msgbox, Severe error saving %dir%
        exit()
      }
            
      a := StrSplit(thePath,";")

      s := ""
      for index, element in a
      {
        if (!RegExMatch(element,"\\scala.*?\\bin") && !RegExMatch(element,"\\scala3.*?\\bin"))
          s := s . element . ";"
      }

      s := SubStr(s,1,-1) ; remove last ";"

      ;prepend
      if (scalaPathBin != ""){
        s := scalaPathBin . ";" . s
      }
      
      setEnv := setSystemEnvCmd(s, "PATH")
      
      pv := strReplace(s,";",";`n")
  
      if (!autoconfirm){
          retScrollBox := ScrollBox(pv,"pb2","Windows-Path")
          if (retScrollBox == 1)
          {
            Run, %setEnv%,,min
            
            setEnv := setSystemEnvCmd(scalaPath, "SCALA_HOME")
            Run, %setEnv%,,min
      
            showHint("Finished!", 2000)
            sleep,2000
          } else {
            showHint("canceled!", 2000)
            sleep,2000
          }
      } else {
        RunWait, %setEnv%,,min
        
        setEnv := setSystemEnvCmd(scalaPath, "SCALA_HOME")
        Run, %setEnv%,,min
      }
      showMessageSelsca()
    }
  }
  
  return
}
;------------------------------ setSystemEnvCmd ------------------------------
setSystemEnvCmd(s := "", p := "PATH"){

  theEnv := ""
  if(s != ""){
    theEnv := cvtPath("%SystemRoot%\System32\windowspowershell\v1.0\powershell.exe","")
    theEnv := theEnv . " -NoProfile -ExecutionPolicy Bypass -Command """
    theEnv := theEnv . "$newEnvVari = '" . s . "'`n"
    theEnv := theEnv . "[Environment]::SetEnvironmentVariable('" . p . "', ""$newEnvVari"",'Machine');""`n"
  }
  
  ;msgbox, % theEnv

  return theEnv
}
;********************************* unselect *********************************
unselect(){
  sendinput {left}
}
;********************************** restart **********************************
restart(){
  exitApp,1
  
  return
}
;------------------------------ openGithubPage ------------------------------
openGithubPage(){
  global appName
  
  StringLower, name, appName
  Run, "https://github.com/jvr-ks/" . name
  
  return
}
;---------------------------- downloadScala2 ----------------------------
downloadScala2(){
  
  csave := clipboardall
  ; InputBox, OutputVar [, Title, Prompt, Hide, Width, Height, X, Y, Locale, Timeout, Default]
  InputBox, scalaVersion, Download Scala,Enter version like: 2.12.19,,,130,,,,,2.13.13

  if(!ErrorLevel){
    dLoadUrl := "http://downloads.typesafe.com/scala/" . scalaVersion . "/scala-" . scalaVersion . ".zip"
    InputBox, dLoadUrl, Download Url,Please check the URL,,,130,,,,,%dLoadUrl%
    if(!ErrorLevel){
      Run, %dLoadUrl%,,min
    }
  }
  clipboard := csave
  
  return
}
;---------------------------- downloadScala3 ----------------------------
downloadScala3(){
  
  csave := clipboardall
  ; InputBox, OutputVar [, Title, Prompt, Hide, Width, Height, X, Y, Locale, Timeout, Default]
  InputBox, scalaVersion, Download Scala,Enter version like: 3.3.3,,,130,,,,,3.4.0

  if(!ErrorLevel){
    dLoadUrl := "https://github.com/lampepfl/dotty/releases/download/" . scalaVersion . "/scala3-" . scalaVersion . ".zip"
    InputBox, dLoadUrl, Download Url,Please check the URL,,,130,,,,,%dLoadUrl%
    if(!ErrorLevel){
      Run, %dLoadUrl%,,min
    }
  }
  clipboard := csave
  
  return
}
;------------------------- openScala3GithubDownload -------------------------
openScala3GithubDownload(){

  Run, "https://github.com/scala/scala3/releases"
  
  return
}
;------------------------- openScala3WindowsDownload -------------------------
openScala3WindowsDownload(){

  Run, "https://www.scala-lang.org/download/all.html"

  return
}
;-------------------------- openScala3LinuxDownload --------------------------
openScala3LinuxDownload(){

  Run, "https://repo1.maven.org/maven2/org/scala-lang/scala3-compiler_3/"
  
  return
}
;--------------------------------- showPath ---------------------------------
showPath(){

  RegRead, thePath,HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment,Path
  
  a := StrSplit(thePath,";")

  s := ""
  for index, element in a
  {
    s := s . element . "`n"
  }

  retScrollBox := ScrollBox(s,"pb1","Windows-Path")
  
  showWindow()
  
  return
}

;------------------------------ editselscaFile ------------------------------
editselscaFile() {
  global notepadpath, selscaFile
  
  filename := selscaFile
  
  dir := inWorkDir(filename)
  f := notepadpath . " " . filename
  
  setTimer,checkFocus,delete
  Gui, guiMain:Destroy
  run %f%
  msgbox, Editing %filename% finished?
  exitReload()

  return
}
;------------------------------- edittoolsFile -------------------------------
edittoolsFile() {
  global notepadpath, toolsFile
  
  filename := toolsFile
  
  dir := inWorkDir(filename)
  f := notepadpath . " " . filename
  
  setTimer,checkFocus,delete
  Gui, guiMain:Destroy
  run %f%
  msgbox, Editing %filename% finished?
  exitReload()

  return
}
;------------------------------ editConfigFile ------------------------------
editConfigFile() {
  global notepadpath, configFile
  
  filename := configFile
  
  dir := inWorkDir(filename)
  f := notepadpath . " " . filename
  
  setTimer,checkFocus,delete
  Gui, guiMain:Destroy
  run %f%
  msgbox, Editing %filename% finished?
  exitReload()

  return
}
;----------------------------- editLinkListFile -----------------------------
editLinkListFile() {
  global notepadpath, linkListFile

  filename := linkListFile
  
  dir := inWorkDir(filename)
  f := notepadpath . " " . filename
  
  setTimer,checkFocus,delete
  Gui, guiMain:Destroy
  run %f%
  msgbox, Editing %filename% finished?
  exitReload()

  return
}
;---------------------------- editPathBackupFile ----------------------------
editPathBackupFile() {
  global notepadpath, pathBackup

  filename := pathBackup
  
  dir := inWorkDir(filename)
  f := notepadpath . " " . filename
  
  setTimer,checkFocus,delete
  Gui, guiMain:Destroy
  run %f%
  msgbox, Editing %filename% finished?
  exitReload()

  return
}

;************************************ ret ************************************
ret() {
  return
}
;********************************* checkJava *********************************
checkJava(){
  global wrkDir
  
  msg := "Please use the external app ""javaVersion.exe"" to check the Java-version!"
  showMessageSelsca(msg)
}
; *********************************** hkToDescription ******************************
; in Lib
; *********************************** hotkeyToText ******************************
; in Lib
;***************************** getKeyboardState *****************************
; in Lib
;********************************** cvtPath **********************************
cvtPath(s, path){
  r := s
  pos := 0

  While pos := RegExMatch(r,"O)(\[\.\.\.\])", match, pos+1){
    r := RegExReplace(r, "\" . match.1, path, , 1, pos)
  }
  
  While pos := RegExMatch(r,"O)(\[.*?\])", match, pos+1){
    r := RegExReplace(r, "\" . match.1, shortcut(match.1), , 1, pos)
  }

  While pos := RegExMatch(r,"O)(%.+?%)", match, pos+1){
    r := RegExReplace(r, match.1, envVariConvert(match.1), , 1, pos)
  }
  return r
}
;****************************** envVariConvert ******************************
envVariConvert(s){
  r := s
  if (InStr(s,"%")){
    s := StrReplace(s,"`%","")
    EnvGet, v, %s%
    Transform, r, Deref, %v%
  }

  return r
}
;********************************* shortcut *********************************
shortcut(s){
  global shortcutsArr
  
  r := s

  sc := shortcutsArr[r]
  if (sc != "")
    r := sc

  return r
}
;------------------------------ windowsEnvTool ------------------------------
windowsEnvTool(){
  runWait  C:\Windows\System32\SystemPropertiesAdvanced.exe
  return
}
;---------------------------- nativeImageInstall ----------------------------
nativeImageInstall(){

  runcmd := A_ComSpec
  Run, %runcmd%,,max
  sleep, 2000
  sendinput gu install native-image{Enter}
  sleep, 3000
  sendinput exit{Enter}
  
  return
}
;-------------------------------- openJavaDir --------------------------------
openJavaDir(){

  EnvGet, runcmd, JAVA_HOME
  Run, %runcmd%,,max  
  
  return
}
;-------------------------------- inWorkDir --------------------------------
inWorkDir(p){
  global wrkdir
  
  r := wrkdir . p
    
  return r
}
;--------------------------------- showHint ---------------------------------
showHint(s, n){
  global font
  global fontsize
  
  Gui, hint:Destroy
  Gui, hint:Font, %fontsize%, %font%
  Gui, hint:Add, Text,, %s%
  Gui, hint:-Caption
  Gui, hint:+ToolWindow
  Gui, hint:+AlwaysOnTop
  Gui, hint:Show
  t := -1 * n
  setTimer,showHintDestroy, %t%
  return
}
;------------------------------ showHintDestroy ------------------------------
showHintDestroy(){
  global hinttimer

  setTimer,showHintDestroy, delete
  Gui, hint:Destroy
  return
}
;---------------------------------- tipTop ----------------------------------
tipTop(msg, n := 1){

  s := StrReplace(msg,"^",",")
  
  toolX := Floor(A_ScreenWidth / 2)
  toolY := 2

  CoordMode,ToolTip,Screen
  ToolTip,%s%, toolX, toolY, n
  
  WinGetPos, X,Y,W,H, ahk_class tooltips_class32

  toolX := (A_ScreenWidth / 2) - W / 2
  
  ToolTip,%s%, toolX, toolY, n
  
  return
}
;----------------------------- tipScreenTopTime -----------------------------
tipScreenTopTime(msg, t := 2000, n := 1){
  ; Closes all tips after timeout

  CoordMode,ToolTip,Screen
  tipTop(msg, n)
  
  if (t > 0){
    tvalue := -1 * t
    SetTimer,tipTopClose,%tvalue%
  }
  
  CoordMode,ToolTip,Client
  return
}
;-------------------------------- tipTopClose --------------------------------
tipTopClose(){
  
  Loop, 20
  {
    ToolTip,,,,%A_Index%
  }
  
  return
}
;--------------------------- GetProcessMemoryUsage ---------------------------
GetProcessMemoryUsage() {
    PID := DllCall("GetCurrentProcessId")
    size := 440
    VarSetCapacity(pmcex,size,0)
    ret := ""
    
    hProcess := DllCall( "OpenProcess", UInt,0x400|0x0010,Int,0,Ptr,PID, Ptr )
    if (hProcess)
    {
        if (DllCall("psapi.dll\GetProcessMemoryInfo", Ptr, hProcess, Ptr, &pmcex, UInt,size))
            ret := Round(NumGet(pmcex, (A_PtrSize=8 ? "16" : "12"), "UInt") / 1024**2, 2)
        DllCall("CloseHandle", Ptr, hProcess)
    }
    return % ret
}
;----------------------------- getKeyboardState -----------------------------
getKeyboardState(){
  r := 0
  if (getkeystate("Capslock","T") == 1)
    r := r + 1
    
  if (getkeystate("Alt","P") == 1)
    r := r + 2
    
  if (getkeystate("Ctrl","P") == 1)
    r:= r + 4
    
  if (getkeystate("Shift","P") == 1)
    r:= r + 8
    
  if (getkeystate("LWin","P") == 1)
    r:= r + 16
    
  if (getkeystate("RWin","P") == 1)
    r:= r + 16

  return r
}
;----------------------------------- StrQ -----------------------------------
; from https://www.autohotkey.com/boards/viewtopic.php?t=57295#p328684

StrQ(Q, I, Max:=10, D:="|") { ;          StrQ v.0.90,  By SKAN on D09F/D34N @ tiny.cc/strq
Local LQ:=StrLen(Q), LI:=StrLen(I), LD:=StrLen(D), F:=0
Return SubStr(Q:=(I)(D)StrReplace(Q,InStr(Q,(I)(D),,0-LQ+LI+LD)?(I)(D):InStr(Q,(D)(I),0,LQ
-LI)?(D)(I):InStr(Q,(D)(I)(D),0)?(D)(I):"","",,1),1,(F:=InStr(Q,D,0,1,Max))?F-1:StrLen(Q))
}
;------------------------------------ eq ------------------------------------
eq(a, b) {
  if (InStr(a, b) && InStr(b, a))
    return 1
  return 0
}
;-------------------------------- createMime --------------------------------
createMime(){
  
  if (!FileExist("mime.types")){
    FileAppend,
    (LTrim
    text/html                             html htm shtml
    text/css                              css
    text/xml                              xml
    image/gif                             gif
    image/jpeg                            jpeg jpg
    application/x-javascript              js
    application/atom+xml                  atom
    application/rss+xml                   rss

    text/mathml                           mml
    text/plain                            txt
    text/vnd.sun.j2me.app-descriptor      jad
    text/vnd.wap.wml                      wml
    text/x-component                      htc

    image/png                             png
    image/tiff                            tif tiff
    image/vnd.wap.wbmp                    wbmp
    image/x-icon                          ico
    image/x-jng                           jng
    image/x-ms-bmp                        bmp
    image/svg+xml                         svg svgz
    image/webp                            webp

    application/java-archive              jar war ear
    application/mac-binhex40              hqx
    application/msword                    doc
    application/pdf                       pdf
    application/postscript                ps eps ai
    application/rtf                       rtf
    application/vnd.ms-excel              xls
    application/vnd.ms-powerpoint         ppt
    application/vnd.wap.wmlc              wmlc
    application/vnd.google-earth.kml+xml  kml
    application/vnd.google-earth.kmz      kmz
    application/x-7z-compressed           7z
    application/x-cocoa                   cco
    application/x-java-archive-diff       jardiff
    application/x-java-jnlp-file          jnlp
    application/x-makeself                run
    application/x-perl                    pl pm
    application/x-pilot                   prc pdb
    application/x-rar-compressed          rar
    application/x-redhat-package-manager  rpm
    application/x-sea                     sea
    application/x-shockwave-flash         swf
    application/x-stuffit                 sit
    application/x-tcl                     tcl tk
    application/x-x509-ca-cert            der pem crt
    application/x-xpinstall               xpi
    application/xhtml+xml                 xhtml
    application/zip                       zip

    application/octet-stream              bin exe dll
    application/octet-stream              deb
    application/octet-stream              dmg
    application/octet-stream              eot
    application/octet-stream              iso img
    application/octet-stream              msi msp msm

    audio/midi                            mid midi kar
    audio/mpeg                            mp3
    audio/ogg                             ogg
    audio/x-m4a                           m4a
    audio/x-realaudio                     ra

    video/3gpp                            3gpp 3gp
    video/mp4                             mp4
    video/mpeg                            mpeg mpg
    video/quicktime                       mov
    video/webm                            webm
    video/x-flv                           flv
    video/x-m4v                           m4v
    video/x-mng                           mng
    video/x-ms-asf                        asx asf
    video/x-ms-wmv                        wmv
    video/x-msvideo                       avi
    ), mime.types, UTF-8-RAW
  }
  
  return
}
;-------------------------------- exitReload --------------------------------
exitReload(){
  global allparams, wrkdir
  
  if A_IsCompiled
      Run "%A_ScriptFullPath%" /force %allparams%, %wrkdir%
  else
      Run "%A_AhkPath%" /force "%A_ScriptFullPath%" %allparams% , %wrkdir%
  
  ExitApp

  return
}
;--------------------------------- errorExit ---------------------------------
errorExit(theMsgArr, clp := "") {
 
  saveGuiData()
 
  msgComplete := ""
  for index, element in theMsgArr
  {
    msgComplete .= element . "`n"
  }
  msgbox,48,ERROR,%msgComplete%
  
  exit()
}
;----------------------------------- exit -----------------------------------
exit() {
  global app
  
  saveGuiData()
  
  showHint("""" . app . """ removed from memory!", 1500)
  sleep,1500
  ExitApp,0
  
  return
}
;----------------------------------------------------------------------------



