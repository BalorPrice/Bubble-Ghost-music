;-------------------------------------------------------
; MATHS ROUTINES

;-------------------------------------------------------
maths.multADE:
; Input: A = Multiplier, DE = Multiplicand
; Output: A:HL = Product
				ld hl,0
				ld c,0

				add	a
				jr nc,@+skip
				ld h,d
				ld l,e
	@skip:

	@loop: equ for 6
				add hl,hl
				rla
				jr nc,$+4
				add hl,de
				adc c
	next @loop
				add hl,hl
				rla
				ret nc
				add hl,de
				adc c
				ret

;-------------------------------------------------------
; Pseudo-random number generator - by Jon Ritman, Simon Brattel, Neil Mottershead
maths.seed:		dm "WUB!"

maths.rand:				
				ld hl,(maths.seed + 2)
				ld d,l
				add hl,hl
				add hl,hl
				ld c,h
				ld hl,(maths.seed)
				ld b,h
				rl b
				ld e,h
				rl e
				rl d
				add hl,bc
				ld (maths.seed),hl
				ld hl,(maths.seed + 2)
				adc hl,de
				res 7,h
				ld (maths.seed + 2),hl
				jp m,@+skip
				ld hl,maths.seed
	@loop:
				inc (hl)
				inc hl
				jp z,@-loop
	@skip:	
				ld hl,(maths.seed)
				ret

;-------------------------------------------------------
