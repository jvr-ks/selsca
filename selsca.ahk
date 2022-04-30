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

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
#SingleInstance force
#Persistent

#Include %A_ScriptDir%

#Include, Lib\ahk_common.ahk

; https://github.com/zhamlin/AHKhttp
#include, Lib\AHKhttp.ahk

; http://www.autohotkey.com/forum/viewtopic.php?p=355775
#include, Lib\AHKsock.ahk


;auto-include Lib\..
;GuiConstants.ahk
;hkToDescription.ahk
;hotkeyToText.ahk
;resolvepath.ahk
;ScrollBox.ahk
;WinGetPosEx.ahk
;ScrollBox.ahk


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
appVersion := "0.031"

bit := (A_PtrSize=8 ? "64" : "32")

if (!A_IsUnicode)
  bit := "A" . bit

bitName := (bit="64" ? "" : bit)

app := appName . " " . appVersion . " " . bit . "-bit"

iniFileDefault := "selsca.ini"
iniFile := iniFileDefault

selscaFileDefault := "selsca.txt"
selscaFile := selscaFileDefault

iniFile := resolvepath(wrkDir,iniFile)
selscaFile := resolvepath(wrkDir,selscaFile)

linkListFileDefault := "selscaLinkList.txt"
linkListFile := linkListFileDefault

listWidthDefault := 800
listWidth := listWidthDefault

fontDefault := "Calibri"
font := fontDefault

fontsizeDefault := 10
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

msg_control_array = []

autoconfirm := false

; force admin rights
if (A_IsCompiled){
  allparams := ""
  for keyGL, valueGL in A_Args {
    allparams .= valueGL . " "
  }
  full_command_line := DllCall("GetCommandLine", "str")

  if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)")) {
    try
    {
      Run *RunAs %A_ScriptFullPath% /restart %allparams%
    }
    ExitApp
  }
} else {
  if (!A_IsAdmin){
    MsgBox, Script must be run as an admin!
    exitApp
  }
}

createMime()

pathBackup := resolvepath(wrkDir,"_thePathBackup.txt")

