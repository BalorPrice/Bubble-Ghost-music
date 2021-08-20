;-------------------------------------------------------
; SOUND EFFECTS

; Sound effects piggy-backs on top of the Protracker music player, which is played directly from the interrupt module at 50 fps.  

; This uses 'slots' for each sound created, processes them all, then selects the loudest sound/s to output.  I modified the protracker playback module to output music from one frame ago, leaving a window for the SFX module to overwrite any/all channels it needs to.

;-------------------------------------------------------
				include "sfx data.asm"

;-------------------------------------------------------

sfx.mode:			db @single_channel					; How many channels of SFX are played at once
@single_channel:	equ 0
@dual_channel:		equ 1

; CONTROL CHARACTERS
sfx.end:			equ -1
sfx.loop:			equ -2
sfx.ADS:			equ 0
sfx.R:				equ 2								; Add to a sound equate when calling sfx.setA to trigger its Release envelope
sfx.retriggerOK:	equ On
sfx.retriggerOff:	equ Off

; SLOTS STRUCTURE
@curr_sound.os:		equ 0								; Current sound playing.  0 for idle
@sound_pos.os:		equ 1								; Pointer to current sound data
@retrigger.os:		equ 3								; On/Off if restarting sound is allowed
@rand_pitch.os:		equ 4								; Modulus value to restrict overall pitch
@x_pos_addr:		equ 6								; Address of object's map X pos for panning
@sound_enable.os:	equ 8								; Main fundamental channel data
@noise_enable.os:	equ 9
@noise_type.os:		equ 10								; Main channel keeps noise data
@curr_freq.os:		equ 11		
@curr_oct.os:		equ 12		
@curr_vol.os:		equ 13

@curr_sound2.os:	equ 14
@sound_pos2.os:		equ 15								; 2nd channel data
@retrigger2.os:		equ 17	
@rand_pitch2.os:	equ 18	
@x_pos2_addr:		equ 20	
@sound_enable2.os:	equ 22	
@noise_enable2.os:	equ 23
@noise_type2.os:	equ 24	
@curr_freq2.os:		equ 25		
@curr_oct2.os:		equ 26		
@curr_vol2.os:		equ 27


sfx.data.len:		equ @curr_vol2.os + 1
sfx.slots.count:	equ 2
sfx.data:			ds sfx.data.len * sfx.slots.count

		
sfx.init.data:		for sfx.data.len, db 0				; Blank slot

sfx.on:				db On								; Global switch for SFX on or off
sfx.volume:			db 15								; SFX Volume setting 0-15
demo.mode.on:		db Off								; If set to On, SFX will not play when triggered

					ds align 256
sfx.volume_table:	equ music.volume_table				; Volume attenuation table - same as music, but now guarenteed to be in same page.
					
;=======================================================

;-------------------------------------------------------
sfx.init.out:
; Only required if Protracker music is not playing
				ld bc,511
	@reset_SAA:
				ld d,&1c
				ld a,2
				call sfx.soundDA
	@turn_on_SAA:
				dec a
				call sfx.soundDA
				ret

sfx.soundDABC:
				ld bc,511
sfx.soundDA:
				out (c),d
				dec b
				out (c),a
				inc b
				ret

;-------------------------------------------------------
sfx.setC.out:
; Start new sound effect C.  Set bit 7 for release part of sound, reset for ADS part.
; HL points to 16-bit x-pos map coord of object creating noise, for live panning
	@check_sfx_on:										; Return if sfx is turned off
				ld a,(sfx.on)
				cp On
				ret nz

				push ix
				push iy
				push hl
	@find_new_slot:										; Find spare slot to process sound
				ld ix,sfx.data
				ld de,sfx.data.len
				ld b,sfx.slots.count
				xor a
	@find_slot_loop:
				cp (ix)
				jp z,@+success
	@next_slot:
				add ix,de
				djnz @-find_slot_loop
	@failure:
				pop hl
				pop iy
				pop ix
				ret

