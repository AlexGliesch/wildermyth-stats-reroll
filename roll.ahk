; https://www.autohotkey.com/boards/viewtopic.php?f=76&t=93120
; ! 	Alt
; ^ 	Ctrl
; + 	Shift

; #SingleInstance force
#NoEnv 
#Persistent
#MaxHotkeysPerInterval 99999999999999

x1 := 1319
y1 := 525
x2 := 1731
y2 := 848

CdToGenChar = 60

DesiredStats := {}
; DesiredStats["RetirementAge"] := [">=", 5.0]
; DesiredStats["Potency"] := [">=", 0.4]
; DesiredStats["Warding"] := [">=", 1.0]
DesiredStats["Accuracy"] := [">=", 7]
; DesiredStats["Speed"] := [">=", 0.1]
; DesiredStats["Speed"] := ["=", 0.6]
; DesiredStats["Health"] := ["=", 0.0]
;; DesiredStats["Dodge"] := ["=", 0.0]
; DesiredStats["Block"] := ["=", 0.0]
; DesiredStats["BonusDamage"] := [">=", 0.2]
; DesiredStats["RetirementAge"] := ["=", 0.0]
; DesiredStats["RecoveryRate"] := ["=", 0.0]
; DesiredStats["Charisma"] := [">=", 60.0]
; DesiredStats["Charisma"] := ["=", 0.0]
; DesiredStats["Tenacity"] := ["=", 0.0]

Running := False

loop {
  if WinActive("ahk_exe wildermyth.exe") and Running {
    Send, ^r
    Send, ^r
    Send, ^r
    Sleep % CdToGenChar
    CharacterIsOk := CheckCharacter()
    if CharacterIsOk {
      Running := False
    }
  }
}
  
#IfWinActive ahk_exe wildermyth.exe
F11::
  Running := False
  msgbox, Stopped the search.
return

F12::
  Running := True
  ; InputRect(x1, y1, x2, y2)
  msgbox, Searching for a character...  
return

F10::
InputRect(x1, y1, x2, y2)
return
#IfWinActive
  
  
  ; running := !running
  ; 
  ; msgbox % ocr("ahk_exe wildermyth.exe",1208,398,1400,600,"","",50,0)
  ; word_array := StrSplit(TestString, "\n", ".") ; Omits periods.
  
  
  ; MsgBox % "Color number " index " is " word
  ; MsgBox % "The 4th word is " word_array[4]
  ; msgbox % TestString

CheckCharacter() {
  global DesiredStats, x1, y1, x2, y2
  TestString := ocr("ahk_exe wildermyth.exe", x1, y1, x2, y2, "", "", 50, 0)
    
  KeyVal := {}
  for Key, _ in DesiredStats {
    KeyVal[Key] := 0
  }
  
  ; msgbox, %TestString%  
  
  for _Index, Str in StrSplit(TestString, "`n")
  {
    Str := StrReplace(Str, ",", ".")
    Str := RegExReplace(Str, "^4|[^A-Za-z0-9\.]")
    ; NewStr := ""
    ; Loop, Parse, Str
    ; {
    ;   Character := SubStr(Str, A_Index, 1)
    ;   if (RegExMatch(Character, "[0-9\.]"))
    ;   {
    ;     NewStr .= Character
    ;   }
    ; }
    ; Str := NewStr
    ; RegExMatch(Haystack, NeedleRegEx [, UnquotedOutputVar = "", StartingPos = 1])
    ; Str := StrReplace(Str, ",", ".")
    ; Str := StrReplace(Str, "=", "")
    ; Str := StrReplace(Str, " ", "")
    ; Str := StrReplace(Str, "+", "")
    ; Str := StrReplace(Str, "_", "")
    ; Str := StrReplace(Str, "|", "")
    ; Str := StrReplace(Str, ":", "")
    ; Str := StrReplace(Str, "#", "")
    ; if (SubStr(Str, 1, 1) = "4") {  ; remove leading 4 because sometimes OCR translates + as 4
      ; Str := SubStr(Str, 2)
    ; }
    ; msgbox, %Str%
    
    for Key, Arr in DesiredStats {
      if InStr(Str, Key) {
        Str := StrReplace(Str, Key, "")
        if (Str is number) {
          KeyVal[Key] := Str
        }
        break
      }      
    }
  }
  
  CharacterIsOk := True
  
  for Key, Value in KeyVal {
    if DesiredStats.HasKey(Key) {
      Arr := DesiredStats[Key]
      if Arr[1] = ">=" && Value < Arr[2] {
        CharacterIsOk := False
      }
      if Arr[1] = ">" && Value <= Arr[2] {
        CharacterIsOk := False
      }
      if Arr[1] = "=" && Value != Arr[2] {
        CharacterIsOk := False
      }
      if Arr[1] = "<=" && Value > Arr[2] {
        CharacterIsOk := False
      }
      if Arr[1] = "<" && Value >= Arr[2] {
        CharacterIsOk := False
      }
      if Arr[1] = "!=" && Value = Arr[2] {
        CharacterIsOk := False
      }
      if !CharacterIsOk {
        break
      }
    }
  }
  
  if CharacterIsOk {
    Str := "Found the desired character!`n"
    for Key in DesiredStats {
      Str .= Key 
      Str .= " "
      Str .= KeyVal[Key]
      Str .= "`n"
    }
    msgbox, %Str%
    msgbox %TestString%
  }

  return CharacterIsOk
}