; *********** Gui parameter ***********
windowPosX := 0
windowPosY := 0
windowWidth := 0
windowHeight := 0
windowPosFixed := false

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

    FoundPos := RegExMatch(A_Args[A_index],"\([\s\w]+?\)", found)
    
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
;-------------------------------- mainWindow --------------------------------
mainWindow(hide := false) {
	global HMain
  global font
  global fontsize
  
  global selscaEntriesArr
  global selscaFile
  global toolsFile
  global iniFile
  global app
  global appName
  global menuHotkey
  global exitHotkey
  global listWidth
  global LV1
  global appVersion

  global linesInListMax
  global linesInListMaxDefault
  global windowPosX
  global windowPosY
  global windowWidth
  global windowHeight
  global pathBackup

  Menu, Tray, UseErrorLevel   ; This affects all menus, not just the tray.

  Menu, MainMenu, DeleteAll
  Menu, MainMenuEdit, DeleteAll
  Menu, MainMenuInternet, DeleteAll
  
  Menu, MainMenuEdit,Add,Edit Selsca-file: "%selscaFile%" with Notepad++,editselscaFile
  Menu, MainMenuEdit,Add,Edit Ini-file: "%iniFile%" with Notepad++,editIniFile
  Menu, MainMenuEdit,Add,Edit PathBackup-file: "%pathBackup%" with Notepad++,editPathBackupFile
  
  Menu, MainMenuInternet,Add,Open %appName% Github webpage,openGithubPage
  Menu, MainMenuInternet,Add,Open Scala 2 download webpage,openScala2Download
  Menu, MainMenuInternet,Add,Open Scala 3 download webpage,openScala3Download
  Menu, MainMenuInternet,Add,Open Scala 3 Linux download webpage,openScala3LinuxDownload
  
  Menu, MainMenu, NoDefault  
  Menu, MainMenu, Add,Edit,:MainMenuEdit
  Menu, MainMenu, Add,Show Path,showPath
  Menu, MainMenu, Add,Windows Environment Tool,windowsEnvTool
  Menu, MainMenu, Add,Update-check,checkUpdate
  Menu, MainMenu, Add,Update,updateApp
  Menu, MainMenu, Add,Internet resources,:MainMenuInternet
  Menu, MainMenu, Add,Kill app,exit
  
  Gui,guiMain:New, +OwnDialogs +LastFound MaximizeBox hwndHMain +Resize, %app%
  
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
  LV_ModifyCol(4,"Text")
  LV_ModifyCol(5,"Text")
  
  Gui, guiMain:Add, StatusBar
  
  showMessage4()
  
  Gui, guiMain:Menu, MainMenu
  
  if (!hide){
    setTimer,checkFocus,3000
    Gui, guiMain:Show, x%windowPosX% y%windowPosY% w%windowWidth% h%windowHeight%
  }
  
  OnMessage(0x200, "WM_MOUSEMOVE")
  OnMessage(0x2a3, "WM_MOUSELEAVE")
  
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
  
  readIni()
  readSelsca()
  readGuiParam()

  return
}
; *********************************** showWindow ******************************
showWindow(){
  global windowPosX
  global windowPosY
  global windowWidth
  global windowHeight
  
  setTimer,checkFocus,3000
  Gui, guiMain:Show, x%windowPosX% y%windowPosY% w%windowWidth% h%windowHeight%
  
  return
}
;********************************* hideWindow *********************************
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
  
  showMessage4()
  
  return
}
;********************************** readIni **********************************
readIni(){
  global iniFile
  global menuhotkeyDefault
  global menuHotkey
  global exitHotkeyDefault
  global exitHotkey
  global notepadpath
  global notepadPathDefault
  global fontDefault
  global font
  global fontsizeDefault
  global fontsize
  global listWidthDefault
  global listWidth
  global linesInListMax
  global linesInListMaxDefault
  global selscaRestPortDefault
  global selscaRestPort

; read Hotkey definition
  IniRead, menuHotkey, %iniFile%, hotkeys, menuhotkey , %menuhotkeyDefault%
  Hotkey, %menuHotkey%, showWindowRefreshed
  
  IniRead, exitHotkey, %iniFile%, hotkeys, exitHotkey , %exitHotkeyDefault%
  Hotkey, %exitHotkey%, exit
  
  IniRead, notepadpath, %iniFile%, external, notepadpath, %notepadPathDefault%
  
  IniRead, font, %iniFile%, config, font, %fontDefault%
  IniRead, fontsize, %iniFile%, config, fontsize, %fontsizeDefault%
  
  IniRead, listWidth, %iniFile%, config, listWidth, %listWidthDefault%
  IniRead, linesInListMax, %iniFile%, config, linesInListMax, %linesInListMaxDefault%
  
  IniRead, selscaRestPort, %iniFile%, config, selscaRestPort, %selscaRestPortDefault%

  return
}
;********************************* readSelsca *********************************
readSelsca(){
  global selscaFile
  global selscaEntriesArr
  global param

  selscaEntriesArr := []

  Loop, read, %selscaFile%
  {
    if (A_LoopReadLine != "") {
      selscaEntriesArr.Push(A_LoopReadLine)
    }
  }
  
  return
}

