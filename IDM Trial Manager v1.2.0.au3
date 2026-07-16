#NoTrayIcon

#Region AutoIt3Wrapper directives section
#AutoIt3Wrapper_Icon=app.ico
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=Y
#EndRegion AutoIt3Wrapper directives section

#Region Includes
#include <sys.au3>
#include <GUIConstantsEx.au3>
#include <Misc.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <FontConstants.au3>
#include <Process.au3>
#include <FileConstants.au3>
#EndRegion Includes

_Singleton(@ScriptName)

#Region Options
Opt('MustDeclareVars', 1)
Opt('GUICloseOnESC', 0)
Opt('TrayMenuMode', 1)
#EndRegion Options

; ===== License Information =====
Global Const $LICENSE_TEXT = "MIT License" & @CRLF & _
    "Copyright (c) 2026 JTeam10" & @CRLF & _
    "" & @CRLF & _
    "Permission is hereby granted, free of charge, to any person obtaining a copy" & @CRLF & _
    "of this software and associated documentation files (the 'Software'), to deal" & @CRLF & _
    "in the Software without restriction, including without limitation the rights" & @CRLF & _
    "to use, copy, modify, merge, publish, distribute, sublicense, and/or sell" & @CRLF & _
    "copies of the Software, and to permit persons to whom the Software is" & @CRLF & _
    "furnished to do so, subject to the following conditions:" & @CRLF & _
    "" & @CRLF & _
    "The above copyright notice and this permission notice shall be included in all" & @CRLF & _
    "copies or substantial portions of the Software." & @CRLF & _
    "" & @CRLF & _
    "THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR" & @CRLF & _
    "IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY," & @CRLF & _
    "FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE" & @CRLF & _
    "AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER" & @CRLF & _
    "LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM," & @CRLF & _
    "OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE" & @CRLF & _
    "SOFTWARE." & @CRLF & @CRLF & _
    "========================================" & @CRLF & @CRLF & _
    "⚠️ DISCLAIMER & LEGAL NOTICE" & @CRLF & @CRLF & _
    "This tool is intended for educational and evaluation purposes only." & @CRLF & _
    "The use of this software to bypass license restrictions may violate the terms of service" & @CRLF & _
    "of Internet Download Manager (IDM). Users are strongly encouraged to purchase a valid" & @CRLF & _
    "license from https://www.internetdownloadmanager.com to support the developers of IDM." & @CRLF & _
    "" & @CRLF & _
    "The author assumes NO responsibility for any misuse, damages, or legal consequences" & @CRLF & _
    "arising from the use of this tool. By using this software, you acknowledge that:" & @CRLF & _
    "" & @CRLF & _
    "• You are using this tool at your own risk" & @CRLF & _
    "• You will not hold the author liable for any damages or legal issues" & @CRLF & _
    "• You understand that this tool may violate IDM's terms of service" & @CRLF & _
    "• You agree to purchase a legitimate license if you continue using IDM"

; ===== Global Variables =====
Global $btFreeze, $btActivate, $btResetNow, $btDownload
Global $lblStatus, $lblSerial
Global $lblFreeze, $lblFreezeDesc, $lblFreezeDesc2, $lblFreezeDesc3
Global $lblStatusTitle, $lblActTitle, $lblActDesc, $lblActDesc2
Global $lblResetTitle, $lblResetWarn
Global $bIsProcessing = False
Global $bButtonClicked = False
Global $hGUI
Global $lblPleaseWait1, $lblPleaseWait2, $lblPleaseWait3, $lblPleaseWait4
Global $hTimer = 0
Global $iUpdateInterval = 3000

; ===== Application Information =====
Global Const $APP_NAME = "IDM Trial Manager"
Global Const $APP_VERSION = "v1.2.0"
Global Const $APP_TITLE = $APP_NAME & " " & $APP_VERSION

; ===== Color Constants =====
Global Const $COLOR_BG = 0x101527
Global Const $COLOR_BUTTON = 0x0D9488
Global Const $COLOR_BUTTON_DISABLED = 0x0D9488
Global Const $COLOR_SECONDARY = 0x8B949E
Global Const $COLOR_WHITE = 0xFFFFFF
Global Const $COLOR_LINE = 0x1A2A4A
Global Const $COLOR_DISCLAIMER = 0x6B7B8D

; ===== Layout Constants =====
Global Const $BUTTON_X = 270
Global Const $BUTTON_W = 120
Global Const $BUTTON_H = 38
Global Const $LABEL_X = 25
Global Const $DESC_X = 25
Global Const $LINE_X = 15
Global Const $LINE_W = 390

; Script Start
If $CmdLine[0] = 0 Then
    GUI()
