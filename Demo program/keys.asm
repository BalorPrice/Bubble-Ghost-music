;-------------------------------------------------------
; KEYS READING AND INTERPRETING
				
;-------------------------------------------------------
f9:						equ 7							; Bits set (1) when key pressed
f8:						equ 6
f7:						equ 5
f6:						equ 4
f5:						equ 3
f4:						equ 2
f3:						equ 1
f2:						equ 0
f1:						equ 5
curs.down:				equ 2
curs.up:				equ 1

keys.extra:				db 0							; F1 and cursors 
keys.curr:				db 0							; F2-F9

;-------------------------------------------------------
keys.input:
; Poll keys
@cursors:				
				ld bc,&fffe
				in a,(c)
				cpl
				and %00000110
				ld d,a
@f1:
				ld bc,&fef9
				in a,(c)
				cpl
				and %00100000
				or d
				ld (keys.extra),a
				
@f9f8f7:
				ld bc,&fbf9
				in a,(c)
				cpl
				and %11100000
				for 3,rlca
				ld d,a
@f6f5f4:
				ld bc,&fdf9
				in a,(c)
				cpl
				and %11100000
				or d
				for 3,rlca
				ld d,a
@f3f2:
				ld bc,&fef9
				in a,(c)
				cpl
				and %11000000
				or d
				ld d,a
				for 2,rlca
				
				ld (keys.curr),a
				ret
		
;-------------------------------------------------------
		