;******************************** checkFocus ********************************
checkFocus(){
  global HMain
  global iniFile
  global windowPosFixed
  global windowPosX
  global windowPosY
  global windowWidth
  global windowHeight

  if (HMain != WinActive("A")){
    hideWindow()
  } else {
    if (!windowPosFixed){
      static xOld := 0
      static yOld := 0
      static wOld := 0
      static hOld := 0

      gui guiMain:+LastFound
      WinGet hwnd1,ID

      WinGetPosEx(hwnd1,xn1,yn1,wn1,hn1,Offset_X1,Offset_Y1)
      hn1 := hn1 - 129
      xn1 := xn1 + Offset_X1

      hn1 := Min(Round(A_ScreenHeight * 0.9),hn1)
      wn1 := Min(Round(A_ScreenWidth * 0.9),wn1)
      
      yn1 := Min(Round(A_ScreenHeight - hn1),yn1)
      xn1 := Min(Round(A_ScreenWidth - wn1),xn1)
    
      if (xOld != xn1 || yOld != yn1 || wOld != wn1 || hOld != hn1){    
        xOld := xn1
        yOld := yn1
        wOld := wn1
        hOld := hn1
        
        IniWrite, %xn1% , %iniFile%, config, windowPosX
        IniWrite, %yn1%, %iniFile%, config, windowPosY
        
        IniWrite, %wn1% , %iniFile%, config, windowWidth
        IniWrite, %hn1%, %iniFile%, config, windowHeight
      }
    }
  }
    
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
;****************************** guiMainGuiSize ******************************
guiMainGuiSize:
; Expand or shrink the ListView in response to the user's resizing of the window.


SetTimer %A_ThisLabel%,Off
  
if (A_EventInfo = 1)  ; The window has been minimized. No action needed.
  return

borderX := 10
borderY := 60 ; reserve statusbar space

GuiControl, Move, LV1, % "W" . (A_GuiWidth - borderX) . " H" . (A_GuiHeight - borderY)

return

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
  global selscaEntriesArr
  global autoconfirm
  
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
  global wrkDir
  global pathBackup
  global selscaFile
  global selscaEntriesArr
  global toolsArr
  global setEXE4J
  global autoconfirm
  global autoSelectName

  if (lineNumber != 0){

    ks := getKeyboardState()
    switch ks
    {
    case 1:
      ;*** Capslock ***
      showMessage4("Operation inhibited due to [Capslock]!")

    case 2:
      ;*** Alt ***
      showMessage4("Click + [Alt] is not yet used!")
  
    case 4:
      ;*** Ctrl ***
      s := selscaEntriesArr[lineNumber]
      
      setTimer,unselect,-100
      
      entry := StrSplit(s,",")
      
      path := entry[2]
      
      Runwait, %path%
      
      showMessage4()
      
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
      
      if FileExist(pathBackup){
        FileRead,que,%pathBackup%
        FileDelete, %pathBackup%
        if (ErrorLevel){
          msgbox, Severe error deleting %pathBackup%
          exit()
        }
      }
       
      RegRead, thePathRead,HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment,Path
      
      thePath := strReplace(thePathRead,";;",";")
      
      Que := StrQ( Que, thePath, MAXQ, "`n`n`n" ) ; add a new item to Que 
      
      FormatTime, dateTime 
      
      out := dateTime . ":`n`n" . Que
      FileAppend, %out%, %pathBackup%, UTF-8-RAW
      if (ErrorLevel){
        msgbox, Severe error saving %pathBackup%
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
      showMessage4()
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
;****************************** openGithubPage ******************************
openGithubPage(){
  global appName
  
  tipWindow("WARNING: Remember, you are an admin!", transp := 0, timeout := 10000, refresh := true)
  StringLower, name, appName
  Run https://github.com/jvr-ks/%name%
  
  return
}
;---------------------------- openScala2Download ----------------------------
openScala2Download(){
  global appName
  
  tipWindow("WARNING: Remember, you are an admin!", transp := 0, timeout := 10000, refresh := true)
  StringLower, name, appName
  Run https://www.scala-lang.org/download/scala2.html
  
  return
}
;---------------------------- openScala3Download ----------------------------
openScala3Download(){
  global appName
  
  tipWindow("WARNING: Remember, you are an admin!", transp := 0, timeout := 10000, refresh := true)
  StringLower, name, appName
  Run https://www.scala-lang.org/download/scala3.html
  
  return
}

;-------------------------- openScala3LinuxDownload --------------------------
openScala3LinuxDownload(){
  global appName
  
  tipWindow("WARNING: Remember, you are an admin!", transp := 0, timeout := 10000, refresh := true)
  StringLower, name, appName
  Run https://repo1.maven.org/maven2/org/scala-lang/scala3-compiler_3/
  
  return
}
;******************************* editselscaFile *******************************
editselscaFile() {
  global selscaFile
  global notepadpath
  
  showMessage4("Please close the editor to refresh the menu!")
  f := notepadpath . " " . selscaFile
  runWait %f%,,max
  showMessage4()
  
  showWindowRefreshed()

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
;******************************** editIniFile ********************************
editIniFile() {
  global iniFile
  global notepadpath
  
  f := notepadpath . " " . iniFile
  showMessage4("Please close the editor to refresh the menu!")

  runWait %f%
  showMessage4()
  
  showWindowRefreshed()

  return
}
;***************************** editLinkListFile *****************************
editLinkListFile() {
  global notepadpath
  global linkListFile

  f := notepadpath . " " . linkListFile
  showMessage4("Please close the editor to refresh the menu!")
  runWait %f%
  showMessage4()
  
  showWindowRefreshed()

  return
}
;---------------------------- editPathBackupFile ----------------------------
editPathBackupFile() {
  global notepadpath
  global pathBackup

  f := notepadpath . " " . pathBackup
  showMessage4("Please close the editor to refresh the menu!")
  runWait %f%
  showMessage4()
  
  showWindowRefreshed()

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
  showMessage4(msg)
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
;******************************* readGuiParam *******************************
readGuiParam(){
  global iniFile
  global font
  global fontsize
  global fontsizeDefault
  global windowPosX
  global windowPosY
  global windowWidth
  global windowHeight
  global windowPosFixed
  
  IniRead, windowPosFixed, %iniFile%, config, windowPosFixed, 0
  
  IniRead, windowPosX, %iniFile%, config, windowPosX, 0

  windowWidthDefault := A_ScreenWidth - Round(A_ScreenWidth/8)
  IniRead, windowWidth, %iniFile%, config, windowWidth, %windowWidthDefault%
  if (windowWidth == 0)
    windowWidth := windowWidthDefault
    
  IniRead, windowPosY, %iniFile%, config, windowPosY, 0

  windowHeightDefault := A_ScreenHeight - Round(A_ScreenHeight/8)
  IniRead, windowHeight, %iniFile%, config, windowHeight, %windowHeightDefault%
  if (windowHeight < 0)
    windowHeight := windowHeightDefault
  
  IniRead, fontsize, %iniFile%, config, fontsize, %fontsizeDefault%
  
  ;DPIScale correction:
  windowWidth := Round(windowWidth * 96/A_ScreenDPI)
  windowHeight := Round(windowHeight * 96/A_ScreenDPI)

  return
}
;******************************* s *******************************
WM_MOUSEMOVE(wParam, lParam) {
  global msg_control_array
  
  ;Gui, main:submit, nohide

  X := lParam & 0xFFFF
  Y := lParam >> 16
  
  if (A_GuiControl){
    Loop, parse, msg_control_array, `,
    { 
      if (A_GuiControl == A_LoopField){
        tooltip, %msg%,,,9
        break
      }
      msg := A_LoopField
    }
    sleep 10000
    OnMessage(0x200, "")
  ToolTip,,,,9
  }
  
  return
}      
;******************************* WM_MOUSELEAVE *******************************
WM_MOUSELEAVE(wParam, lParam) {
  ToolTip,,,,9
  
  return
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
;----------------------------------- exit -----------------------------------
exit() {
  global app
  
  showHint("""" . app . """ removed from memory!", 1500)
  sleep,1500
  ExitApp,0
  
  return
}
;----------------------------------------------------------------------------