Else
    Switch $CmdLine[1]
        Case '/trial'
            FreezeOnly()
            clearTemp()
        Case Else
            GUI()
    EndSwitch
EndIf

; ===== Function for Auto Update Timer =====
Func UpdateTimer()
    If Not $bIsProcessing Then
        UpdateStatus($lblStatus)
        UpdateButtonsState()
    EndIf
EndFunc

; ===== Function to Update Buttons State Based on IDM Installation =====
Func UpdateButtonsState()
    Local $sVersion = GetIDMVersion()

    If $sVersion = "Not Installed" Then
        ; IDM is not installed: Show Download button, disable other buttons
        GUICtrlSetState($btDownload, $GUI_SHOW)
        GUICtrlSetState($btDownload, $GUI_ENABLE)
        GUICtrlSetColor($btDownload, $COLOR_WHITE)
        GUICtrlSetBkColor($btDownload, $COLOR_BUTTON)

        ; Disable Freeze button
        GUICtrlSetState($btFreeze, $GUI_DISABLE)
        GUICtrlSetColor($btFreeze, $COLOR_SECONDARY)
        GUICtrlSetBkColor($btFreeze, $COLOR_BUTTON_DISABLED)

        ; Disable Activate button
        GUICtrlSetState($btActivate, $GUI_DISABLE)
        GUICtrlSetColor($btActivate, $COLOR_SECONDARY)
        GUICtrlSetBkColor($btActivate, $COLOR_BUTTON_DISABLED)

        ; Disable Reset button
        GUICtrlSetState($btResetNow, $GUI_DISABLE)
        GUICtrlSetColor($btResetNow, $COLOR_SECONDARY)
        GUICtrlSetBkColor($btResetNow, $COLOR_BUTTON_DISABLED)
    Else
        ; IDM is installed: Hide Download button, enable other buttons
        GUICtrlSetState($btDownload, $GUI_HIDE)

        ; Enable Freeze button
        GUICtrlSetState($btFreeze, $GUI_ENABLE)
        GUICtrlSetColor($btFreeze, $COLOR_WHITE)
        GUICtrlSetBkColor($btFreeze, $COLOR_BUTTON)

        ; Enable Activate button
        GUICtrlSetState($btActivate, $GUI_ENABLE)
        GUICtrlSetColor($btActivate, $COLOR_WHITE)
        GUICtrlSetBkColor($btActivate, $COLOR_BUTTON)

        ; Enable Reset button
        GUICtrlSetState($btResetNow, $GUI_ENABLE)
        GUICtrlSetColor($btResetNow, $COLOR_WHITE)
        GUICtrlSetBkColor($btResetNow, $COLOR_BUTTON)
    EndIf
EndFunc

; ===== Function to Get IDM Version =====
Func GetIDMVersion()
    Local $sIDMPath = ""

    If FileExists(@ProgramFilesDir & "\Internet Download Manager\IDMan.exe") Then
        $sIDMPath = @ProgramFilesDir & "\Internet Download Manager\IDMan.exe"
    ElseIf FileExists(@ProgramFilesDir & "\IDM\IDMan.exe") Then
        $sIDMPath = @ProgramFilesDir & "\IDM\IDMan.exe"
    ElseIf FileExists("C:\Program Files (x86)\Internet Download Manager\IDMan.exe") Then
        $sIDMPath = "C:\Program Files (x86)\Internet Download Manager\IDMan.exe"
    ElseIf FileExists("C:\Program Files (x86)\IDM\IDMan.exe") Then
        $sIDMPath = "C:\Program Files (x86)\IDM\IDMan.exe"
    EndIf

    If $sIDMPath = "" Then Return "Not Installed"

    Local $aVersion = FileGetVersion($sIDMPath)
    If @error Then Return "Unknown"

    Return $aVersion
EndFunc

; ===== Function to Get IDM Serial =====
Func GetIDMSerial()
    Local $sSerial = ""

    ; Try to read serial from multiple registry locations
    Local $aRegPaths[3]
    $aRegPaths[0] = "HKEY_CURRENT_USER\Software\DownloadManager"
    $aRegPaths[1] = "HKEY_LOCAL_MACHINE\SOFTWARE\Internet Download Manager"
    $aRegPaths[2] = "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Internet Download Manager"

    Local $aValueNames[2]
    $aValueNames[0] = "Serial"
    $aValueNames[1] = "SerialNumber"

    For $i = 0 To UBound($aRegPaths) - 1
        For $j = 0 To UBound($aValueNames) - 1
            $sSerial = RegRead($aRegPaths[$i], $aValueNames[$j])
            If Not @error And $sSerial <> "" Then
                Return $sSerial
            EndIf
        Next
    Next

    Return "Not Found"
EndFunc

