; *******************************
; Code provided for Assignment #2
;
; Author: Mike Zastre (2022-Oct-15)
;
 
; This skeleton of an assembly-language program is provided to help you
; begin with the programming tasks for A#2. As with A#1, there are "DO
; NOT TOUCH" sections. You are *not* to modify the lines within these
; sections. The only exceptions are for specific changes changes
; announced on Brightspace or in written permission from the course
; instructor. *** Unapproved changes could result in incorrect code
; execution during assignment evaluation, along with an assignment grade
; of zero. ****

.include "m2560def.inc"
.cseg
.org 0

; ***************************************************
; **** BEGINNING OF FIRST "STUDENT CODE" SECTION ****
; ***************************************************

	; initializion code will need to appear in this
    ; section

	; set pins of PORTS L&B as output using DDRs

	ldi r22, 0xFF

	sts DDRL, r22
	out DDRB, r22

	clr r22

	; initialize stack at top of sram i.e. RAMEND
		; use channels
	; ensure sp pointing at has correct start val 

	ldi r16, high(RAMEND)
	ldi r17, low(RAMEND)
	out SPH, r16
	out SPL, r17

; ***************************************************
; **** END OF FIRST "STUDENT CODE" SECTION **********
; ***************************************************

; ---------------------------------------------------
; ---- TESTING SECTIONS OF THE CODE -----------------
; ---- TO BE USED AS FUNCTIONS ARE COMPLETED. -------
; ---------------------------------------------------
; ---- YOU CAN SELECT WHICH TEST IS INVOKED ---------
; ---- BY MODIFY THE rjmp INSTRUCTION BELOW. --------
; -----------------------------------------------------

	rjmp test_part_d
	; Test code


test_part_a:
	ldi r16, 0b00100001
	rcall set_leds
	rcall delay_long

	clr r16
	rcall set_leds
	rcall delay_long

	ldi r16, 0b00111000
	rcall set_leds
	rcall delay_short

	clr r16
	rcall set_leds
	rcall delay_long

	ldi r16, 0b00100001
	rcall set_leds
	rcall delay_long

	clr r16
	rcall set_leds

	rjmp end


test_part_b:
	ldi r17, 0b00101010
	rcall slow_leds
	ldi r17, 0b00010101
	rcall slow_leds
	ldi r17, 0b00101010
	rcall slow_leds
	ldi r17, 0b00010101
	rcall slow_leds

	rcall delay_long
	rcall delay_long

	ldi r17, 0b00101010
	rcall fast_leds
	ldi r17, 0b00010101
	rcall fast_leds
	ldi r17, 0b00101010
	rcall fast_leds
	ldi r17, 0b00010101
	rcall fast_leds
	ldi r17, 0b00101010
	rcall fast_leds
	ldi r17, 0b00010101
	rcall fast_leds
	ldi r17, 0b00101010
	rcall fast_leds
	ldi r17, 0b00010101
	rcall fast_leds

	rjmp end

test_part_c:
	ldi r16, 0b11111000
	push r16
	rcall leds_with_speed
	pop r16

	ldi r16, 0b11011100
	push r16
	rcall leds_with_speed
	pop r16

	ldi r20, 0b00100000
test_part_c_loop:
	push r20
	rcall leds_with_speed
	pop r20
	lsr r20
	brne test_part_c_loop

	rjmp end


test_part_d:
	ldi r21, 'E'
	push r21
	rcall encode_letter
	pop r21
	push r25
	rcall leds_with_speed
	pop r25

	rcall delay_long

	ldi r21, 'A'
	push r21
	rcall encode_letter
	pop r21
	push r25
	rcall leds_with_speed
	pop r25

	rcall delay_long


	ldi r21, 'M'
	push r21
	rcall encode_letter
	pop r21
	push r25
	rcall leds_with_speed
	pop r25

	rcall delay_long

	ldi r21, 'H'
	push r21
	rcall encode_letter
	pop r21
	push r25
	rcall leds_with_speed
	pop r25

	rcall delay_long

	rjmp end


test_part_e:
	ldi r25, HIGH(WORD02 << 1)
	ldi r24, LOW(WORD02 << 1)
	rcall display_message
	rjmp end

end:
    rjmp end






