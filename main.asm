;
; partbdraft.asm
;
; Created: 2/18/2024 6:38:22 PM
; Author : catherinebertozzi
;


; Replace with your application code

  .cseg
    .org 0

; ==== END OF "DO NOT TOUCH" SECTION ==========
	
	; THE RESULT **MUST** END UP IN R25

; **** BEGINNING OF "STUDENT CODE" SECTION **** 

	ldi r16, 0b01011100
	;ldi r16, 0b01011101
	;ldi r16, 0b01000111
	;ldi r16, 0b10000000
	;ldi r16, 0b10010000
	;ldi r16, 0b00000000

; Your solution here.

	.def numOnes = r17
	.def index = r18
	
	clr r17
	ldi r18,8 ; set index to 8 


loop:
	sbrc r16,0 ; skip is 0
	rjmp group

	lsr r16

	dec index
	tst index
	breq shift

	rjmp loop

group:
	dec index
	lsr r16

	tst index
	breq shift

	sbrc r16,0
	rjmp group

shift:
	cpi index,8
	breq done

	inc index
	lsr r16

done:
	mov r25,r16
	rjmp reset_rightmost_stop

reset_rightmost_stop:
    rjmp reset_rightmost_stop
