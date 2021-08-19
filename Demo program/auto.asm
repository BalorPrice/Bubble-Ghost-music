;-------------------------------------------------------
; BUBBLE GHOST MUSIC PLAYER

; tobermory@cookingcircle.co.uk, 18-Aug-2021.
; This version, demo with logo and VU player bars running

;-------------------------------------------------------
; Entry point
				dump 1,0
				autoexec
				org &8000

auto.start:
				di
	@set_stack:
				ld sp,@+stack
				jp main.start

				ds &40
@stack:
auto.main.stack:
				ds &40
int.main.stack:
				ds 1

;-------------------------------------------------------
; MODULES
				include "house.asm"						; Equates and general housekeeping routines
				include "interrupts.asm"				; Interrupt set up and loops
				include "jump.asm"						; Routines sitting under screen/s, initially to jump to other pages' routs
				include "gfx.asm"						; Bubble Ghost logo data and print routine
				include "keys.asm"						; 
				include "game.asm"
				include "maths.asm"
				include "music.asm"
				include "sfx.asm"

;-------------------------------------------------------
; GLOBAL VARIABLES

sfx.on:			db On									; Global switch for SFX on or off
music.on:		db On									; Same for music
demo.mode.on:	db Off									; If set to On, SFX will not play when triggered

;-------------------------------------------------------
; MAIN LOOP
main.start:
				call main.setup
	@init_state:
				ld hl,int.ll.off
				call int.ll.installHL
				ld hl,game.print_screen
				ld de,disp.game
				call int.onHLDE
main.disp.loop:
	@wait_frame:
				ld a,(int.new_frames_elapsed.live)
				or a
				jp z,@-wait_frame
				ld (int.new_frames_elapsed),a
				xor a
				ld (int.new_frames_elapsed.live),a

	disp.state:	call 0

	@reset_frame_count:
				xor a
				ld (int.new_frames_elapsed),a

				jp main.disp.loop

;-------------------------------------------------------
game.state:		jp 0

;-------------------------------------------------------
main.setup:
; One-time only setup routines.
	@set_low_page:
				ld a,ScreenPage1 + ROMOut
				out (LMPR),a
	@set_video_page:
				ld a,ScreenPage1 + Mode4
				out (VMPR),a

				ld a,8
				call house.palette_offA
				ld a,3
				out (BorderReg),a
				call jump.prep							; Copy VU bars printer under screen
				call int.setup							; Set up interrupts 
				ld a,3 * &11
				call house.clear_screensA

				ld a,music.end
				call music.setA
				ret

;=======================================================
auto.end:
auto.len:		equ auto.end - auto.start

print "-----------------------------------------------------------------------------------"
print "auto.start      ", auto.start, 		" auto.end   ", auto.end, 		" auto.len    ", auto.len
print "jump.start      ", jump.start, 		" jump.end   ", jump.end, 		" jump.len    ", jump.len
print "int.start       ", int.start, 		" int.end    ", int.end, 		" int.len     ", int.len
print "gfx.start       ", gfx.start, 		" gfx.end    ", gfx.end, 		" gfx.len     ", gfx.len
print "-----------------------------------------------------------------------------------"