; ===== Function to Calculate Days Between Two Dates =====
Func _DateDiffDays($sDate1, $sDate2)
    Local $aDate1 = StringSplit($sDate1, "/")
    Local $aDate2 = StringSplit($sDate2, "/")

    If $aDate1[0] <> 3 Or $aDate2[0] <> 3 Then Return -1

    Local $iYear1 = Number($aDate1[1])
    Local $iMonth1 = Number($aDate1[2])
    Local $iDay1 = Number($aDate1[3])

    Local $iYear2 = Number($aDate2[1])
    Local $iMonth2 = Number($aDate2[2])
    Local $iDay2 = Number($aDate2[3])

    Local $iDays1 = _DateToDays($iYear1, $iMonth1, $iDay1)
    Local $iDays2 = _DateToDays($iYear2, $iMonth2, $iDay2)

    Return $iDays2 - $iDays1
EndFunc

; ===== Function to Convert Date to Days =====
Func _DateToDays($iYear, $iMonth, $iDay)
    Local $iA = Int(($iMonth - 14) / 12)
    Local $iB = Int(($iYear + 4800 + $iA) / 4)
    Local $iC = Int((1461 * ($iYear + 4800 + $iA)) / 4)
    Local $iD = Int((367 * ($iMonth - 2 - 12 * $iA)) / 12)
    Local $iE = Int((3 * Int(($iYear + 4900 + $iA) / 100)) / 4)

    Return $iC + $iD - $iE + $iDay - 32075
EndFunc

; ===== Function to Get IDM Installation Date =====
Func GetIDMInstallDate()
    Local $sInstallDate = ""

    Local $aRegPaths[8]
    $aRegPaths[0] = "HKEY_CURRENT_USER\Software\DownloadManager"
    $aRegPaths[1] = "HKEY_CURRENT_USER\Software\Internet Download Manager"
    $aRegPaths[2] = "HKEY_LOCAL_MACHINE\SOFTWARE\Internet Download Manager"
    $aRegPaths[3] = "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Internet Download Manager"
    $aRegPaths[4] = "HKEY_CURRENT_USER\Software\Classes\Internet Download Manager"
    $aRegPaths[5] = "HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Internet Download Manager"
    $aRegPaths[6] = "HKEY_CURRENT_USER\Software\DownloadManager"
    $aRegPaths[7] = "HKEY_LOCAL_MACHINE\SOFTWARE\DownloadManager"

    Local $aValueNames[5]
    $aValueNames[0] = "InstallDate"
    $aValueNames[1] = "FirstInstall"
    $aValueNames[2] = "TrialDate"
    $aValueNames[3] = "Install"
    $aValueNames[4] = "Date"

    For $i = 0 To 7
        For $j = 0 To 4
            $sInstallDate = RegRead($aRegPaths[$i], $aValueNames[$j])
            If Not @error And $sInstallDate <> "" Then
                ExitLoop 2
            EndIf
        Next
    Next

    If $sInstallDate = "" Or @error Then
        Local $sIDMPath = ""
        If FileExists(@ProgramFilesDir & "\Internet Download Manager\IDMan.exe") Then
            $sIDMPath = @ProgramFilesDir & "\Internet Download Manager\IDMan.exe"
        ElseIf FileExists(@ProgramFilesDir & "\IDM\IDMan.exe") Then
            $sIDMPath = @ProgramFilesDir & "\IDM\IDMan.exe"
        ElseIf FileExists("C:\Program Files (x86)\Internet Download Manager\IDMan.exe") Then
            $sIDMPath = "C:\Program Files (x86)\Internet Download Manager\IDMan.exe"
        ElseIf FileExists("C:\Program Files (x86)\IDM\IDMan.exe") Then
            $sIDMPath = "C:\Program Files (x86)\IDM\IDMan.exe"
        EndIf

        If $sIDMPath <> "" Then
            Local $sFileTime = FileGetTime($sIDMPath, 0, 1)
            If Not @error And $sFileTime <> "" Then
                $sInstallDate = StringLeft($sFileTime, 8)
                $sInstallDate = StringMid($sInstallDate, 1, 4) & "/" & StringMid($sInstallDate, 5, 2) & "/" & StringMid($sInstallDate, 7, 2)
            EndIf
        EndIf
    EndIf

    If $sInstallDate <> "" Then
        Local $aCheck = StringSplit($sInstallDate, "/")
        If $aCheck[0] = 3 Then
            If Number($aCheck[1]) >= 2000 And Number($aCheck[1]) <= 2100 Then
                If Number($aCheck[2]) >= 1 And Number($aCheck[2]) <= 12 Then
                    If Number($aCheck[3]) >= 1 And Number($aCheck[3]) <= 31 Then
                        Return $sInstallDate
                    EndIf
                EndIf
            EndIf
        EndIf
    EndIf

    Return ""
