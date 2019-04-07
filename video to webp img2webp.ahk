if A_IsCompiled
    Menu, Tray, Icon, %A_ScriptFullPath%, -159
#MaxMem 8094
DllCall( "LoadLibrary", Str,"MediaInfo.Dll" )
GUIRESTART:
Gui, Destroy
Gui, New
Gui, -Resize +MinSize410x480 -MaximizeBox
GuiClose(GuiHwnd) {
Process, Close , img2webp.exe
Process, Close , ffmpeg.exe
if (FfmpegInstalled=1)
    FileDelete, ffmpeg.exe
if (MediaInfoInstalled=1)
    FileDelete, MediaInfo.exe
ExitApp
}
Name=
Gui, Show, xCenter yCenter w450 h150, WEBP Video Converter
;by AyoKeito
Gui, Add, Edit, ReadOnly vFileName x10 y30 w390 r1, Waiting for file
Gui, Add, Text, x10 y11, Drag and drop your file
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
;
SB_SetText("Getting media information for " FileName)

IfNotExist MediaInfo.exe
	FileInstall, MediaInfo.exe, MediaInfo.exe, 1
	MediaInfoInstalled=1
MediaInfoCheck:
RunWait, MediaInfo.exe --LogFile=video.log --Inform=Video`;`%Width`%\r\n`%Height`% %FileName%,,Hide,
FileReadLine, ResolutionWidth, video.log, 1
FileReadLine, ResolutionHeight, video.log, 2
TotalPixelCount:=ResolutionWidth*ResolutionHeight
FileDelete, video.log
Working=%Working%\frame_`%03d.png
IfNotExist ffmpeg.exe
	FileInstall, ffmpeg.exe, ffmpeg.exe, 1
	FfmpegInstalled=1
if TotalPixelCount is space
    MsgBox,18,Video analysis failed, Video analysis by MediaInfo has failed`nSuccessfull encoding is not guaranteed.`nMaybe your file is not a video file.
	IfMsgBox Abort
	   {
	   Process, Close , img2webp.exe
	   Process, Close , ffmpeg.exe
	   if (FfmpegInstalled=1)
	       FileDelete, ffmpeg.exe
	   if (MediaInfoInstalled=1)
	       FileDelete, MediaInfo.exe
	   FileRemoveDir, %FramesFolder%\, 1
	   ExitApp
	   }
	IfMsgBox Retry
	   GOTO MediaInfoCheck
	IfMsgBox Ignore
	   {
	   }
if (TotalPixelCount > 921600)
MsgBox,52,Resolution is higher than HD, Your file resolution (pixel count) is higher than HD 1280x720.`nSmooth playback is not guaranteed.`nDo you want to downscale to 1280x720?
IfMsgBox Yes
    {
    SB_SetText("Extracting frames to " Working)
	RunWait, ffmpeg.exe -probesize 1000M -i %FileName% -vsync vfr -vf scale=1280:720 -sws_flags lanczos+full_chroma_inp %Working%,,Hide,
    SB_SetText("Frames are ready")
	}
else
    {
    SB_SetText("Extracting frames to " Working)
	RunWait, ffmpeg.exe -probesize 1000M -i %FileName% -vsync vfr %Working%,,Hide,
    SB_SetText("Frames are ready")
	}
;
StringTrimRight, FileName, FileName, 4
FramerateToWEBP:= 1000 // Framerate
FFileList := Array()
VarSetCapacity(LongInputString, 90240000)
Loop, Files, %FramesFolder%\*.png,
{
    FFileList.Push(A_LoopFileName)
	NumberOfFiles  += 1
}
if (NumberOfFiles > 300)
MsgBox,48,High number of frames, Your video is longer than 300 frames`nSuccessfull encoding is not guaranteed.
Loop % FFileList.Length()
{
LoopReadLine := FFileList[A_Index]
tempstorage=%LoopReadLine%
LongInputString=%LongInputString% %tempstorage% -d %FramerateToWEBP% -q %Quality%
}
Length := StrLen(LongInputString)
FileDelete, %FramesFolder%\parameters
FileAppend, -mixed %LongInputString% -o %Name%, %FramesFolder%\parameters,
SB_SetText("Encoding " Name)
;clipboard = %FramesFolder%\img2webp.exe -mixed %LongInputString% -o %Name%
SetWorkingDir, %FramesFolder%
RunWait, %FramesFolder%\img2webp.exe parameters,,Hide,
SetWorkingDir, %A_ScriptDir%
FileRemoveDir, %FramesFolder%\, 1
SB_SetText("Done!")
;RunWait, ffprobe.exe -probesize 1000M -i %Name%.mkv -debug 1 -report,,Hide,
CLEANUP:
if (FfmpegInstalled=1)
    FileDelete, ffmpeg.exe
if (MediaInfoInstalled=1)
    FileDelete, MediaInfo.exe
ExitApp