; ****************************************************
; **** BEGINNING OF SECOND "STUDENT CODE" SECTION ****
; ****************************************************

set_leds:

	; input is r16 containing 0b00******
	; parse through relevant bits and update masks for PortB and PortL
	; let r22 be maskB and r23 be maskL

	clr r22 ; ensure registers are clear
	clr r23

	sbrc r16, 5 ; related to bit 1 of PORTB- B1
	ori r22, 0b00000010 ; A or 1 = 1, mask & operation force relevant bits to true

	sbrc r16, 4 ; related to B3
	ori r22, 0b00001000

	sbrc r16, 3 ; related to bit 1 of PORTL- L1
	ori r23, 0b00000010 

	sbrc r16, 2 ; related to L3
	ori r23, 0b00001000

	sbrc r16, 1 ; related to L5
	ori r23, 0b00100000

	sbrc r16, 0 ; related to L7
	ori r23, 0b10000000

	out PORTB, r22
	sts PORTL, r23

	ret


slow_leds:
	; turn on leds- copy contents of input r17 to r16 bc that's input reg for set_leds
	mov r16, r17 
	rcall set_leds

	rcall delay_long ; keep on for 1 second

	; turn off leds- load r16 with 0x00 and call set_leds
	clr r16
	rcall set_leds

	ret

fast_leds:
	; turn on leds- copy contents of input r17 to r16 bc that's input reg for set_leds
	mov r16, r17 
	rcall set_leds

	rcall delay_short ; keep on for 1/4 second

	; turn off leds- load r16 with 0x00 and call set_leds
	clr r16
	rcall set_leds

	ret

leds_with_speed:
	; input- one byte pushed onto stack

	; save the registers in use before
	push YL
	push YH
	push r17

	; load SP into Y i.e. set Y to top of stack
	in YL, SPL
	in YH, SPH

	; use displaced pointer Y to access the pushed byte,
		; displace by 7 because initial + 3 pushed + 3 ret addr

	ldd r17, Y+7 ; load into r17 bc it's the input register for fast & slow_leds

	; check if first two bits are set (only two cases are 11 or 00)
	sbrc r17, 7

	rcall slow_leds ; first bit is set

	rcall fast_leds ; first bit is clear

	; pop off any saved registers on top of return addr
	pop r17
	pop YH
	pop YL

	ret 

; Note -- this function will only ever be tested
; with upper-case letters, but it is a good idea
; to anticipate some errors when programming (i.e. by
; accidentally putting in lower-case letters). Therefore
; the loop does explicitly check if the hyphen/dash occurs,
; in which case it terminates with a code not found
; for any legal letter.

encode_letter:
; input: one byte pushed onto stack- ascii reprsentation of single char
; output; store the encoded value in r25

; save relevant registers
	push r19 ; letter of pattern
	push r20 ; input value
	push r21 ; store mask
	push r22 ; cur char of pattern 
	push ZL
	push ZH

	clr r25
	ldi r21, 0b0100000 ; mask A or 0 (bits 0-5) mask-> shows where char is set

; load SP into Z
	in ZL, SPL
	in ZH, SPH
	
; read input value into r20
	ldd r20, Z+10 ; displace = 10 = intial + 6 saved + 3 ret addrs

; find first pattern (remember word vs byte addressing)
	ldi ZL, low(PATTERNS<<1)
	ldi ZH, high(PATTERNS<<1)

	find:
		lpm r19, Z ; read first byte of Z (i.e. cur pattern) into r19
		cp r20, r19 ; compare input with pattern
		breq encode ; if equal branch
	
	; else, keep looking
		adiw Z,8 ; increment Z by 8 to reach next pattern (WORD ADDRESSING!!)
		rjmp find

	encode:
		; if bit 0 of pattern char is clear then ".", else "o"
		; . = 0b 0010 1110 => 0 = off
		; o = 0b 0110 1111 => 1 = on

		lpm r22, Z+ ; load letter in order to increment Z
		lpm r22, Z ; load next char of pattern

		make:
			sbrc r22, 0 ; bit 0 = 0 => "." i.e. 0
			or r25, r21 ; bit 0 = 1 => "o" i.e. 1, load r25 with A or 0

			; rotate mask, increment & load Z
			lsr r21
			tst r21 ; if mask is 0 => done
			breq speed
			rjmp encode

	speed:
		lpm r22, Z+ ; load letter in order to increment Z
		lpm r22, Z ; load speed of pattern

		sbrc r22, 0 ; bit 0 = 1 => char = 1 =>
		sbr r25, 0b11000000 ;  SLOW  => 0b 11** *****

