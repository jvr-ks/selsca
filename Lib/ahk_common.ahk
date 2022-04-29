; ahk_common.ahk

; Must be defined in parent code:
; function "exit()"
; variable font
; variable fontsize

;----------------------------------- StrQ -----------------------------------
; from https://www.autohotkey.com/boards/viewtopic.php?t=57295#p328684

StrQ(Q, I, Max:=10, D:="|") { ;          StrQ v.0.90,  By SKAN on D09F/D34N @ tiny.cc/strq
Local LQ:=StrLen(Q), LI:=StrLen(I), LD:=StrLen(D), F:=0
Return SubStr(Q:=(I)(D)StrReplace(Q,InStr(Q,(I)(D),,0-LQ+LI+LD)?(I)(D):InStr(Q,(D)(I),0,LQ
-LI)?(D)(I):InStr(Q,(D)(I)(D),0)?(D)(I):"","",,1),1,(F:=InStr(Q,D,0,1,Max))?F-1:StrLen(Q))
}

;----------------------------- SetTextAndResize -----------------------------
SetTextAndResize(controlHwnd, newText) {

  dc := DllCall("GetDC", "Ptr", controlHwnd)

; 0x31 = WM_GETFONT
  SendMessage 0x31,,,, ahk_id %controlHwnd%
  hFont := ErrorLevel
  oldFont := 0
  if (hFont != "FAIL")
    oldFont := DllCall("SelectObject", "Ptr", dc, "Ptr", hFont)

  VarSetCapacity(rect, 16, 0)
  ; 0x440 = DT_CALCRECT | DT_EXPANDTABS
  h := DllCall("DrawText", "Ptr", dc, "Ptr", &newText, "Int", -1, "Ptr", &rect, "UInt", 0x440)
  ; width = rect.right - rect.left
  w := NumGet(rect, 8, "Int") - NumGet(rect, 0, "Int")

  if oldFont
    DllCall("SelectObject", "Ptr", dc, "Ptr", oldFont)
  DllCall("ReleaseDC", "Ptr", controlHwnd, "Ptr", dc)

  GuiControl,, %controlHwnd%, %newText%

  GuiControl Move, %controlHwnd%, % "w" w

  return w
}