ocr(win_id="",x1=0,y1=0,x2="",y2="",whitelist="",bw="",v=20,leptonica=0)
{
	static hAPI, header
	if !hAPI
		LoadLibrary("libtesseract530.dll")
		, LoadLibrary("libleptonica1831.dll")
		, hAPI := DllCall("libtesseract530\TessBaseAPICreate", "Ptr")
		, DllCall("libtesseract530\TessBaseAPIInit3", "Ptr", hAPI, "AStr", A_ScriptDir, "AStr", "eng")
		, VarSetCapacity(header, 54, 0)
		, NumPut(0x360000, NumPut(1, NumPut(0x5FC64D42, header, "UInt"), "UInt"), "UInt")	; Bitmap file header (14 bytes)

	if whitelist
		DllCall("libtesseract530\TessBaseAPISetVariable", "Ptr", hAPI, "Str", "tessedit_char_whitelist", "Str", whitelist)

	if (win_id<>"") && FileExist(win_id)
		hPix := DllCall("libleptonica1831\pixRead", "AStr", win_id, "Ptr")
		, DllCall("libtesseract530\TessBaseAPISetImage2", "Ptr", hAPI, "Ptr", hPix)
		, str:= DllCall("libtesseract530\TessBaseAPIGetUTF8Text", "Ptr", hAPI, "AStr")
	else {
		if (win_id=="")
			win_id:=WinExist("A")
		if (x2=="")
			WinGetPos,,,x2,,ahk_id %win_id%
		if (y2=="")
			WinGetPos,,,,y2,ahk_id %win_id%

		x:=min(x1,x2), y:=min(y1,y2), w:=abs(x2-x1)+1, h:=abs(y2-y1)+1
		, bh := -h	; must be -h for Tesseract
		, NumPut(32, NumPut(1, NumPut(bh, NumPut(w, NumPut(40, header, 14, "uint"), "int"), "int"), "UShort"), 0, "UShort") ; bitmap info for CreateDIB (40 bytes) positive h for Capture2Text to work
		, src := DllCall("user32.dll\GetDCEx", "Ptr", win_id, "Ptr", 0, "UInt", 3, "Ptr")
		, dst := DllCall("CreateCompatibleDC", "Ptr", src, "Ptr")
		, DIB := DllCall("CreateDIBSection", "Ptr", dst, "Ptr", &header+14, "UInt", 0, "Ptr*", pbits, "Ptr", 0, "UInt", 0, "Ptr")
		, DllCall("SelectObject", "Ptr", dst, "Ptr", DIB, "Ptr")
		, DllCall("BitBlt", "ptr", dst, "int", 0, "int", 0, "int", w, "int", h, "ptr", src, "int", x, "int", y, "Uint", 0xCC0020)
		if (bw<>"")
		{
			b:=(bw>>16)&x0xFF, g:=(bw>>8)&0xFF, r:=bw&0xFF
			Loop % w*h
			{
				Addr := pbits + A_Index*4
				if (abs(r - NumGet(Addr+2, 0, "UChar"))<=v)
				&& (abs(g - NumGet(Addr+1, 0, "UChar"))<=v)
				&& (abs(b - NumGet(Addr+0, 0, "UChar"))<=v)
					Numput(0, Addr+0, "UInt")
				else	Numput(0xFFFFFF, Addr+0, "UInt")			
			}
		}
		if leptonica
		{
			hData := DllCall("GlobalAlloc", "uint", 0x2, "uint", 54 + w*h*4, "ptr")
			, pData := DllCall("GlobalLock", "ptr", hData, "ptr")
			, DllCall("RtlMoveMemory", "ptr", pData + 0, "ptr", &header, "UInt", 54)		; destination, source, length
			, DllCall("RtlMoveMemory", "ptr", pData + 54, "ptr", pbits, "UInt", w*h*4)
			, hPix := DllCall("libleptonica1831\pixReadMemBmp", "Ptr", pData, "UInt", 54+w*h*4, "Ptr")
			, DllCall("libtesseract530\TessBaseAPISetImage2", "Ptr", hAPI, "Ptr", hPix)
			; , out := FileOpen("out.bmp", "w"), out.Rawwrite(pData+0,54+w*h*4), out.Close()
			, DllCall("GlobalUnlock", "ptr", hData)		; don't unlock immediately after rtlmovememory, wait a little bit
		} else	DllCall("libtesseract530\TessBaseAPISetImage", "Ptr", hAPI, "Ptr", pbits, "UInt", w, "UInt", h, "UInt", bytes_per_pixel := 4, "UInt", bytes_per_line := 4*w)
		str := DllCall("libtesseract530\TessBaseAPIGetUTF8Text", "Ptr", hAPI, "AStr")

		DllCall("DeleteDC", "ptr", dst)
		, DllCall("DeleteObject", "ptr", dib)
		, DllCall("ReleaseDC", "ptr", win_id, "ptr", src)
	}
	return str
}

