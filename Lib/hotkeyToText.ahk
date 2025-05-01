; *********************************** hotkeyToText.ahk ******************************
hotkeyToText(h) {
  
  StringLower,h,h
  
  ; h := extractHotkey(h)
  
  isOff := ""
  if (InStr(h, "off") > 0){
    h := RegExReplace(h, "i)off" , "")
    isOff := " (is off!)"
  }
  
  if (InStr(h, "tab") > 0){
    h := RegExReplace(h, "i)alt & tab" , "$")
  }
  
  hk := StrSplit(StrRev(h))
  s := ""
  l := hk.Length() - 1
  
  
  Loop, % l
  {
    s := hkToDescription(hk[A_Index + 1]) . " + " . s
  }
  s := s . hkToDescription(hk[1])
  
  return s . isOff
}
;------------------------------- extractHotkey -------------------------------
; extractHotkey(s){
  ; a := RegExReplace(s,"(.*){(\w*)}","$1")
  ; b := GetKeyName(RegExReplace(s,"(.)*?{(\w*)}","$2"))
  ; c := a . b
  
  ; return c
; }
; *********************************** StrRev ******************************
StrRev(in) {
  DllCall("msvcrt\_" (A_IsUnicode ? "wcs":"str") "rev", "UInt",&in, "CDecl")
  return in
}