EndFunc

; ===== Function to Get Current Date =====
Func _GetCurrentDate()
    Return @YEAR & "/" & @MON & "/" & @MDAY
EndFunc

; ===== Function to Calculate Trial Days Left =====
Func GetTrialDaysLeft()
    Local $sInstallDate = GetIDMInstallDate()
    Local $sCurrentDate = _GetCurrentDate()

    If $sInstallDate = "" Then
        Return 30
    EndIf

    Local $iDateDiff = _DateDiffDays($sInstallDate, $sCurrentDate)

    If $iDateDiff > 30 Or $iDateDiff < 0 Then
        Return 30
    EndIf

    Local $iDaysLeft = 30 - $iDateDiff
    If $iDaysLeft < 0 Then $iDaysLeft = 0

    Return $iDaysLeft
EndFunc

; ===== Function to Check IDM Status =====
Func CheckIDMStatus()
    Local $sStatus = ""
    Local $sVersion = GetIDMVersion()

    If $sVersion = "Not Installed" Then
        Return "❌ IDM is not installed on this windows!"
    EndIf

    If $sVersion = "Unknown" Then
        Return "⚠️ IDM version could not be detected!"
    EndIf

    Local $sRegPath = "HKEY_CURRENT_USER\Software\DownloadManager"
    Local $sRegValue = RegRead($sRegPath, "FName")

    If @error Then
        $sRegPath = "HKEY_LOCAL_MACHINE\SOFTWARE\Internet Download Manager"
        $sRegValue = RegRead($sRegPath, "FName")

        If @error Then
            $sRegPath = "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Internet Download Manager"
            $sRegValue = RegRead($sRegPath, "FName")
        EndIf
    EndIf

    If $sRegValue <> "" And Not @error Then
        $sStatus = "✅ Registered (original serial number) - v" & $sVersion
        Return $sStatus
    Else
        Local $iDaysLeft = GetTrialDaysLeft()

        If $iDaysLeft > 0 And $iDaysLeft <= 30 Then
            $sStatus = "⚠️ Trial Mode - v" & $sVersion & " (" & $iDaysLeft & " days left)"
            Return $sStatus
        ElseIf $iDaysLeft = 0 Then
            $sStatus = "⚠️ Trial Mode - v" & $sVersion & " (Expired - Use Reset!)"
            Return $sStatus
        Else
            $sStatus = "⚠️ Trial Mode - v" & $sVersion & " (Unknown status)"
            Return $sStatus
        EndIf
    EndIf
EndFunc

; ===== Function to Update Status Display =====
Func UpdateStatus($lblStatus)
    Local $sStatus = CheckIDMStatus()
    GUICtrlSetData($lblStatus, $sStatus)

    ; عرض السريال تحت الحالة
    Local $sSerial = GetIDMSerial()
    Local $sVersion = GetIDMVersion()

    If $sVersion = "Not Installed" Then
        GUICtrlSetData($lblSerial, "Serial: Not Available")
        GUICtrlSetColor($lblSerial, $COLOR_SECONDARY)
    ElseIf $sSerial <> "Not Found" Then
        ; عرض كل السريال مع إخفاء آخر 4 خانات فقط
        Local $sDisplaySerial = StringLeft($sSerial, StringLen($sSerial) - 4) & "****"
        GUICtrlSetData($lblSerial, "Serial: " & $sDisplaySerial)
        GUICtrlSetColor($lblSerial, 0x2ECC71)
    Else
        GUICtrlSetData($lblSerial, "Serial: Not Found")
        GUICtrlSetColor($lblSerial, 0xFF6B6B)
    EndIf

    If StringInStr($sStatus, "✅") Then
        GUICtrlSetColor($lblStatus, 0x2ECC71)
        GUICtrlSetState($btDownload, $GUI_HIDE)
    ElseIf StringInStr($sStatus, "⚠️") Then
        If StringInStr($sStatus, "Expired") Then
            GUICtrlSetColor($lblStatus, 0xFF6B6B)
        Else
            GUICtrlSetColor($lblStatus, 0xFFA500)
        EndIf
        GUICtrlSetState($btDownload, $GUI_HIDE)
    ElseIf StringInStr($sStatus, "❌") Then
        GUICtrlSetColor($lblStatus, 0xFF6B6B)
    Else
        GUICtrlSetColor($lblStatus, 0xFF0000)
        GUICtrlSetState($btDownload, $GUI_HIDE)
    EndIf

    UpdateButtonsState()
EndFunc

