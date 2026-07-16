; ============================================================================
; sys.au3 - System Functions for IDM Trial Manager
; Copyright (c) 2026 JTeam10
;
; Licensed under the MIT License
; See the main file for full license text and disclaimer
;
; DISCLAIMER: This tool is for educational and evaluation purposes only.
; Users should purchase a valid IDM license from https://www.internetdownloadmanager.com
; The author assumes NO responsibility for any misuse or legal consequences.
; ============================================================================

#RequireAdmin

#include <Date.au3>
#include <String.au3>

; Install CMD files only
FileInstall('reset.cmd', @TempDir & '\reset.cmd', 1)
FileInstall('freeze.cmd', @TempDir & '\freeze.cmd', 1)
FileInstall('activate.cmd', @TempDir & '\activate.cmd', 1)
FileInstall('verification.cmd', @TempDir & '\verification.cmd', 1)

; ===== Direct Execution Functions =====

Func FreezeOnly()
    ; Run freeze.cmd only
    RunWait('"' & @TempDir & "\freeze.cmd" & '"', "", @SW_HIDE)
EndFunc   ;==>FreezeOnly

Func ActivateOnly()
    ; Run activate.cmd only
    RunWait('"' & @TempDir & "\activate.cmd" & '"', "", @SW_HIDE)
EndFunc   ;==>ActivateOnly

Func ResetOnly()
    ; Run reset.cmd only
    RunWait('"' & @TempDir & "\reset.cmd" & '"', "", @SW_HIDE)
EndFunc   ;==>ResetOnly

Func Verification()
    ; Run verification.cmd only
    RunWait('"' & @TempDir & "\verification.cmd" & '"', "", @SW_HIDE)
EndFunc   ;==>Verification

; ===== Cleanup Function =====

Func clearTemp()
    ; Delete temporary files
    FileDelete(@TempDir & "\reset.cmd")
    FileDelete(@TempDir & "\freeze.cmd")
    FileDelete(@TempDir & "\activate.cmd")
	FileDelete(@TempDir & "\verification.cmd")
EndFunc   ;==>clearTemp