; pop saved registers
	pop ZH
	pop ZL
	pop r22
	pop r21
	pop r20
	pop r19

	ret

display_message:
; input: byte address of message (low byte in r24, high byte in r25)

	; save relevant registers
	push ZL
	push ZH
	push r18 ; storage for cur char
	
	; load Z with byte addrs
	mov ZL, r24
	mov ZH, r25

	parse:
		lpm r18, Z+ ; read first byte of Z (i.e. cur message) into r19 and increment

		tst r18
		breq unsave ; if char = 0 we are done

		push r18 ; push onto stack as parameter
		call encode_letter ; returns value in r25
		pop r18

		push r25 ; push onto stack as parameter
		call leds_with_speed 
		pop r25

		call delay_short ; delay between chars

		rjmp parse

unsave:
	pop r18
	pop ZH
	pop ZL

	ret


; ****************************************************
; **** END OF SECOND "STUDENT CODE" SECTION **********
; ****************************************************




; =============================================
; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
; =============================================

; about one second
delay_long:
	push r16

	ldi r16, 14
delay_long_loop:
	rcall delay
	dec r16
	brne delay_long_loop

	pop r16
	ret


; about 0.25 of a second
delay_short:
	push r16

	ldi r16, 4
delay_short_loop:
	rcall delay
	dec r16
	brne delay_short_loop

	pop r16
	ret

; When wanting about a 1/5th of a second delay, all other
; code must call this function
;
delay:
	rcall delay_busywait
	ret


; This function is ONLY called from "delay", and
; never directly from other code. Really this is
; nothing other than a specially-tuned triply-nested
; loop. It provides the delay it does by virtue of
; running on a mega2560 processor.
;
delay_busywait:
	push r16
	push r17
	push r18

	ldi r16, 0x08
delay_busywait_loop1:
	dec r16
	breq delay_busywait_exit

	ldi r17, 0xff
delay_busywait_loop2:
	dec r17
	breq delay_busywait_loop1

	ldi r18, 0xff
delay_busywait_loop3:
	dec r18
	breq delay_busywait_loop2
	rjmp delay_busywait_loop3

delay_busywait_exit:
	pop r18
	pop r17
	pop r16
	ret


; Some tables
;.cseg
;.org 0x600

PATTERNS:
	; LED pattern shown from left to right: "." means off, "o" means
    ; on, 1 means long/slow, while 2 means short/fast.
	.db "A", "..oo..", 1
	.db "B", ".o..o.", 2
	.db "C", "o.o...", 1
	.db "D", ".....o", 1
	.db "E", "oooooo", 1
	.db "F", ".oooo.", 2
	.db "G", "oo..oo", 2
	.db "H", "..oo..", 2
	.db "I", ".o..o.", 1
	.db "J", ".....o", 2
	.db "K", "....oo", 2
	.db "L", "o.o.o.", 1
	.db "M", "oooooo", 2
	.db "N", "oo....", 1
	.db "O", ".oooo.", 1
	.db "P", "o.oo.o", 1
	.db "Q", "o.oo.o", 2
	.db "R", "oo..oo", 1
	.db "S", "....oo", 1
	.db "T", "..oo..", 1
	.db "U", "o.....", 1
	.db "V", "o.o.o.", 2
	.db "W", "o.o...", 2
	.db "X", "oo....", 2 ; correction from W to X
	.db "Y", "..oo..", 2
	.db "Z", "o.....", 2
	.db "-", "o...oo", 1   ; Just in case!

WORD00: .db "HELLOWORLD", 0, 0
WORD01: .db "THE", 0
WORD02: .db "QUICK", 0
WORD03: .db "BROWN", 0
WORD04: .db "FOX", 0
WORD05: .db "JUMPED", 0, 0
WORD06: .db "OVER", 0, 0
WORD07: .db "THE", 0
WORD08: .db "LAZY", 0, 0
WORD09: .db "DOG", 0

; =======================================
; ==== END OF "DO NOT TOUCH" SECTION ====
; =======================================