; ===== Function to Close IDM =====
Func CloseIDM()
    Local $aProcesses = ProcessList("IDMan.exe")
    For $i = 1 To $aProcesses[0][0]
        ProcessClose($aProcesses[$i][1])
    Next

    $aProcesses = ProcessList("IDMIntegrator64.exe")
    For $i = 1 To $aProcesses[0][0]
        ProcessClose($aProcesses[$i][1])
    Next

    $aProcesses = ProcessList("IDMIntegrator.exe")
    For $i = 1 To $aProcesses[0][0]
        ProcessClose($aProcesses[$i][1])
    Next

    Sleep(1000)
EndFunc

; ===== Function to Start IDM =====
Func StartIDM()
    If FileExists(@ProgramFilesDir & "\Internet Download Manager\IDMan.exe") Then
        Run(@ProgramFilesDir & "\Internet Download Manager\IDMan.exe", "", @SW_SHOW)
    ElseIf FileExists(@ProgramFilesDir & "\IDM\IDMan.exe") Then
        Run(@ProgramFilesDir & "\IDM\IDMan.exe", "", @SW_SHOW)
    ElseIf FileExists("C:\Program Files (x86)\Internet Download Manager\IDMan.exe") Then
        Run("C:\Program Files (x86)\Internet Download Manager\IDMan.exe", "", @SW_SHOW)
    ElseIf FileExists("C:\Program Files (x86)\IDM\IDMan.exe") Then
        Run("C:\Program Files (x86)\IDM\IDMan.exe", "", @SW_SHOW)
    EndIf
EndFunc

; ===== Function to Download IDM =====
Func DownloadIDM()
    ShellExecute("https://www.internetdownloadmanager.com")
    Return True
EndFunc

; ===== Function to Disable All Buttons Except One =====
Func DisableButtonsExcept($sButtonToKeep)
    Local $iState = $GUI_DISABLE

    GUICtrlSetState($btFreeze, $iState)
    GUICtrlSetColor($btFreeze, $COLOR_SECONDARY)
    GUICtrlSetBkColor($btFreeze, $COLOR_BUTTON_DISABLED)

    GUICtrlSetState($btActivate, $iState)
    GUICtrlSetColor($btActivate, $COLOR_SECONDARY)
    GUICtrlSetBkColor($btActivate, $COLOR_BUTTON_DISABLED)

    GUICtrlSetState($btResetNow, $iState)
    GUICtrlSetColor($btResetNow, $COLOR_SECONDARY)
    GUICtrlSetBkColor($btResetNow, $COLOR_BUTTON_DISABLED)

    GUICtrlSetState($btDownload, $iState)
    GUICtrlSetColor($btDownload, $COLOR_SECONDARY)
    GUICtrlSetBkColor($btDownload, $COLOR_BUTTON_DISABLED)

    GUICtrlSetState($lblPleaseWait1, $GUI_HIDE)
    GUICtrlSetState($lblPleaseWait2, $GUI_HIDE)
    GUICtrlSetState($lblPleaseWait3, $GUI_HIDE)
    GUICtrlSetState($lblPleaseWait4, $GUI_HIDE)

    Switch $sButtonToKeep
        Case "freeze"
            GUICtrlSetState($btFreeze, $GUI_HIDE)
            GUICtrlSetState($lblPleaseWait1, $GUI_SHOW)
            GUICtrlSetData($lblPleaseWait1, 'Please wait...')
        Case "activate"
            GUICtrlSetState($btActivate, $GUI_HIDE)
            GUICtrlSetState($lblPleaseWait2, $GUI_SHOW)
            GUICtrlSetData($lblPleaseWait2, 'Please wait...')
        Case "reset"
            GUICtrlSetState($btResetNow, $GUI_HIDE)
            GUICtrlSetState($lblPleaseWait3, $GUI_SHOW)
            GUICtrlSetData($lblPleaseWait3, 'Please wait...')
        Case "download"
            GUICtrlSetState($btDownload, $GUI_HIDE)
            GUICtrlSetState($lblPleaseWait4, $GUI_SHOW)
            GUICtrlSetData($lblPleaseWait4, 'Please wait...')
    EndSwitch

    $bIsProcessing = True
EndFunc

