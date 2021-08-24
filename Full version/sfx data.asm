;-------------------------------------------------------
; SFX DATA


sfx.jump.len:		equ 8								; Length of each jump table entry

;-------------------------------------------------------
; JUMP TABLE FOR A/D/S PART, and RELEASE PART
sfx.jump_table:
					for sfx.jump.len, db 0				; Empty table entry for sound 0

sfx.score_point:	equ sfx.jump.len * 1				; Effect IDs go up in 8s for easy lookup in table
					dw sfx.score_point.dataADS	 		; Address of Attack-Decay-Sustain data, 1st and 2nd channel (0 for null)
					dw sfx.score_point.data2ADS
					dw 0, 0								; Address of Release data
sfx.score_complete:	equ sfx.jump.len * 2
					dw sfx.score_complete.dataADS, sfx.score_complete.data2ADS
					dw 0, 0
sfx.bubble_pop:		equ sfx.jump.len * 3
					dw sfx.bubble_pop.dataADS, 0
					dw 0, 0
sfx.bonus_arp:		equ sfx.jump.len * 4
					dw sfx.bonus_arp.dataADS, sfx.bonus_arp.data2ADS
					dw 0, 0
sfx.fanfare:		equ sfx.jump.len * 5
					dw sfx.fanfare.dataADS, sfx.fanfare.data2ADS
					dw 0, 0
sfx.level_complete:	equ sfx.jump.len * 6
					dw sfx.level_complete.dataADS, sfx.level_complete.data2ADS
					dw 0, 0
sfx.click:			equ sfx.jump.len * 7
					dw sfx.click.dataADS, 0
					dw 0,0

;-------------------------------------------------------
; Chromatic pitches, equal tempered
; C		21
; C#	3c
; D		55
; D#	6d
; E		84
; F		99
; F#	ad
; G		c0
; G#	d2
; A		e3
; A#	f3
; B		05

;-------------------------------------------------------
sfx.example.dataADS:
; Attack-Decay-Sustain data
				db %01000101							; Header format (each 2 bits): retrigger, sound_enable, noise_enable, noise_type
				db 0									; Pitch limiter (restrict the randomness of pitch)
				db &00,&00,&11							; Main data (1 byte each): octave, frequency, volume
				db &00,&00,&22
	@loop:
				db &00,&00,&44
				db sfx.loop								; If held note, finish ADS part with a loop token and address to loop back to
				dw @-loop
				; db sfx.end							; Else use end token.  For this, Release data will likely be null.

sfx.example.dataR:
; Release data
				db %01000101,0							; Release data in same format as ADS data
				db &03,&00,&33
				db &03,&00,&22
				db &03,&00,&11
				db sfx.end

;-------------------------------------------------------
sfx.score_point.dataADS:
; Add point to score
				db %01010000,%00000011
				db &05,&30,&fc
				db &05,&30,&eb
				db &05,&a0,&da
				db &05,&a0,&b8
				db &05,&a0,&63
				
				db &03,&00,&00
				db &03,&00,&00
				db &03,&00,&00
				db sfx.end


sfx.score_point.data2ADS:
				db %01010000,%00000011
				db &03,&00,&00
				db &03,&00,&00
				db &03,&00,&00
				
				db &05,&30,&af
				db &05,&30,&9e
				db &05,&a0,&8d
				db &05,&a0,&6b
				db &05,&a0,&16
				db sfx.end
				
;-------------------------------------------------------
sfx.score_complete.dataADS:
; Score tally complete
				db %00010000,%00000011
				db &05,&f0,&ff
				db &05,&f0,&ff
				db &06,&f0,&ff
				db &06,&f0,&bb
				db &06,&f0,&66
				
				db &03,&00,&00
				db &03,&00,&00
				db sfx.end

sfx.score_complete.data2ADS:
				db %00010000,%00000011
				db &03,&00,&00
				db &03,&00,&00
				
				db &05,&f0,&af
				db &05,&f0,&af
				db &06,&f0,&af
				db &06,&f0,&6b
				db &06,&f0,&16
				db sfx.end
				
