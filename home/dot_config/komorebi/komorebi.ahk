#Requires AutoHotkey v2.0.2
#SingleInstance Force

Komorebic(cmd) {
    RunWait(format("komorebic.exe {}", cmd), , "Hide")
}

; Basic Controls
!q::Komorebic("close")
!m::Komorebic("minimize")
!+o::Komorebic("reload-configuration")

; Focus windows
!h::Komorebic("focus left")
!j::Komorebic("focus down")
!k::Komorebic("focus up")
!l::Komorebic("focus right")
!+[::Komorebic("cycle-focus previous")
!+]::Komorebic("cycle-focus next")

; Move windows
!+h::Komorebic("move left")
!+j::Komorebic("move down")
!+k::Komorebic("move up")
!+l::Komorebic("move right")

; Stack windows
!Left::Komorebic("stack left")
!Down::Komorebic("stack down")
!Up::Komorebic("stack up")
!Right::Komorebic("stack right")
!`;::Komorebic("unstack")
![::Komorebic("cycle-stack previous")
!]::Komorebic("cycle-stack next")

; Resize
!+Left::Komorebic("resize-window left")
!+Down::Komorebic("resize-window down")
!+Up::Komorebic("resize-window up")
!+Right::Komorebic("resize-window right")

; Workspaces (0-8)
!1::Komorebic("focus-workspace 0")
!2::Komorebic("focus-workspace 1")
!3::Komorebic("focus-workspace 2")
!4::Komorebic("focus-workspace 3")
!5::Komorebic("focus-workspace 4")
!6::Komorebic("focus-workspace 5")
!7::Komorebic("focus-workspace 6")
!8::Komorebic("focus-workspace 7")
!9::Komorebic("focus-workspace 8")

; Move windows across workspaces
!+1::Komorebic("move-to-workspace 0")
!+2::Komorebic("move-to-workspace 1")
!+3::Komorebic("move-to-workspace 2")
!+4::Komorebic("move-to-workspace 3")
!+5::Komorebic("move-to-workspace 4")
!+6::Komorebic("move-to-workspace 5")
!+7::Komorebic("move-to-workspace 6")
!+8::Komorebic("move-to-workspace 7")
!+9::Komorebic("move-to-workspace 8")

; Cycle through workspaces
!Tab::Komorebic("cycle-workspace next")
!+Tab::Komorebic("cycle-workspace previous")

; Layout adjustments
!x::Komorebic("flip-layout horizontal")
!y::Komorebic("flip-layout vertical")
!c::Komorebic("promote")
!+Backspace::Komorebic("retile")
!Backspace::Komorebic("toggle-float")
!t::Komorebic("toggle-float-all")
!w::Komorebic("toggle-monocle")
!+r::Komorebic("toggle-tiling-direction")
!s::Komorebic("toggle-maximize")


; Application shortcuts (customize these)
; !f::
; {
;     if !WinExist("ahk_exe firefox.exe")
;         Run "firefox.exe"
;     else
;         WinActivate "ahk_exe firefox.exe"
; }
;
; !b::
; {
;     if !WinExist("ahk_exe chrome.exe")
;         Run "chrome.exe"
;     else
;         WinActivate "ahk_exe chrome.exe"
; }
