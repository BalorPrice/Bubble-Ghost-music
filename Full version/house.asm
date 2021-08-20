;-------------------------------------------------------
; HOUSEKEEPING ROUTINES

; Paging
MainPage:		equ 1		; 32768
MusicAdminPage:	equ 3		; 65536 (1990 bytes)
MusicCompPage:	equ 5		; 98304 (28160 bytes)

; Logic signalling - some equates to make code easier to read
On:				equ 0
Off:			equ -1

; Hardware values
LMPR:			equ 250
HMPR:			equ 251
VMPR:			equ 252
PaletteBaseReg:	equ 248
StatusReg:		equ 249
KeyboardReg:	equ 254
BorderReg:		equ 254
ROMOut:			equ %00100000