;-------------------------------------------------------
sfx.bubble_pop.dataADS:
; Bubble pop dying noise
				db %00000111,0
				db &06,&c0,&88
				db &07,&20,&88
				db &07,&10,&77
				db &06,&ff,&77
				db &06,&ee,&77
				db &06,&dd,&66
				db &06,&cc,&66
				db &06,&bb,&66
				db &06,&aa,&55
				db &06,&99,&55
				db &06,&99,&55
				db &06,&88,&44
				db &06,&88,&44
				db &06,&77,&33
				db &06,&77,&33
				db &06,&66,&22
				db &06,&66,&22
				db &06,&66,&22
				db &06,&66,&11
				db &06,&66,&11
				db &06,&66,&11
				db sfx.end

;-------------------------------------------------------
sfx.bonus_arp.dataADS:
; Bonus level arpeggio.  TODO:  Double channel, just echo this one
				db %00010000,%00000011
				db &03,&55,&dd
				db &03,&55,&ff
				db &03,&55,&ff
				db &03,&55,&ee
				db &03,&55,&dd
				
				db &03,&c0,&dd
				db &03,&c0,&ff
				db &03,&c0,&ff
				db &03,&c0,&ee
				db &03,&c0,&dd
				
				db &04,&21,&dd
				db &04,&21,&ff
				db &04,&21,&ff
				db &04,&21,&ee
				db &04,&21,&dd
				
				db &04,&84,&dd
				db &04,&84,&ff
				db &04,&84,&ff
				db &04,&84,&ee
				db &04,&84,&dd
			
				db &04,&21,&dd
				db &04,&21,&ff
				db &04,&21,&ff
				db &04,&21,&ee
				db &04,&21,&dd
				
				db &03,&c0,&dd
				db &03,&c0,&ff
				db &03,&c0,&ff
				db &03,&c0,&ee
				db &03,&c0,&dd
				
				db &03,&55,&dd
				db &03,&55,&ff
				db &03,&55,&ff
				db &03,&55,&ee
				db &03,&55,&dd
				db &03,&55,&bb
				db &03,&55,&88
				db &03,&55,&44
				
				db &03,&55,&44
				db &03,&55,&33
				db &03,&55,&22
				db &03,&55,&22
				db &03,&55,&11
				db &03,&55,&11
				
				db &03,&00,&00
				db &03,&00,&00
				db &03,&00,&00
				
				db sfx.end

sfx.bonus_arp.data2ADS:
				db %00010000,%00000011
				db &03,&00,&00
				db &03,&00,&00
				db &03,&00,&00
				
				db &03,&57,&bb
				db &03,&57,&dd
				db &03,&57,&dd
				db &03,&57,&cc
				db &03,&57,&bb
				
				db &03,&c2,&bb
				db &03,&c2,&dd
				db &03,&c2,&dd
				db &03,&c2,&cc
				db &03,&c2,&bb
				
				db &04,&23,&bb
				db &04,&23,&dd
				db &04,&23,&dd
				db &04,&23,&cc
				db &04,&23,&bb
				
				db &04,&86,&bb
				db &04,&86,&dd
				db &04,&86,&dd
				db &04,&86,&cc
				db &04,&86,&bb
			
				db &04,&23,&bb
				db &04,&23,&dd
				db &04,&23,&dd
				db &04,&23,&cc
				db &04,&23,&bb
				
				db &03,&c2,&bb
				db &03,&c2,&dd
				db &03,&c2,&dd
				db &03,&c2,&cc
				db &03,&c2,&bb
				
				db &03,&57,&bb
				db &03,&57,&dd
				db &03,&57,&dd
				db &03,&57,&cc
				db &03,&57,&bb
				db &03,&57,&99
				db &03,&57,&66
				db &03,&57,&22
				
				db &03,&57,&22
				db &03,&57,&22
				db &03,&57,&22
				db &03,&57,&22
				db &03,&57,&11
				db &03,&57,&11
				
				db sfx.end

;-------------------------------------------------------
sfx.fanfare.dataADS:
; Item interacted-with fanfare.  TODO:  Double channel
				db %00010000,%00000011
				db &04,&b9,&99
				db &04,&ba,&aa
				db &04,&bc,&ee
				db &04,&c0,&ff
				db &04,&c0,&ff
				db &04,&c0,&ff
				db &04,&c0,&ff
				db &04,&bc,&dd

				db &04,&b9,&99
				db &04,&ba,&aa
				db &04,&bc,&ee
				db &04,&c0,&ff
				db &04,&c0,&ff
				db &04,&c0,&ff
				db &04,&c0,&ff
				db &04,&c0,&ff
				db &04,&c0,&ff
				db &04,&c0,&ff
				db &04,&c0,&ff
				db &04,&c0,&ff
				db &04,&c0,&ff
				db &04,&c0,&ff
				db &04,&bc,&dd
				db &04,&ba,&aa
				
				db &03,&03,&00
				db &03,&03,&00
				db sfx.end