; ===== Function to Enable All Buttons =====
Func EnableAllButtons()
    GUICtrlSetState($btFreeze, $GUI_ENABLE)
    GUICtrlSetColor($btFreeze, $COLOR_WHITE)
    GUICtrlSetBkColor($btFreeze, $COLOR_BUTTON)
    GUICtrlSetData($btFreeze, 'Freeze Trial')
    GUICtrlSetState($btFreeze, $GUI_SHOW)

    GUICtrlSetState($btActivate, $GUI_ENABLE)
    GUICtrlSetColor($btActivate, $COLOR_WHITE)
    GUICtrlSetBkColor($btActivate, $COLOR_BUTTON)
    GUICtrlSetData($btActivate, 'Get Serial')
    GUICtrlSetState($btActivate, $GUI_SHOW)

    GUICtrlSetState($btResetNow, $GUI_ENABLE)
    GUICtrlSetColor($btResetNow, $COLOR_WHITE)
    GUICtrlSetBkColor($btResetNow, $COLOR_BUTTON)
    GUICtrlSetData($btResetNow, 'Reset Now')
    GUICtrlSetState($btResetNow, $GUI_SHOW)

    GUICtrlSetState($btDownload, $GUI_ENABLE)
    GUICtrlSetColor($btDownload, $COLOR_WHITE)
    GUICtrlSetBkColor($btDownload, $COLOR_BUTTON)
    GUICtrlSetData($btDownload, 'Download IDM')

    GUICtrlSetState($lblPleaseWait1, $GUI_HIDE)
    GUICtrlSetState($lblPleaseWait2, $GUI_HIDE)
    GUICtrlSetState($lblPleaseWait3, $GUI_HIDE)
    GUICtrlSetState($lblPleaseWait4, $GUI_HIDE)

    $bIsProcessing = False
    $bButtonClicked = False

    UpdateButtonsState()
EndFunc