LoadLibrary(dll)
{
	if !hModule:=DllCall("LoadLibrary", "Str", dll, "Ptr")
		msgbox % "LoadLibrary(" dll "): " GetLastError(A_LastError)
	return hModule
}

GetLastError(Error=0)
{
	VarSetCapacity(ErrorString, 1024)
	IfEqual, Error, 0, SetEnv, Error, %A_LastError%
	if DllCall("FormatMessage" 
		, "UINT", 0x1000	; FORMAT_MESSAGE_FROM_SYSTEM: The function should search the system message-table resource(s) for the requested message. 
		, "PTR", 0		; A handle to the module that contains the message table to search. 
		, "UINT", Error
		, "UINT", 0             ; Language-ID is automatically retreived 
		, "Str",  ErrorString 
		, "UINT", 1024          ; Buffer-Length 
		, "STR", "")		; "str",  "")            ;An array of values that are used as insert values in the formatted message. (not used) 
		return ErrorString
}


; LetUserSelectRect
; https://www.autohotkey.com/boards/viewtopic.php?t=42810

;[Gdip functions]
;GDI+ standard library 1.45 by tic - AutoHotkey Community
;https://autohotkey.com/boards/viewtopic.php?f=6&t=6517


#include gdip_all.ahk

CoordMode, Mouse, Screen

; q:: ;take printscreen based on selection rectangle
; DetectHiddenWindows, On
; InputRect(vWinX, vWinY, vWinR, vWinB)
; vWinW := vWinR-vWinX, vWinH := vWinB-vWinY
; if (vInputRectState = -1)
; 	return

; vScreen := vWinX "|" vWinY "|" vWinW "|" vWinH
; pToken := Gdip_Startup()
; pBitmap := Gdip_BitmapFromScreen(vScreen, 0x40CC0020)
; DllCall("gdiplus\GdipCreateHBITMAPFromBitmap", Ptr,pBitmap, PtrP,hBitmap, Int,0xffffffff)

; ;SplashImage, % "HBITMAP:" hBitmap, B
; SplashImage, % "HBITMAP:" hBitmap
; Sleep, 2000
; SplashImage, Off

; DeleteObject(hBitmap)
; Gdip_DisposeImage(pBitmap)
; Gdip_Shutdown(pToken)
; return


;based on LetUserSelectRect by Lexikos:
;LetUserSelectRect - select a portion of the screen - Scripts and Functions - AutoHotkey Community
;https://autohotkey.com/board/topic/45921-letuserselectrect-select-a-portion-of-the-screen/

;note: 'CoordMode, Mouse, Screen' must be used in the auto-execute section

;e.g.
;InputRect(vWinX, vWinY, vWinR, vWinB)
;vWinW := vWinR-vWinX, vWinH := vWinB-vWinY
;if (vInputRectState = -1)
;	return

InputRect(ByRef vX1, ByRef vY1, ByRef vX2, ByRef vY2)
{
	global vInputRectState := 0
	DetectHiddenWindows, On
	Gui, 1: -Caption +ToolWindow +AlwaysOnTop +hWndhGuiSel
	Gui, 1: Color, Red
	WinSet, Transparent, 128, % "ahk_id " hGuiSel
	Hotkey, *LButton, InputRect_Return, On
	Hotkey, *RButton, InputRect_End, On
	Hotkey, Esc, InputRect_End, On
	KeyWait, LButton, D
	MouseGetPos, vX0, vY0
	SetTimer, InputRect_Update, 10
	KeyWait, LButton
	Hotkey, *LButton, Off
	Hotkey, Esc, InputRect_End, Off
	SetTimer, InputRect_Update, Off
	Gui, 1: Destroy
	return

	InputRect_Update:
	if !vInputRectState
	{
		MouseGetPos, vX, vY
		(vX < vX0) ? (vX1 := vX, vX2 := vX0) : (vX1 := vX0, vX2 := vX)
		(vY < vY0) ? (vY1 := vY, vY2 := vY0) : (vY1 := vY0, vY2 := vY)
		Gui, 1:Show, % "NA x" vX1 " y" vY1 " w" (vX2-vX1) " h" (vY2-vY1)
		return
	}
	vInputRectState := 1

	InputRect_End:
	if !vInputRectState
		vInputRectState := -1
	Hotkey, *LButton, Off
	Hotkey, *RButton, Off
	Hotkey, Esc, Off
	SetTimer, InputRect_Update, Off
	Gui, 1: Destroy

	InputRect_Return:
	return
}
