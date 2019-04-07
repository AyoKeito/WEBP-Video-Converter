IfNotExist ffmpeg.exe
	MsgBox,16,Critical file missing, ffmpeg.exe is missing. `nPlease download it and place next to the program.`nApp will now exit.
    ifMsgBox Ok
        ExitApp
if A_IsCompiled
    Menu, Tray, Icon, %A_ScriptFullPath%, -159
#MaxMem 1024
GUIRESTART:
Gui, Destroy
Gui, New
Gui, -Resize +MinSize410x480 -MaximizeBox
GuiClose(GuiHwnd) {
Process, Close , img2webp.exe
Process, Close , ffmpeg.exe
ExitApp
}
Name=
Gui, Show, xCenter yCenter w450 h150, WEBP VIDEO CODER
;by AyoKeito
Gui, Add, Edit, ReadOnly vFileName x10 y30 w390 r1, Waiting for file
Gui, Add, Text, x10 y11, Drag and drop your folder
Gui, Add, Button, x10 y100 w390 r1.5 Default, Start
Gui, Add, Edit, ReadOnly vName x10 y55 w390 r1, %Name%
Gui, Add, Text, x10 y82,Framerate:
Framerate=30
Gui, Add, ComboBox, x70 y80 w50 vFramerate, 20|25|30||50
Gui, Add, Text, x130 y82, | libwebp-1.0.2 x64 | MediaInfo 18.12 | ffmpeg 4.1.1 |
Gui, Add, Slider, x420 y25 h110 vQuality Vertical Invert Range1-100, 100
Gui, Add, Text, x410 y10, Quality
Gui, Add, Link, x365 y135, <a href="https://github.com/AyoKeito/">AyoKeito Github</a>
Gui, Add, StatusBar,, Waiting to start.
Gui, Submit, NoHide
Gui, Show
GuiDropFiles(GuiHwnd, FileArray, CtrlHwnd, X, Y) {
    for 1, file in FileArray
        GuiControl,, FileName, %file%
		OutDir=
		SelectedFile=%file%
		GuiControl, Disabled, Here
		FileSelectFile, Name, 8, , WEBP animation, *.webp
		Name=%Name%.webp
		GuiControl,, Name, %Name%
		Gui, Submit, NoHide
}
return
ButtonStart:
SplitPath, FileName, , OutDir
    if OutDir contains %A_Space%
	    {
	    MsgBox,16,Spaces in folder path detected, Please remove all spaces from the working path and restart
	    ExitApp
	    }	
Process, Priority, , B
Gui, Submit, NoHide
GuiControl, Disabled, Here
GuiControl, Disabled, Start
GuiControl, Disabled, Loop
GuiControl, Disabled, Framerate
Gui -E0x10
Working=%FileName%
if Working contains %A_Space%
{
Renaming:= StrReplace(FileName, A_Space, "_")
FileMove, %Working%, %Renaming%
Working=%Renaming%
FileName=%Renaming%
}
StringTrimRight, Working, FileName, 4
FileCreateDir, %Working%
FramesFolder=%Working%
FileInstall, img2webp.exe, %FramesFolder%\img2webp.exe, 1
SB_SetText("Uncompressing video to " Working)
Working=%Working%\frame_`%03d.png
;RunWait, ffmpeg.exe -probesize 1000M -i %FileName% -vsync vfr -vf scale=1280:720 -sws_flags lanczos+full_chroma_inp %Working%,,Hide,
SB_SetText("Uncompressing finished")
StringTrimRight, FileName, FileName, 4
FramerateToWEBP:= 1000 // Framerate
FFileList := Array()
VarSetCapacity(LongInputString, 90240000)
Loop, Files, %FramesFolder%\*.png,
{
    FFileList.Push(A_LoopFileName)
}
Loop % FFileList.Length()
{
LoopReadLine := FFileList[A_Index]
tempstorage=%LoopReadLine%
LongInputString=%LongInputString% %tempstorage% -d %FramerateToWEBP% -q %Quality%
}
Length := StrLen(LongInputString)
SB_SetText("Encoding " Name)
clipboard = %FramesFolder%\img2webp.exe -mixed %LongInputString% -o %Name%
SetWorkingDir, %FramesFolder%
RunWait, %FramesFolder%\img2webp.exe -mixed %LongInputString% -o %Name%,,Hide,
SetWorkingDir, %A_ScriptDir%
pause
FileRemoveDir, %FramesFolder%\, 1
SB_SetText("Done!")
;RunWait, ffprobe.exe -probesize 1000M -i %Name%.mkv -debug 1 -report,,Hide,
ExitApp