Func GUI()
    #Region ### START Koda GUI section ###
    $hGUI = GUICreate($APP_TITLE, 420, 550, -1, -1, BitOR($WS_MINIMIZEBOX, $WS_CAPTION, $WS_SYSMENU))
    GUISetBkColor($COLOR_BG, $hGUI)

    ; ===== Header Section =====
    Local $lblTitle = GUICtrlCreateLabel($APP_NAME, 20, 15, 400, 45)
    GUICtrlSetFont(-1, 25, 700, 0, 'Segoe UI')
    GUICtrlSetColor(-1, $COLOR_WHITE)

    Local $lblVersion = GUICtrlCreateLabel($APP_VERSION, 20, 60, 150, 22)
    GUICtrlSetFont(-1, 11, 400, 0, 'Segoe UI')
    GUICtrlSetColor(-1, $COLOR_SECONDARY)

    Local $lblSubTitle = GUICtrlCreateLabel('IDM Tool By JTeam10', 20, 85, 250, 20)
    GUICtrlSetFont(-1, 9.5, 400, 0, 'Segoe UI')
    GUICtrlSetColor(-1, $COLOR_SECONDARY)

    ; إضافة زر الترخيص
    Local $btnLicense = GUICtrlCreateButton("License", 340, 80, 55, 20)
    GUICtrlSetFont(-1, 7, 400, 0, "Segoe UI")
    GUICtrlSetColor(-1, $COLOR_SECONDARY)
    GUICtrlSetBkColor(-1, 0x2D2D2D)
    GUICtrlSetCursor(-1, 0)

    Local $line1 = GUICtrlCreateLabel('', $LINE_X, 110, $LINE_W, 1)
    GUICtrlSetBkColor(-1, $COLOR_LINE)

    ; ===== Section 1: IDM Status =====
    $lblStatusTitle = GUICtrlCreateLabel('IDM Status', $LABEL_X, 125, 150, 24)
    GUICtrlSetFont(-1, 13, 700, 0, 'Segoe UI')
    GUICtrlSetColor(-1, $COLOR_WHITE)

    $lblStatus = GUICtrlCreateLabel('Checking IDM Status...', $LABEL_X, 153, 300, 18)
    GUICtrlSetFont(-1, 9.5, 400, 0, 'Segoe UI')
    GUICtrlSetColor(-1, $COLOR_SECONDARY)

    $lblSerial = GUICtrlCreateLabel('Serial: Checking...', $LABEL_X, 173, 350, 18)
    GUICtrlSetFont(-1, 9, 400, 0, 'Segoe UI')
    GUICtrlSetColor(-1, $COLOR_SECONDARY)

    $btDownload = GUICtrlCreateButton('Download IDM', $BUTTON_X, 136, $BUTTON_W, $BUTTON_H)
    GUICtrlSetFont(-1, 10, 600, 0, 'Segoe UI')
    GUICtrlSetColor(-1, $COLOR_WHITE)
    GUICtrlSetBkColor(-1, $COLOR_BUTTON)
    GUICtrlSetCursor(-1, 0)
    GUICtrlSetState(-1, $GUI_HIDE)

    $lblPleaseWait4 = GUICtrlCreateLabel('', $BUTTON_X, 136, $BUTTON_W, $BUTTON_H)
    GUICtrlSetFont(-1, 10, 600, 0, 'Segoe UI')
    GUICtrlSetColor(-1, $COLOR_WHITE)
    GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
    GUICtrlSetStyle(-1, $SS_CENTER)
    GUICtrlSetState(-1, $GUI_HIDE)

    Local $line2 = GUICtrlCreateLabel('', $LINE_X, 200, $LINE_W, 1)
    GUICtrlSetBkColor(-1, $COLOR_LINE)

    ; ===== Section 2: Free Serial =====
    $lblActTitle = GUICtrlCreateLabel('Free Serial', $LABEL_X, 210, 150, 24)
    GUICtrlSetFont(-1, 13, 700, 0, 'Segoe UI')
    GUICtrlSetColor(-1, $COLOR_WHITE)

    $lblActDesc = GUICtrlCreateLabel('Get a free serial key for 180 days', $DESC_X, 237, 220, 16)
    GUICtrlSetFont(-1, 8.5, 400, 0, 'Segoe UI')
    GUICtrlSetColor(-1, $COLOR_SECONDARY)

    $lblActDesc2 = GUICtrlCreateLabel('New serial number after the expiry', $DESC_X, 255, 220, 16)
    GUICtrlSetFont(-1, 8.5, 400, 0, 'Segoe UI')
    GUICtrlSetColor(-1, $COLOR_SECONDARY)

    $btActivate = GUICtrlCreateButton('Get Serial', $BUTTON_X, 225, $BUTTON_W, $BUTTON_H)
    GUICtrlSetFont(-1, 10, 600, 0, 'Segoe UI')
    GUICtrlSetColor(-1, $COLOR_WHITE)
    GUICtrlSetBkColor(-1, $COLOR_BUTTON)
    GUICtrlSetCursor(-1, 0)

    $lblPleaseWait2 = GUICtrlCreateLabel('', $BUTTON_X, 225, $BUTTON_W, $BUTTON_H)
    GUICtrlSetFont(-1, 10, 600, 0, 'Segoe UI')
    GUICtrlSetColor(-1, $COLOR_WHITE)
    GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
    GUICtrlSetStyle(-1, $SS_CENTER)
    GUICtrlSetState(-1, $GUI_HIDE)

    Local $line3 = GUICtrlCreateLabel('', $LINE_X, 290, $LINE_W, 1)
    GUICtrlSetBkColor(-1, $COLOR_LINE)

    ; ===== Section 3: Freeze Trial =====
    $lblFreeze = GUICtrlCreateLabel('Freeze Trial', $LABEL_X, 305, 150, 24)
    GUICtrlSetFont(-1, 13, 700, 0, 'Segoe UI')
    GUICtrlSetColor(-1, $COLOR_WHITE)

    $lblFreezeDesc = GUICtrlCreateLabel('Freeze the 30-day trial period permanently.', $DESC_X, 332, 250, 16)
    GUICtrlSetFont(-1, 8.5, 400, 0, 'Segoe UI')
    GUICtrlSetColor(-1, $COLOR_SECONDARY)

    $lblFreezeDesc2 = GUICtrlCreateLabel('Most reliable method.', $DESC_X, 350, 370, 16)
    GUICtrlSetFont(-1, 8.5, 400, 0, 'Segoe UI')
    GUICtrlSetColor(-1, $COLOR_SECONDARY)

    $lblFreezeDesc3 = GUICtrlCreateLabel('Blocks registration popups permanently.', $DESC_X, 368, 370, 16)
    GUICtrlSetFont(-1, 8.5, 400, 0, 'Segoe UI')
    GUICtrlSetColor(-1, $COLOR_SECONDARY)

    $btFreeze = GUICtrlCreateButton('Freeze Trial', $BUTTON_X, 325, $BUTTON_W, $BUTTON_H)
    GUICtrlSetFont(-1, 10, 600, 0, 'Segoe UI')
    GUICtrlSetColor(-1, $COLOR_WHITE)
    GUICtrlSetBkColor(-1, $COLOR_BUTTON)
    GUICtrlSetCursor(-1, 0)

    $lblPleaseWait1 = GUICtrlCreateLabel('', $BUTTON_X, 325, $BUTTON_W, $BUTTON_H)
    GUICtrlSetFont(-1, 10, 600, 0, 'Segoe UI')
    GUICtrlSetColor(-1, $COLOR_WHITE)
    GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
    GUICtrlSetStyle(-1, $SS_CENTER)
    GUICtrlSetState(-1, $GUI_HIDE)

    Local $line4 = GUICtrlCreateLabel('', $LINE_X, 395, $LINE_W, 1)
    GUICtrlSetBkColor(-1, $COLOR_LINE)

    ; ===== Section 4: Reset / Clean =====
    $lblResetTitle = GUICtrlCreateLabel('Reset / Clean', $LABEL_X, 405, 150, 24)
    GUICtrlSetFont(-1, 13, 700, 0, 'Segoe UI')
    GUICtrlSetColor(-1, $COLOR_WHITE)

    $lblResetWarn = GUICtrlCreateLabel('Warning: Deletes all keys.', $DESC_X, 433, 200, 18)
    GUICtrlSetFont(-1, 9.5, 400, 0, 'Segoe UI')
    GUICtrlSetColor(-1, 0xFF6B6B)

    $btResetNow = GUICtrlCreateButton('Reset Now', $BUTTON_X, 415, $BUTTON_W, $BUTTON_H)
    GUICtrlSetFont(-1, 10, 600, 0, 'Segoe UI')
    GUICtrlSetColor(-1, $COLOR_WHITE)
    GUICtrlSetBkColor(-1, $COLOR_BUTTON)
    GUICtrlSetCursor(-1, 0)

    $lblPleaseWait3 = GUICtrlCreateLabel('', $BUTTON_X, 415, $BUTTON_W, $BUTTON_H)
    GUICtrlSetFont(-1, 10, 600, 0, 'Segoe UI')
    GUICtrlSetColor(-1, $COLOR_WHITE)
    GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
    GUICtrlSetStyle(-1, $SS_CENTER)
    GUICtrlSetState(-1, $GUI_HIDE)

    ; ===== Footer Section with Disclaimer =====
    Local $line5 = GUICtrlCreateLabel('', $LINE_X, 470, $LINE_W, 1)
    GUICtrlSetBkColor(-1, $COLOR_LINE)

    Local $lblDisclaimer = GUICtrlCreateLabel('⚠️ For educational & evaluation purposes only.' & @CRLF & _
                                               'Support IDM by purchasing a license.', 15, 480, 390, 32)
    GUICtrlSetFont(-1, 8, 400, 0, 'Segoe UI')
    GUICtrlSetColor(-1, $COLOR_DISCLAIMER)
    GUICtrlSetStyle(-1, $SS_CENTER)

    Local $lblFooter = GUICtrlCreateLabel('All rights reserved 2026 | JTeam10', 15, 515, 390, 20)
    GUICtrlSetFont(-1, 8, 400, 0, 'Segoe UI')
    GUICtrlSetColor(-1, $COLOR_SECONDARY)
    GUICtrlSetStyle(-1, $SS_CENTER)

    GUISetState(@SW_SHOW)

    $hTimer = AdlibRegister("UpdateTimer", $iUpdateInterval)
    UpdateStatus($lblStatus)
    UpdateButtonsState()

    #EndRegion ### END Koda GUI section ###

    While 1
        Local $nMsg = GUIGetMsg()
        Switch $nMsg
            Case $GUI_EVENT_CLOSE
                AdlibUnRegister($hTimer)
                clearTemp()
                GUIDelete($hGUI)
                Exit

            Case $btnLicense
                ; عرض نافذة الترخيص مع إخلاء المسؤولية
                MsgBox(262144, "License & Disclaimer - IDM Trial Manager", $LICENSE_TEXT)

            Case $btResetNow
                If $bIsProcessing Or $bButtonClicked Then ContinueLoop
                $bButtonClicked = True
                DisableButtonsExcept("reset")
                ResetOnly()
                Sleep(1000)
                Verification()
                Sleep(2000)
                UpdateStatus($lblStatus)
                EnableAllButtons()
                StartIDM()
                MsgBox(262144, 'Reset IDM Trial', 'You have 30 day trial now!')

            Case $btFreeze
                If $bIsProcessing Or $bButtonClicked Then ContinueLoop
                $bButtonClicked = True
                DisableButtonsExcept("freeze")
                FreezeOnly()
                Sleep(1000)
                Verification()
                Sleep(2000)
                UpdateStatus($lblStatus)
                EnableAllButtons()
                StartIDM()
                MsgBox(262144, 'Freeze Trial', 'Trial has been frozen! You have 30 day trial permanently.')

            Case $btActivate
                If $bIsProcessing Or $bButtonClicked Then ContinueLoop
                $bButtonClicked = True
                DisableButtonsExcept("activate")
                ActivateOnly()
                Sleep(1000)
                Verification()
                Sleep(2000)
                UpdateStatus($lblStatus)
                EnableAllButtons()
                StartIDM()
                MsgBox(262144, 'Register IDM', 'IDM is registered now!')

            Case $btDownload
                If $bIsProcessing Or $bButtonClicked Then ContinueLoop
                $bButtonClicked = True
                DisableButtonsExcept("download")
                DownloadIDM()
                Sleep(2000)
                UpdateStatus($lblStatus)
                EnableAllButtons()

        EndSwitch
    WEnd
EndFunc   ;==>GUI