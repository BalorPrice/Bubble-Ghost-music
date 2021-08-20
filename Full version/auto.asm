;-------------------------------------------------------
; BUBBLE GHOST MUSIC & SFX

; tobermory@cookingcircle.co.uk, 20-Aug-2021.

;-------------------------------------------------------
; Entry point
				dump 1,0
				org &8000

auto.start:
				di
				jp main.start

				ds &40
@stack:

;-------------------------------------------------------
; MODULES
				include "house.asm"						; Equates and general housekeeping routines
				include "maths.asm"
				include "music.asm"						; Also includes SFX module

;-------------------------------------------------------
; MAIN LOOP
main.start:
				in a,(HMPR)
				and %00011111
				or ROMOut
				out (LMPR),a
				jp @+here - &8000		
	@here:
				org @here - &8000						; Run in lower memory
				
				ld sp,@-stack - &8000
				ld a,MusicAdminPage						; Music admin page in high memory
				out (HMPR),a
				
				xor a									; NOP out DI...EI pair
				ld (music.int1),a
				ld (music.int2),a
				
				ld a,music.end							; Set music
				call music.setA
main.loop:
				in a,(StatusReg)						; Wait for frame
				bit 3,a
				jp nz,main.loop

				call music.play							; Play music
				call sfx.update.out						; Play sound effect if active
				
				in a,(KeyboardReg)						; Test for space
				cp 95
				jp z,main.loop							; If not pressed, loop
				
				ld c,sfx.level_complete					; If pressed, start new sound effect
				call sfx.setC.out

				jp main.loop						

;=======================================================

