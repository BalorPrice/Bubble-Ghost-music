;-------------------------------------------------------
; JUMP ROUTINES

; Routines that sit under the screen/s live here - originally used to page in new pages and jump to them.
; In this case, just print the VU bars directly to the screen

;-------------------------------------------------------
jump.prep:
; Move jump routines under screen
	@move_routines:										; Move module beneath this screen
				ld hl,jump.src
				ld de,int.end
				ld bc,jump.len
				ldir
				ret
				
;-------------------------------------------------------

jump.src:
;=======================================================
				org int.end
jump.start:

				ds &40
jump.stack:

			if defined (DEBUG)
				nop
			endif

;-------------------------------------------------------
jump.print_bars:
; Make volume bars for the music.  Sits under screen as needs to take data from the music page
	@paging:											; Page in music data to upper memory
				ld ( @+rest_sp + 1),sp
				ld sp,jump.stack
				in a,(HMPR)
				ld ( @+rest_hi + 1),a
				ld a,MusicPage
				out (HMPR),a
				
				
@left:
				ld hl,music.table + &8000				; Music normally in lower memory so add 32768
				ld de,&3010
				ld b,6									; Loop through volume data
	@loop:
				push bc
				ld a,(hl)
				and &0f									; Left data in lower nibble
				call @print_barADE
				inc hl
				for 4, inc de
				pop bc
				djnz @-loop
@right:													; Repeat for right speaker
				ld hl,music.table + &8000
				ld de,&3058
				ld b,6
	@loop:
				push bc
				ld a,(hl)
				for 4,srl a
				call @print_barADE
				inc hl
				for 4, inc de
				pop bc
				djnz @-loop

	@paging:
		@rest_hi: ld a,0
				out (HMPR),a
		@rest_sp: ld sp,0
				ret


				
@print_barADE:											; Print this power bar
				push bc
				push de
				push hl
				ex de,hl
				
				ld e,15									; Loop for 15 volumes
	@loop:
				cp e									; If A bigger than this volume then print, otherwise clear it
				jr c,@+clear
		@print:
				ld (hl),&11
				inc l
				ld (hl),&11
				inc l
				ld (hl),&11
				jp @+next
		@clear:
				ld (hl),&22
				inc l
				ld (hl),&22
				inc l
				ld (hl),&22
		@next:
				ld bc,&80 - 2
				add hl,bc
				dec e
				jp nz,@-loop
				
				ex de,hl
				pop hl
				pop de
				pop bc
				ret

;-------------------------------------------------------
jump.end:
jump.len:		equ jump.end - jump.start
				org jump.src + jump.len
;=======================================================