@success:
	@find_data:											; Find source data
				ld b,0
				ld hl,sfx.jump_table
				add hl,bc
				ld e,(hl)								; 1st channel data
				inc hl
				ld d,(hl)
				push de
				inc hl
				ld e,(hl)								; 2nd channel stored for setting later
				inc hl
				ld d,(hl)
				ld ( @+set_sound2 + 1),de
				pop de
				ex de,hl

	@test_retrigger:									; If playing a unique sound (only one possible at once) check it's not already playing elsewhere
				ld a,(hl)
				and %11000000
				jp z,@+set_sound1
		@find_sound:
				ld iy,sfx.data
				ld de,sfx.data.len
				ld a,c
				and %11111101							; Ignore Release bit for now
				ld b,sfx.slots.count
		@find_sound_loop:
				cp (iy)
				jp z,@+check_release
			@next_slot:
				add iy,de
				djnz @-find_sound_loop
				jp @+set_sound1
		@check_release:									; If sound is found, if releasing then continue, update this slot
				bit 1,c
				jp z,@+quit								; If sound is in ADS part, give up starting new sound
		@update_slot:
				push iy
				pop ix
@set_sound1:											; ID of sound
				ld ( ix + @curr_sound.os),c
	@set_retrigger:
				ld e,(hl)
				inc hl
				xor a
				sla e									; Top two bits saved as retrigger 
				rla
				sla e
				rla
				ld ( ix + @retrigger.os),a
	@set_sound_enable:
				xor a
				sla e
				rla
				sla e
				rla
				ld ( ix + @sound_enable.os),a
	@set_noise_enable:
				xor a
				sla e
				rla
				sla e
				rla
				ld ( ix + @noise_enable.os),a
	@set_noise_type:
				xor a
				sla e
				rla
				sla e
				rla
				ld ( ix + @noise_type.os),a
	@set_rand_val:										; Get randomize pitch size
				ld a,(hl)
				inc hl
				ld ( @+rand_size + 1),a
	@end:
				ld ( ix + @sound_pos.os),l				; Store address of next datum
				ld ( ix + @sound_pos.os + 1),h
				
@set_sound2:	ld hl,0									; 2nd channel data pull goes here
	@set_sfx_mode:										; Test if 2nd channel data present
				ld e,@single_channel
				ld a,l
				or h
				or a
				jr z,@+skip
				ld e,@dual_channel
		@skip:
				ld a,e
				ld (sfx.mode),a
				
	@set_retrigger:
				ld e,(hl)
				inc hl
				xor a
				sla e									; Top two bits saved as retrigger 
				rla
				sla e
				rla
				ld ( ix + @retrigger2.os),a
	@set_sound_enable:
				xor a
				sla e
				rla
				sla e
				rla
				ld ( ix + @sound_enable2.os),a
	@set_noise_enable:
				xor a
				sla e
				rla
				sla e
				rla
				ld ( ix + @noise_enable2.os),a
	@set_noise_type:
				xor a
				sla e
				rla
				sla e
				rla
				ld ( ix + @noise_type2.os),a
				inc hl
	@end:
				ld ( ix + @sound_pos2.os),l				; Store address of next datum
				ld ( ix + @sound_pos2.os + 1),h				
				
	@prep_rand:											; Make variation on pitch for each sound effect
				call maths.rand
				ld a,(maths.seed)
	@rand_size: and 0
				ld l,a
				ld h,0
				srl a
				ld e,a
				ld d,0
				and a
				sbc hl,de
				ld ( ix + @rand_pitch.os),l
				ld ( ix + @rand_pitch.os + 1),h
	@set_x_pos:
				pop hl
				ld ( ix + @x_pos_addr),l
				ld ( ix + @x_pos_addr + 1),h
				pop iy
				pop ix
				ret
	@quit:
				pop hl
				pop iy
				pop ix
				ret