;------------------------------- tipWindow -------------------------------
tipWindow(msg, transp := 0, timeout := 0, refresh := true){
  ; using own Gui
  global font
  global fontsize
  
  static text1Hwnd := ""
  static tipWindowTextWidth
  static newtipWindowTextWidth
  
  s := StrReplace(msg,"^",",")
    
  if (refresh){
    tipWindowClose()
    sleep,100
  }
  
  tipWindowhwnd := WinExist("TheTipWindow")
  
  if (tipWindowhwnd == 0){
    Gui, tipWindow:New,-Caption +AlwaysOnTop -dpiScale HwndtipWindowhwnd

    Gui, tipWindow:Font, s%fontsize%, %font%
    Gui tipWindow:Margin, 2, 2
    Gui, tipWindow:Add, Text, Hwndtext1Hwnd vTipWindow R1 Center
    newtipWindowTextWidth := SetTextAndResize(text1Hwnd, s)
    Gui, tipWindow:Show, xCenter y1 Autosize NoActivate,TheTipWindow
    tipWindowTextWidth := newtipWindowTextWidth
  } else {
    newtipWindowTextWidth := SetTextAndResize(text1Hwnd, s)
    GuiControl,, %text1Hwnd%, %s%
    if (newtipWindowTextWidth != tipWindowTextWidth){
      tipWindowTextWidth := newtipWindowTextWidth
      tipWindowClose()
      Gui, tipWindow:New,-Caption +AlwaysOnTop -dpiScale

      Gui, tipWindow:Font, s%fontsize%, %font%
      Gui tipWindow:Margin, 2, 2
      Gui, tipWindow:Add, Text, Hwndtext1Hwnd vTipWindow R1 Center
      newtipWindowTextWidth := SetTextAndResize(text1Hwnd, s)
      Gui, tipWindow:Show, xCenter y1 Autosize NoActivate,TheTipWindow
    }
  }
  
  if (transp != 0)
    WinSet, Transparent, %transp%, ahk_id %tipWindowhwnd%
  
  if (timeout != 0){
    t := -1 * timeout
    setTimer,tipWindowClose,delete
    setTimer,tipWindowClose,%t%
  }

  return
}
;----------------------------- tipWindowClose -----------------------------
tipWindowClose(){
  global TipWindow

  setTimer,tipWindowClose,delete
  Gui,tipWindow:Destroy
  
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
;-------------------------------- tipTopTime --------------------------------
tipTopTime(msg, t := 2000, n := 1){
  ; Closes all tips after timeout

  tipTop(msg, n)
  
  if (t > 0){
    tvalue := -1 * t
    SetTimer,tipTopClose,%tvalue%
  }
  
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
;******************************** GuiGetSize ********************************
GuiGetSize( ByRef W, ByRef H, GuiID=1 ) {
  Gui %GuiID%:+LastFoundExist
  IfWinExist
  {
    VarSetCapacity( rect, 16, 0 )
    DllCall("GetClientRect", uint, MyGuiHWND := WinExist(), uint, &rect )
    W := NumGet( rect, 8, "int" )
    H := NumGet( rect, 12, "int" )
  }
}
;********************************* GuiGetPos *********************************
GuiGetPos( ByRef X, ByRef Y, ByRef W, ByRef H, GuiID=1 ) {
  Gui %GuiID%:+LastFoundExist
  IfWinExist
  {
    WinGetPos X, Y
    VarSetCapacity( rect, 16, 0 )
    DllCall("GetClientRect", uint, MyGuiHWND := WinExist(), uint, &rect )
    W := NumGet( rect, 8, "int" )
    H := NumGet( rect, 12, "int" )
  }
}
;******************************** stringUpper ********************************
stringUpper(s){
  r := ""
  StringUpper, r, s
  
  return r
}
;********************************* StrLower *********************************
StrLower(s){
  r := ""
  StringLower, r, s
  
  return r
}
;******************************** openShell ********************************
openShell(commands) {
  shell := ComObjCreate("WScript.Shell")
  exec := shell.Exec(ComSpec " /Q /K echo off")
  exec.StdIn.WriteLine(commands "`nexit") 
  r := exec.StdOut.ReadAll()
  msgbox, %r%
  
  return
}
;******************************** showObject ********************************
showObject(a){
  s := ""

  for index,element in a
  {
    s := s . element .  ", "
  }
  msgbox, showObject: %s%
}

;--------------------------- GetProcessMemoryUsage ---------------------------
GetProcessMemoryUsage(){

  OwnPID := DllCall("GetCurrentProcessId")
  static PMC_EX := "", size := NumPut(VarSetCapacity(PMC_EX, 8 + A_PtrSize * 9, 0), PMC_EX, "uint")

  if (hProcess := DllCall("OpenProcess", "uint", 0x1000, "int", 0, "uint", OwnPID)) {
    if !(DllCall("GetProcessMemoryInfo", "ptr", hProcess, "ptr", &PMC_EX, "uint", size))
      if !(DllCall("psapi\GetProcessMemoryInfo", "ptr", hProcess, "ptr", &PMC_EX, "uint", size))
        return (ErrorLevel := 2) & 0, DllCall("CloseHandle", "ptr", hProcess)
    DllCall("CloseHandle", "ptr", hProcess)
    return Round(NumGet(PMC_EX, 8 + A_PtrSize * 8, "uptr") / 1024**2, 2)
  }
  return (ErrorLevel := 1) & 0
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
;-------------------------------- showHintAt --------------------------------
showHintAt(s, n, x, y){
  global font
  global fontsize
  
  Gui, hint:Destroy
  Gui, hint:Font, s%fontsize%, %font%
  Gui, hint:Add, Text,, %s%
  Gui, hint:-Caption
  Gui, hint:+ToolWindow
  Gui, hint:+AlwaysOnTop
  Gui, hint:Show, x%x% y%y%
  t := -1 * n
  setTimer,showHintDestroy, %t%
  
  return
}

;------------------------------- showHintSleep -------------------------------
showHintSleep(s, n){
  showHint(s, n)
  sleep, %n%
  
  return
}
;------------------------------ showHintDestroy ------------------------------
showHintDestroy(){
  global hinttimer

  setTimer,showHintDestroy, delete
  Gui, hint:Destroy
  return
}
;-------------------------------- showHintAdd --------------------------------
showHintAdd(s,n := 2000){
  global font
  global fontsize
  
  static sIs := ""
  
  if (s == ""){
    sIs := ""
    rows := 1
    setTimer,showHintAddDestroy, delete
    Gui, hintAdd:Destroy
  } else {
    setTimer,showHintAddDestroy, delete
    sIs .= s

    Gui, hintAdd:Destroy
    Gui, hintAdd:Font, %fontsize%, %font%
    Gui, hintAdd:Add, Text,, %sIs%
    Gui, hintAdd:-Caption
    Gui, hintAdd:+ToolWindow
    Gui, hintAdd:+AlwaysOnTop
    Gui, hintAdd:Show,autosize
    
    sIs .= "`n"
    t := -1 * n
    setTimer,showHintAddDestroy, %t%
  }
  
  return
}

;----------------------------- showHintAddReset -----------------------------
showHintAddReset(){

  showHintAdd("",0)

  return
}
;---------------------------- showHintAddDestroy ----------------------------
showHintAddDestroy(){

  setTimer,showHintAddDestroy, delete
  Gui, hintAdd:Destroy
  
  return
}
;------------------------------------ eq ------------------------------------
eq(a, b) {
  if (InStr(a, b) && InStr(b, a))
    return 1
  return 0
}
;-------------------------------- openWindow --------------------------------
openWindow(title){
  SetTitleMatchMode, 2
  wHwnd := 0

  if WinExist(title){
    winActivate,%title%
    sleep, 200
    
    TrialLoop:
    Loop, 20
    {
      if (!WinActive(title)){
        showHint("Waiting for Window: " . title . " to open!", 1000)
        sleep, 1000
        winActivate,%title%
      } else {
        wHwnd := WinActive(title)
        break TrialLoop
      }
    }
  } else {
    tipTopTime("Window: " . title . " not found!", 4000)
  }

  
  return wHwnd
}
;--------------------------------- BaseToDec ---------------------------------
BaseToDec(n, Base) {
  static U := A_IsUnicode ? "wcstoui64_l" : "strtoui64"
  return, DllCall("msvcrt\_" U, "Str",n, "Uint",0, "Int",Base, "CDECL Int64")
}
;--------------------------------- DecToBase ---------------------------------
DecToBase(n, Base) {
  static U := A_IsUnicode ? "w" : "a"
  VarSetCapacity(S,65,0)
  DllCall("msvcrt\_i64to" U, "Int64",n, "Str",S, "Int",Base)
  return, S
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

;-------------------------------- showMessage --------------------------------
showMessage(hk1, hk2, part1 = 170, part2 = 580){
  global menuHotkey
  global exitHotkey

  SB_SetParts(part1,part2)
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
;------------------------------- removeMessage -------------------------------
removeMessage(){
  global menuHotkey
  global exitHotkey

  showMessage("", "")

  return
}
;------------------------------- showMessage4 -------------------------------
showMessage4(hk1 := "", hk2 := "", reso := ""){
  global menuHotkey
  global exitHotkey

  SB_SetParts(300,500,200)
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
  
  if (reso != ""){
    SB_SetText("`t" . reso , 3, 2)
  } else {
    resolution := "[" . A_ScreenWidth . " x " . A_ScreenHeight . "]"
    SB_SetText("`t" . reso , 3, 2)
  }
  
  memory := "[" . GetProcessMemoryUsage() . " MB]      "
  SB_SetText("`t`t" . memory , 4, 2)

  return
}
;------------------------------ showHintColored ------------------------------
showHintColored(s, n, fg, bg){
  global font
  global fontsize
  
  Gui, hintColored:Font, s%fontsize%, %font%
  Gui, hintColored:Font, c%fg%
  Gui, hintColored:Color, %bg%
  Gui, hintColored:Add, Text,, %s%
  Gui, hintColored:-Caption
  Gui, hintColored:+ToolWindow
  Gui, hintColored:+AlwaysOnTop
  Gui, hintColored:Show
  Sleep, n
  Gui, hintColored:Destroy
  
  return
}
;--------------------------- getVersionFromGithub ---------------------------
getVersionFromGithub(){
  global appnameLower

  ret := "unknown!"

  url := "https://github.com/jvr-ks/" . appnameLower . "/raw/main/version.txt"
  whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
  Try
  {
    whr.Open("GET", url)
    whr.Send()
    status := whr.Status
    if (status == 200)
      ret := whr.ResponseText
  }
  catch e
  {
    msgbox, Connection to:`n`n%url%`n`nfailed!
  }

  return ret
}

;-------------------------------- checkUpdate --------------------------------
checkUpdate(){
  global appVersion

  vers := getVersionFromGithub()
  if (vers != "unknown!"){
    if (vers > appVersion){
      msg := "New version available, this is: " . appVersion . ", available on Github is: " . vers
      showHintColored(msg, 5000, 0xFFFFFF, 0xFF0000)
    } else {
      msg := "No new version available!"
      showHint(msg, 5000)
    }
  } else {
      msg := "Updatecheck failed!"
      showHintColored(msg, 5000, 0xFFFFFF, 0xFF0000)
  }

  return
}
;-------------------------------- restartApp --------------------------------
restartApp(){
  global bit
  global restartFilename
  
  run,%comspec% /k %restartFilename% %bit%
  
  exit()
}
;---------------------------- restartAppNoupdate ----------------------------
restartAppNoupdate(){
  global bit
  global restartFilename
  
  run,%comspec% /k %restartFilename% %bit% noupdate
  
  exit()
}
;--------------------------------- updateApp ---------------------------------
updateApp(){
  global appName
  global bitName
  global appVersion
  global downLoadFilename
  global restartFilename
  global downLoadURL
  global downLoadURLrestart

  vers := getVersionFromGithub()
  if (vers != "unknown!"){
    if (vers > appVersion){
      msg := "This is: " . appVersion . ", available on Github is: " . vers . " update now?"
      MsgBox , 1, Update available!, %msg%
      
      FileDelete, %downLoadFilename%
      
      IfMsgBox, OK
        {
          ;restartXX.bat can contain update hints, allways download!
          
          UrlDownloadToFile, %downLoadURLrestart%, %restartFilename%
          sleep,1000
          
          UrlDownloadToFile, %downLoadURL%, %downLoadFilename%
              
          if FileExist(downLoadFilename){
            showHint(appName . bitName . " restarts now!",2000)
            restartApp()
            exitApp
          } else {
            msgbox,Could not download update!
          }
        }
    } else {
      msgbox, This version: %appVersion%, available version %vers%, no update available!
    }
  }
  
  return
}

; ----------------------------------------------------------------------------- 










