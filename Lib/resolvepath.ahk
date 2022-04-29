; *********************************** resolvepath.ahk ******************************
resolvepath(wrkPath,path) {
  r := ""
  c := ""
  
  if (SubStr(wrkPath,0,1) != "\") ; last character
    c := "\"
    
  r := wrkPath . c . path
  if (InStr(path,":"))
    r := path
    
  return r
}