;-------------------------------------------------------
sfx.update.out:
; Update all sound effects and output
	@check_sfx_on:
				ld a,(sfx.on)
				cp On
				ret nz

				push ix
				push iy
	@page_in:
				ex af,af'
				in a,(LMPR)
				ld ( @+rest_lo + 1),a
				ld a,(music.page)
				or ROMOut
				out (LMPR),a
				ex af,af'

				call @process_effects
				call @outputIY0
	@check_mode:										; Check mode to see how many sounds output (Currently broken!)
				ld a,(sfx.mode)
				cp @dual_channel
				call z,@output2IY3

	@rest_lo:	ld a,0
				out (LMPR),a

				pop iy
				pop ix
				ret

;-------------------------------------------------------
@process_effects:
; Process each effect separately, return with IY=>loudest sound, IX=>2nd loudest
				ld ix,sfx.data
				ld iy,sfx.init.data						; Set IY to loudest sound, start in a blank sfx slot
				ld de,sfx.init.data
				ld b,sfx.slots.count
	@update_loop:
				push bc
		@check_active:
				ld a,( ix + @curr_sound.os)
				or a
				jp z,@+next_slot
		@update:
				push de
				call sfx.updateIX
				ld a,(sfx.mode)
				cp @dual_channel
				call z,sfx.update2IX
				pop de
		@test_volume:									; If loudest noise so far, point IY to it to play
				ld a,( iy + @curr_vol.os)
				cp ( ix + @curr_vol.os)
				jp nc,@+next_slot
		@update_loudest_sound:
				ld e,iyl								; Use D'E' for 2nd loudest sound
				ld d,iyh
				push ix									; Use IY for loudest sound
				pop iy
		@next_slot:
				ld bc,sfx.data.len
				add ix,bc
				pop bc
				djnz @-update_loop

				ld ixl,e
				ld ixh,d
				ret

;-------------------------------------------------------
sfx.updateIX:
; Update sound effect at IX
	@get_current_pos:
				ld l,( ix + @sound_pos.os)
				ld h,( ix + @sound_pos.os + 1)
	@test_live:											; If end token found, turn sound off and reset retrigger
				ld a,(hl)
				cp sfx.end
				jp nz,@+test_loop
	@deactivate_sfx:
				ld ( ix + @curr_sound.os),0
				ret

	@test_loop:											; If loop token found, reset position counter and reread
				cp sfx.loop
				jp nz,@+read_pitch
	@apply_loop:
				inc hl
				ld e,(hl)
				inc hl
				ld d,(hl)
				ex de,hl
				jp @-test_live

	@read_pitch:
				ld d,(hl)
				inc hl
				ld e,(hl)
				inc hl
	@add_randomness:
				push hl
				ld l,( ix + @rand_pitch.os)
				ld h,( ix + @rand_pitch.os + 1)
				add hl,de
				ld ( ix + @curr_oct.os),h
				ld ( ix + @curr_freq.os),l
				pop hl
	@read_volume:
				ld a,(demo.mode.on)						; If demo mode on, no sound effects please
				cp On
				ld a,0
				jr z,@+skip
				ld a,(hl)
		@skip:
				call sfx.attenuateA						; Apply overall sfx volume
				inc hl
				ld ( ix + @curr_vol.os),a
	@store_pos:
				ld ( ix + @sound_pos.os),l
				ld ( ix + @sound_pos.os + 1),h
				ret

