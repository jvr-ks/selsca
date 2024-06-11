; *********************************** hkToDescription.ahk ******************************
; TODO

hkToDescription(c) {
  s := ""
  
  switch c
  {
    case "^":
      s := "[CTRL]"
    case "!":
      s := "[ALT]"
    case "#":
      s := "[WIN]"
    case "+":
      s := "[SHIFT]"
    case ">":
      s := "Right"
    case "<":
      s := "Left"
    case "$":
      s := "[Alt] + [Tab]"
    default:
      s := "[" . c . "]"
  }
  
  return s
}

