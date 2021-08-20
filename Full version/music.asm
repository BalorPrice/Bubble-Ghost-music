;-------------------------------------------------------
; MUSIC

; This module acts as a wrapper for the main player routine by Andrew Collier
;-------------------------------------------------------

music.src:
;=======================================================
				org 0									; Compiled music page 
				dump MusicCompPage,0

; Compiled Protracker files
music.data0:	mdat "music/intro.raw"					; Compiled to 0
music.data1:	mdat "music/main2.raw"					; 1554
music.data2:	mdat "music/end.raw"					; 15323

				ds 32
music.stack:	

;-------------------------------------------------------
music.play2:
				call music.output						; Play previous frame's output values
				call music.process						; Process next frame of music
				call music.attenuate					; Attentuate music before SFX overlaid
				ret

				include "player.asm"					; player routine by Andrew Collier

;-------------------------------------------------------
music.attenuate:
; Set music volume for all channels.
	@prep_volume:
				ld c,0
				ld a,(music.on)							; Use volume as 0 if music is not on
				cp On
				jr nz,@+skip

				ld a,(music.volume)
				ld c,a
		@skip:

				ld de,music.table
				ld h,music.volume_table / &100
				ld a,6
@loop:
				ex af,af'
	@left_channel:
				ld a,(de)
				and %11110000
				add c
				ld l,a
				ld a,(hl)
				for 4,add a
				ld b,a
	@right_channel:
				ld a,(de)
				for 4,add a
				add c
				ld l,a
				ld a,(hl)
	@output:
				or b
				ld (de),a
	@next:
				inc de
				ex af,af'
				dec a
				jr nz,@-loop
				ret

				ds align 256
music.volume_table:
				db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
				db 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
				db 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2
				db 0, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 3, 3, 3
				db 0, 1, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4
				db 0, 1, 1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5, 5
				db 0, 1, 1, 1, 2, 2, 2, 3, 3, 4, 4, 4, 5, 5, 6, 6
				db 0, 1, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7
				db 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8
				db 0, 1, 1, 2, 2, 3, 4, 4, 5, 5, 6, 7, 7, 8, 8, 9
				db 0, 1, 1, 2, 3, 3, 4, 5, 5, 6, 7, 7, 8, 9, 9,10
				db 0, 1, 1, 2, 3, 4, 4, 5, 6, 7, 7, 8, 9,10,10,11
				db 0, 1, 2, 2, 3, 4, 5, 6, 6, 7, 8, 9,10,10,11,12
				db 0, 1, 2, 3, 3, 4, 5, 6, 7, 8, 9,10,10,11,12,13
				db 0, 1, 2, 3, 4, 5, 6, 7, 7, 8, 9,10,11,12,13,14
				db 0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15
				
MusicCompPage.end:

;=======================================================
					org &8000
					dump MusicAdminPage,0

music.lut:
; Lookup table for start addresses of each piece of music
music.intro:		equ 0								; Intro piece plays in attract sequence
					dw music.data0
music.main:			equ 1								; Main music while playing
					dw music.data1
music.end:			equ 2								; Success end music
					dw music.data2

;-------------------------------------------------------
music.table:		equ SOUNDTABLE 						; Protracker SOUNDTABLE offset
music.output:		equ PLAYROUTINE						; Tweaked Protracker playback routine.  Send output to chip
music.process:		equ AFTERSOUNDCHIP					; Process next Protracker frame.
music.setup:		equ STARTPLAYER						; Protracker prep tune call address

music.on:			db On								; Global switch for if music plays at all
music.page:			db MusicCompPage
music.playing:		db On								; Set to on if current music has not run out
music.volume:		db 15								; 0-15 for overall music volume.  Envelopes don't cope well with volume 1
music.curr_tune: 	db 0								; Index of currently playing music from music.lut

;-------------------------------------------------------
music.off:
; Stop sound, but don't reset everything
@volume_down:											; Turn all volumes to 0
				ld bc,511
				ld d,5
				xor a
	@loop:
				call sfx.soundDA
				dec d
				jr nz,@-loop
	@envelopes_off:										; Envelopes don't respond to volume setting after already on
				ld d,24
				xor a
				call sfx.soundDA
				inc d
				call sfx.soundDA
				ret

;-------------------------------------------------------
music.setA:
; Set up tune A to play
music.int1:		di
				
				ld (music.curr_tune),a					; Save tune number
	@paging:											; Page music player into LMPR
				ex af,af'
				in a,(LMPR)
				ld ( @+rest_lo + 1),a
				ld a,(music.page)
				or ROMout
				out (LMPR),a
				ex af,af'

	@find_offset:										; Get offset through music.lut
				add a
				ld e,a
				ld d,0
	@get_tune_addr:										; Get compiled music address
				ld hl,music.lut
				add hl,de
				ld c,(hl)
				inc hl
				ld b,(hl)
				ld (music.setup + 1),bc
				ld a,On									; Set music to currently playing
				ld (music.playing),a

				call music.setup

	@rest_lo:	ld a,0
				out (LMPR),a
				
music.int2:		ei
				ret
;-------------------------------------------------------
music.play:
; Play a frame of currently-selected music.
@page_in:
				in a,(LMPR)
				ld ( @+rest_lo + 1),a
				ld a,(music.page)
				or ROMout
				out (LMPR),a

				call music.play2

@page_out:
	@rest_lo:	ld a,0
				out (LMPR),a
				ret

;-------------------------------------------------------
music.set_volA:
; Set music volume 0-15.  Envelopes don't play properly at volume 1.
@page_in:
				ex af,af'
				in a,(LMPR)
				ld ( @+rest_lo + 1),a
				ld a,(music.page)
				or ROMout
				out (LMPR),a
				ex af,af'

				ld (music.volume),a
@page_out:
				ex af,af'
	@rest_lo:	ld a,0
				out (LMPR),a
				ex af,af'
				ret

;=======================================================

				include "sfx.asm"						; Sound effects put here to stay at end of MusicAdminPage

;=======================================================
				
				org music.src
				dump MainPage,music.src - &8000
