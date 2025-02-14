; reset-rightmost.asm
; CSC 230: Fall 2022
;
; Code provided for Assignment #1
;
; Mike Zastre (2022-Sept-22)

; This skeleton of an assembly-language program is provided to help you
; begin with the programming task for A#1, part (b). In this and other
; files provided through the semester, you will see lines of code
; indicating "DO NOT TOUCH" sections. You are *not* to modify the
; lines within these sections. The only exceptions are for specific
; changes announced on conneX or in written permission from the course
; instructor. *** Unapproved changes could result in incorrect code
; execution during assignment evaluation, along with an assignment grade
; of zero. ****
;
; In a more positive vein, you are expected to place your code with the
; area marked "STUDENT CODE" sections.

; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
; Your task: You are to take the bit sequence stored in R16,
; and to reset the rightmost contiguous sequence of set
; by storing this new value in R25. For example, given
; the bit sequence 0b01011100, resetting the right-most
; contigous sequence of set bits will produce 0b01000000.
; As another example, given the bit sequence 0b10110110,
; the result will be 0b10110000.
;
; Your solution must work, of course, for bit sequences other
; than those provided in the example. (How does your
; algorithm handle a value with no set bits? with all set bits?)

; ANY SIGNIFICANT IDEAS YOU FIND ON THE WEB THAT HAVE HELPED
; YOU DEVELOP YOUR SOLUTION MUST BE CITED AS A COMMENT (THAT
; IS, WHAT THE IDEA IS, PLUS THE URL).

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

loop: ; rotate THEN check index
	sbrc r16,0 ; skip if bit 0 = 0
	rjmp findOnes ; branches only if bit 0 = 1

	ror r16

	dec index
	tst index ; if 0 then we are done
	breq copy

	rjmp loop

findOnes: ; rotate THEN check index
	inc numOnes
	dec index 
	sec ; set carry flag so 1 is rotated in
	ror r16

	tst index
	breq shiftZeros ; clean we have iterated through all

	sbrc r16,0 ; skip if bit 0 = 0
	rjmp findOnes ; branches only if bit 0 = 1

shiftZeros:
	lsl r16
	inc index
	dec numOnes
	tst numOnes
	breq rerotate ; if numOnes = 0 branch to rerotate
	rjmp shiftZeros

rerotate: ; check index THEN rotate
	cpi index,8 
	breq copy ; branch if index-8=0 and sets z flag

	inc index
	clc ; clear carry flag so rotate back in 0
	rol r16
	rjmp rerotate
	
copy:
	mov r25, r16
	rjmp reset_rightmost_stop


; **** END OF "STUDENT CODE" SECTION ********** 

; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
reset_rightmost_stop:
    rjmp reset_rightmost_stop


; ==== END OF "DO NOT TOUCH" SECTION ==========