;-------------------------------------------------------
sfx.update2IX:
; Update sound effect 2nd channel at IX
	@get_current_pos:
				ld l,( ix + @sound_pos2.os)
				ld h,( ix + @sound_pos2.os + 1)
	@test_live:											; If end token found, turn sound off and reset retrigger
				ld a,(hl)
				cp sfx.end
				jp nz,@+test_loop
	@deactivate_sfx:
				ld ( ix + @curr_sound2.os),0
				ret

	@test_loop:											; If loop token found, reset position counter and reread
				cp sfx.loop
				jp nz,@+read_pitch
	@apply_loop:
				inc hl
				ld e,(hl)
				inc hl
				ld d,(hl)
				ex de,hl
				jp @-test_live

	@read_pitch:
				ld d,(hl)
				inc hl
				ld e,(hl)
				inc hl
	@add_randomness:
				push hl
				ld l,( ix + @rand_pitch.os)
				ld h,( ix + @rand_pitch.os + 1)
				add hl,de
				ld ( ix + @curr_oct2.os),h
				ld ( ix + @curr_freq2.os),l
				pop hl
	@read_volume:
				ld a,(demo.mode.on)						; If demo mode on, no sound effects please
				cp On
				ld a,0
				jr z,@+skip
				ld a,(hl)
		@skip:
				call sfx.attenuateA						; Apply overall sfx volume
				inc hl
				ld ( ix + @curr_vol2.os),a
	@store_pos:
				ld ( ix + @sound_pos2.os),l
				ld ( ix + @sound_pos2.os + 1),h
				ret
				
;-------------------------------------------------------
sfx.attenuateA:
; Set sfx volume for all channels.
				push bc
				push de
				push hl

				ld d,a
				ld a,(sfx.volume)
				ld c,a
				ld h,sfx.volume_table / 256
@loop:
	@left_channel:
				ld a,d
				and %11110000
				add c
				ld l,a
				ld a,(hl)
				for 4,add a
				ld b,a
	@right_channel:
				ld a,d
				for 4,add a
				add c
				ld l,a
				ld a,(hl)
	@output:
				or b

				pop hl
				pop de
				pop bc
				ret

;-------------------------------------------------------
@outputIY0:
; Output single loudest sound effect to channel 0
				push af

@output_protracker:
	@test_sfx_playing:
				ld a,( iy + @curr_vol.os)				; If loudest volume is 0 then don't overwrite channel
				or a
				jp z,@+end

	@set_sound_enable:
				ld a,(music.table + 15)					; !! Magic numbers, these are all offsets in Protracker's music data table
				and %00111110
				ld e,a
				ld a,( iy + @sound_enable.os)
				or e
				ld (music.table + 15),a
	@set_noise_enable:
				ld a,(music.table + 16)
				and %00011111
				ld e,a
				ld a,( iy + @noise_type.os)
				or e
				ld (music.table + 16),a
	@set_octave:
				ld a,(music.table + 12)
				and %11110000
				ld e,a
				ld a,( iy + @curr_oct.os)
				or e
				ld (music.table + 12),a
	@set_frequency:
				ld a,( iy + @curr_freq.os)
				ld (music.table + 6),a
	@get_volume:
				ld a,( iy + @curr_vol.os)				; Apply panning to volume before outputting
				ld (music.table + 0),a
	@end:
				pop af
				ret

;-------------------------------------------------------
@output2IY3:
; Output 2nd sound effect to channel 3
				push af

@output_protracker:
	@test_sfx_playing:
				ld a,( iy + @curr_vol2.os)				; If loudest volume is 0 then don't overwrite channel
				or a
				jp z,@+end

	@set_sound_enable:
				ld a,(music.table + 15)					; !! Magic numbers, these are all offsets in Protracker's music data table
				and %00110111
				ld e,a
				ld a,( iy + @sound_enable2.os)
				for 3,rlca
				or e
				ld (music.table + 15),a
	@set_noise_enable:
				ld a,(music.table + 16)
				and %00110111
				ld e,a
				ld a,( iy + @noise_type2.os)
				for 3,add a
				or e
				ld (music.table + 16),a
	@set_octave:
				ld a,(music.table + 13)
				and %00001111
				ld e,a
				ld a,( iy + @curr_oct2.os)
				for 4,add a
				or e
				ld (music.table + 13),a
	@set_frequency:
				ld a,( iy + @curr_freq2.os)
				ld (music.table + 9),a
	@get_volume:
				ld a,( iy + @curr_vol2.os)				; Apply panning to volume before outputting
				ld (music.table + 3),a
	@end:
				pop af
				ret

;=======================================================
