#include-Once

; #INDEX# =======================================================================================================================
; Title .........: Cmd
; AutoIt Version : 3.3.6++
; Language ......: English
; Description ...: Functions for manipulating command prompt windows.
; Author(s) .....: PhilHibbs
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;_CmdGetWindow
;_CmdWaitFor
;_CmdWaitList
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name...........: _CmdGetWindow
; Description ...: Locates the window handle for a given Command Prompt process.
; Syntax.........: _CmdGetWindow($pCmd)
; Parameters ....: $pCmd  - Process id of the Command Prommpt application
; Return values .: Success - Window handle
;                  Failure - -1, sets @error
;                  |1 - Process $pCmd not found
; Author ........: Phil Hibbs (phil at hibbs dot me dot uk)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _CmdGetWindow( $pCmd )
    Local $WinList, $i
    $WinList = WinList()
    For $i = 1 to $WinList[0][0]
        If $WinList[$i][0] <> "" And WinGetProcess( $WinList[$i][1] ) = $pCmd Then
            Return $WinList[$i][1]
        EndIf
    Next
    Return SetError(1, 0, -1)
EndFunc   ;==>_CmdGetWindow

; #FUNCTION# ====================================================================================================================
; Name...........: _CmdWaitFor
; Description ...: Waits for a particular string to be found in a Command Prompt window
; Syntax.........: _CmdWaitFor($hWin, $text, $timeout = -1, $period, $prefix = "" )
; Parameters ....: $hWin    - Window handle
;                  $text    - String to search for
;                  $timeout - How long to wait for in ms, 0 = look once and return, -1 = keep looking for ever
;                  $period  - How long to pause between each content grab
;                  $prefix  - Prefix string, anything prior to this prefix is discarded before searching for $text
; Return values .: Success - True
;                  Failure - False
;                  |1 - Text is not found within the time limit
;                  |2 - Window does not exist
; Author ........: Phil Hibbs (phil at hibbs dot me dot uk)
; Modified.......:
; Remarks .......: The prefix is for searching for something that might occur multiple times, for instance if you issue a command
;                  and want to wait for the User@ prompt, the command itself should be the preifx. If you are issuing the same
;                  command multiple times, you could echo a unique string and use that as the prefix, e.g.
;                     Send( "echo :cmd123:;ls -l{Enter}" )
;                     _CmdWaitFor( $hTelnet, $User & "@", -1, ":cmd123:" )
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _CmdWaitFor( $hWin, $text, $timeout = Default, $period = Default, $prefix = "" )
    Local $timer, $con, $i

    If $timeout = Default Then $timeout = -1
    If $period = Default Then $period = 1000

    SendKeepActive( $hWin )

    $timer = TimerInit()
    While ($timeout <= 0 Or TimerDiff($timer) < $timeout) And WinExists( $hWin )
        Send( "! es{Enter}" )
        $con = ClipGet()
        If $prefix <> "" Then
            $con = StringMid( $con, StringInStr( $con, $prefix, False, -1 ) + StringLen( $prefix ) )
        EndIf
        If StringInStr( $con, $text ) > 0 Then
            Return True
        EndIf
        If $timeout = 0 Then ExitLoop
        Sleep($period)
    WEnd
    Return False
EndFunc   ;==>_CmdWaitFor

; #FUNCTION# ====================================================================================================================
; Name...........: _CmdWaitList
; Description ...: Waits for one of a set of strings to be found in a Command Prompt window
; Syntax.........: _CmdWaitList($hWin, $aText, $timeout = -1, $period, $prefix = "" )
; Parameters ....: $hWin    - Window handle
;                  $aText   - Array of strings to search for
;                  $timeout - How long to wait for in ms, 0 = look once and return, -1 = keep looking for ever
;                  $period  - How long to pause between each content grab
;                  $prefix  - Prefix string, anything prior to this prefix is discarded before searching for $text
; Return values .: Success - Element number found
;                  Failure - -1, sets @error
;                  |1 - Text is not found within the time limit
;                  |2 - Window does not exist
; Author ........: Phil Hibbs (phil at hibbs dot me dot uk)
; Modified.......:
; Remarks .......: The prefix is for searching for something that might occur multiple times, for instance if you issue a command
;                  and want to wait for the User@ prompt, the command itself should be the preifx. If you are issuing the same
;                  command multiple times, you could echo a unique string and use that as the prefix.
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _CmdWaitList( $hWin, ByRef $aText, $timeout = Default, $period = Default, $prefix = "" )
    Local $timer, $con, $i

    If $timeout = Default Then $timeout = -1
    If $period = Default Then $period = 1000

    SendKeepActive( $hWin )

    $timer = TimerInit()
    While ($timeout <= 0 Or TimerDiff($timer) < $timeout) And WinExists( $hWin )
        Send( "! es{Enter}" )
        $con = ClipGet()
        If $prefix <> "" Then
            $con = StringMid( $con, StringInStr( $con, $prefix, False, -1 ) + StringLen( $prefix ) )
        EndIf
        For $i = 0 To UBound( $aText ) - 1
            If StringInStr( $con, $aText[$i] ) > 0 Then
                Return $i
            EndIf
        Next
        If $timeout = 0 Then ExitLoop
        Sleep($period)
    WEnd
    If Not(WinExists( $hWin )) Then Return SetError(2, 0, -1)
    Return SetError(1, 0, -1)
EndFunc   ;==>_CmdWaitList