sfx.fanfare.data2ADS:
; 2nd channel for fanfare
				db %00010000,%00000011
				db &03,&03,&00
				db &03,&03,&00				

				db &04,&4e,&99
				db &04,&4f,&aa
				db &04,&51,&ee
				db &04,&55,&ff
				db &04,&55,&ff
				db &04,&55,&ff
				db &04,&55,&ff
				db &04,&51,&dd

				db &04,&4e,&99
				db &04,&4f,&aa
				db &04,&51,&ee
				db &04,&55,&ff
				db &04,&55,&ff
				db &04,&55,&ff
				db &04,&55,&ff
				db &04,&55,&ff
				db &04,&55,&ff
				db &04,&55,&ff
				db &04,&55,&ff
				db &04,&55,&ff
				db &04,&55,&ff
				db &04,&55,&ff
				db &04,&51,&dd
				db &04,&4f,&aa
				
				db sfx.end

;-------------------------------------------------------
sfx.click.dataADS:
; Attempt at speccy click to show button press
				db %00010100,0
				db &06,&e3,&55
				db &07,&e3,&30
				db sfx.end
				
;-------------------------------------------------------
sfx.level_complete.dataADS:
; Completed level klaxon
				db %00010000,0
				db &03,&55,&ff
				db &03,&68,&ff
				db &03,&81,&ff
				db &03,&9a,&ff
				db &03,&b3,&ff
				db &03,&cc,&ff
				db &03,&e5,&ee
				db &03,&e3,&dd
				db &03,&fe,&cc
				db &04,&05,&bb

				db &03,&55,&ff
				db &03,&68,&ff
				db &03,&81,&ff
				db &03,&9a,&ff
				db &03,&b3,&ff
				db &03,&cc,&ff
				db &03,&e5,&ee
				db &03,&e3,&dd
				db &03,&fe,&cc
				db &04,&05,&bb
				
				db &03,&55,&ff
				db &03,&68,&ff
				db &03,&81,&ff
				db &03,&9a,&ff
				db &03,&b3,&ff
				db &03,&cc,&ff
				db &03,&e5,&ee
				db &03,&e3,&dd
				db &03,&fe,&cc
				db &04,&05,&bb
				
				db &03,&55,&ff
				db &03,&68,&ff
				db &03,&81,&ff
				db &03,&9a,&ff
				db &03,&b3,&ff
				db &03,&cc,&ff
				db &03,&e5,&ee
				db &03,&e3,&dd
				db &03,&fe,&cc
				db &04,&05,&bb

				db &03,&00,&00
				db &03,&00,&00
				db sfx.end

sfx.level_complete.data2ADS:
				db %00010000,0
				db &03,&00,&00
				db &03,&00,&00
				
				db &03,&10,&ff
				db &03,&23,&ff
				db &03,&3c,&ff
				db &03,&55,&ff
				db &03,&6e,&ff
				db &03,&87,&ff
				db &03,&a0,&ee
				db &03,&b9,&dd
				db &03,&d2,&cc
				db &04,&eb,&bb

				db &03,&10,&ff
				db &03,&23,&ff
				db &03,&3c,&ff
				db &03,&55,&ff
				db &03,&6e,&ff
				db &03,&87,&ff
				db &03,&a0,&ee
				db &03,&b9,&dd
				db &03,&d2,&cc
				db &04,&eb,&bb
				
				db &03,&10,&ff
				db &03,&23,&ff
				db &03,&3c,&ff
				db &03,&55,&ff
				db &03,&6e,&ff
				db &03,&87,&ff
				db &03,&a0,&ee
				db &03,&b9,&dd
				db &03,&d2,&cc
				db &04,&eb,&bb
				
				db &03,&10,&ff
				db &03,&23,&ff
				db &03,&3c,&ff
				db &03,&55,&ff
				db &03,&6e,&ff
				db &03,&87,&ff
				db &03,&a0,&ee
				db &03,&b9,&dd
				db &03,&d2,&cc
				db &04,&eb,&66
				db sfx.end
				
;=======================================================
