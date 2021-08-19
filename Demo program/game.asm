;-------------------------------------------------------
; GAMEPLAY MODULE

; Usually I put a state machine for the gameplay here, this demo doesn't need it

;-------------------------------------------------------
game.print_screen:
; Initialise screens
				ld hl,house.palette
				call house.set_paletteHL
				call gfx.print_logo
				call house.set_curr_palette
	@set_state:
				ld de,game.wait
				ld (game.state + 1),de
				ret
				
;-------------------------------------------------------
game.wait:
; Check keypresses for new music/SFX to play.
	@test_music:
				ld a,(keys.curr)
				ld e,a
				ld a,music.intro
				bit f7,e
				jp nz,@+play_music
				ld a,music.main
				bit f8,e
				jp nz,@+play_music
				ld a,music.end
				bit f9,e
				jp nz,@+play_music
				
	@test_sfx:
				ld c,sfx.bubble_pop
				bit f6,e
				jp nz,@+play_sfx
				ld c,sfx.score_complete
				bit f5,e
				jp nz,@+play_sfx
				ld c,sfx.score_point
				bit f4,e
				jp nz,@+play_sfx
				ld c,sfx.bonus_arp
				bit f3,e
				jp nz,@+play_sfx
				ld c,sfx.fanfare
				bit f2,e
				jp nz,@+play_sfx
				
	@extra:
				ld a,(keys.extra)
				ld e,a
				ld c,sfx.level_complete
				bit f1,e
				jp nz,@+play_sfx
				bit curs.down,e
				jp nz,@+volume_down
				bit curs.up,e
				jp nz,@+volume_up
				ret
	
	@play_music:
				call music.setA							; Set new music and reset volume
				ld a,15
				ld (music.volume),a
				ld a,254
				ld (main.volume),a
				ret
				
	@play_sfx:
				call sfx.setC.out
				ret
				
	@music_off:
				xor a
				ld (music.volume),a
				ret

	@volume_down:
				ld a,(main.volume)
				for 2,dec a
				ld (main.volume),a
				for 4,srl a
				ld (music.volume),a
				ret

	@volume_up:
				ld a,(main.volume)
				for 2,inc a
				ld (main.volume),a
				for 4,srl a
				ld (music.volume),a
				ret
				
main.volume:	db 254

;-------------------------------------------------------
disp.game:
; Display loop updates VU bars only
				call jump.print_bars
				ret
				
;-------------------------------------------------------
				