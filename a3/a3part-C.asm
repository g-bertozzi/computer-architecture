;
; a3part-C.asm
;
; Part C of assignment #3
;
;
; Student name: Grace Bertozzi
; Student ID: V01012576
; Date of completed work:
;
; **********************************
; Code provided for Assignment #3
;
; Author: Mike Zastre (2022-Nov-05)
;
; This skeleton of an assembly-language program is provided to help you 
; begin with the programming tasks for A#3. As with A#2 and A#1, there are
; "DO NOT TOUCH" sections. You are *not* to modify the lines within these
; sections. The only exceptions are for specific changes announced on
; Brightspace or in written permission from the course instruction.
; *** Unapproved changes could result in incorrect code execution
; during assignment evaluation, along with an assignment grade of zero. ***
;


; =============================================
; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
; =============================================
;
; In this "DO NOT TOUCH" section are:
; 
; (1) assembler direction setting up the interrupt-vector table
;
; (2) "includes" for the LCD display
;
; (3) some definitions of constants that may be used later in
;     the program
;
; (4) code for initial setup of the Analog-to-Digital Converter
;     (in the same manner in which it was set up for Lab #4)
;
; (5) Code for setting up three timers (timers 1, 3, and 4).
;
; After all this initial code, your own solutions's code may start
;

.cseg
.org 0
	jmp reset

; Actual .org details for this an other interrupt vectors can be
; obtained from main ATmega2560 data sheet
;
.org 0x22
	jmp timer1

; This included for completeness. Because timer3 is used to
; drive updates of the LCD display, and because LCD routines
; *cannot* be called from within an interrupt handler, we
; will need to use a polling loop for timer3.
;
; .org 0x40
;	jmp timer3

.org 0x54
	jmp timer4

.include "m2560def.inc"
.include "lcd.asm"

.cseg
#define CLOCK 16.0e6
#define DELAY1 0.01
#define DELAY3 0.1
#define DELAY4 0.5

#define BUTTON_RIGHT_MASK 0b00000001	
#define BUTTON_UP_MASK    0b00000010
#define BUTTON_DOWN_MASK  0b00000100
#define BUTTON_LEFT_MASK  0b00001000

#define BUTTON_RIGHT_ADC  0x032
#define BUTTON_UP_ADC     0x0b0   ; was 0x0c3
#define BUTTON_DOWN_ADC   0x160   ; was 0x17c
#define BUTTON_LEFT_ADC   0x22b
#define BUTTON_SELECT_ADC 0x316

.equ PRESCALE_DIV=1024   ; w.r.t. clock, CS[2:0] = 0b101

; TIMER1 is a 16-bit timer. If the Output Compare value is
; larger than what can be stored in 16 bits, then either
; the PRESCALE needs to be larger, or the DELAY has to be
; shorter, or both.
.equ TOP1=int(0.5+(CLOCK/PRESCALE_DIV*DELAY1))
.if TOP1>65535
.error "TOP1 is out of range"
.endif

; TIMER3 is a 16-bit timer. If the Output Compare value is
; larger than what can be stored in 16 bits, then either
; the PRESCALE needs to be larger, or the DELAY has to be
; shorter, or both.
.equ TOP3=int(0.5+(CLOCK/PRESCALE_DIV*DELAY3))
.if TOP3>65535
.error "TOP3 is out of range"
.endif

; TIMER4 is a 16-bit timer. If the Output Compare value is
; larger than what can be stored in 16 bits, then either
; the PRESCALE needs to be larger, or the DELAY has to be
; shorter, or both.
.equ TOP4=int(0.5+(CLOCK/PRESCALE_DIV*DELAY4))
.if TOP4>65535
.error "TOP4 is out of range"
.endif

reset:
; ***************************************************
; **** BEGINNING OF FIRST "STUDENT CODE" SECTION ****
; ***************************************************

; Anything that needs initialization before interrupts
; start must be placed here.

; symbolic names for registers
.def DATAH=r25  ;DATAH:DATAL  store 10 bits data from ADC
.def DATAL=r24
.def BOUNDARY_H=r1  ;hold high byte value of the threshold for button
.def BOUNDARY_L=r0  ;hold low byte value of the threshold for button, r1:r0

; Definitions for using the Analog to Digital Conversion
.equ ADCSRA_BTN=0x7A
.equ ADCSRB_BTN=0x7B
.equ ADMUX_BTN=0x7C
.equ ADCL_BTN=0x78
.equ ADCH_BTN=0x79

; set boundary for testing if button is pressed
ldi r16, high(900)
mov BOUNDARY_H, r16
ldi r16, low(900)
mov BOUNDARY_L, r16
clr r16

; ***************************************************
; ******* END OF FIRST "STUDENT CODE" SECTION *******
; ***************************************************

; =============================================
; ====  START OF "DO NOT TOUCH" SECTION    ====
; =============================================

	; initialize the ADC converter (which is needed
	; to read buttons on shield). Note that we'll
	; use the interrupt handler for timer 1 to
	; read the buttons (i.e., every 10 ms)
	;
	ldi temp, (1 << ADEN) | (1 << ADPS2) | (1 << ADPS1) | (1 << ADPS0)
	sts ADCSRA, temp
	ldi temp, (1 << REFS0)
	sts ADMUX, r16

	; Timer 1 is for sampling the buttons at 10 ms intervals.
	; We will use an interrupt handler for this timer.
	ldi r17, high(TOP1)
	ldi r16, low(TOP1)
	sts OCR1AH, r17
	sts OCR1AL, r16
	clr r16
	sts TCCR1A, r16
	ldi r16, (1 << WGM12) | (1 << CS12) | (1 << CS10)
	sts TCCR1B, r16
	ldi r16, (1 << OCIE1A)
	sts TIMSK1, r16

	; Timer 3 is for updating the LCD display. We are
	; *not* able to call LCD routines from within an 
	; interrupt handler, so this timer must be used
	; in a polling loop.
	ldi r17, high(TOP3)
	ldi r16, low(TOP3)
	sts OCR3AH, r17
	sts OCR3AL, r16
	clr r16
	sts TCCR3A, r16
	ldi r16, (1 << WGM32) | (1 << CS32) | (1 << CS30)
	sts TCCR3B, r16
	; Notice that the code for enabling the Timer 3
	; interrupt is missing at this point.

	; Timer 4 is for updating the contents to be displayed
	; on the top line of the LCD.
	ldi r17, high(TOP4)
	ldi r16, low(TOP4)
	sts OCR4AH, r17
	sts OCR4AL, r16
	clr r16
	sts TCCR4A, r16
	ldi r16, (1 << WGM42) | (1 << CS42) | (1 << CS40)
	sts TCCR4B, r16
	ldi r16, (1 << OCIE4A)
	sts TIMSK4, r16

	sei

; =============================================
; ====    END OF "DO NOT TOUCH" SECTION    ====
; =============================================

; ****************************************************
; **** BEGINNING OF SECOND "STUDENT CODE" SECTION ****
; ****************************************************
; clear dseg

ldi r16, ' '
sts TOP_LINE_CONTENT, r16
ldi r16, 0 
sts CURRENT_CHARSET_INDEX, r16
sts CURRENT_CHAR_INDEX, r16
sts BUTTON_IS_PRESSED, r16
sts LAST_BUTTON_PRESSED, r16

start:
	rcall lcd_init ;  call lcd_init to Initialize the LCD (line 689 in lcd.asm)
	rcall timer3

	; Part-C Initializations

	; TOP_LINE_CONTENT:  start as all spaces
	; CURRENT_CHARSET_INDEX: holds offset for AVAILABLE_CHARSET
			; 16 bytes because in part-d we will have different offsets for each column
	; CURRENT_CHAR_INDEX: columns/index number (i.e.. 0 for Part-C)		

	; initliaze CURRENT_CHAR_INDEX to 0
	;ldi r16, 0
	;sts CURRENT_CHAR_INDEX, r16

	; load TOP_LINE_CONTENT with ' ' (16 bytes)
	lds ZH, high(TOP_LINE_CONTENT)
	lds ZL, low(TOP_LINE_CONTENT)
	ldi r16, ' ' ; space char
	ldi r17, 16 ; counter

load_TLC:
	st Z+, r16 ; post op increment
	dec r17
	tst r17
	brne load_TLC

	; load CURRENT_CHARSET_INDEX with 0 (16 bytes)

	lds ZH, high(CURRENT_CHARSET_INDEX)
	lds ZL, low(CURRENT_CHARSET_INDEX)
	ldi r16, 0 ; zero
	ldi r17, 16 ; counter

load_CCI:
	st Z+, r16 ; post op increment
	dec r17
	tst r17
	brne load_CCI

stop:
	rjmp stop

timer1:
; prologue
	push DATAL
	push DATAH
	push r16 ; store adc sreg
	lds r19, SREG
	push r19 ; save sreg

	push r20 ; store BUTTON_IS_PRESSED
	push r21 ; store LAST_BUTTON_PRESSED
	push r22 ; low boundary
	push r23 ; high boundary

check_button:
	; start analogue to digital conversion by setting bit 6 of ADC status reg to 1
	lds r16, ADCSRA_BTN ; load ADC status register into r16	
	ori r16, 0b01000000 ; mask to check for zero in bit 6
	sts ADCSRA_BTN, r16 ; send back the value with bit 6 set

	wait:	; wait for conversion to complete, then check if bit 6 (i.e. ADSC bit) is set
		lds r16, ADCSRA_BTN
		andi r16, 0b01000000 ; if equal then bit 6 is set => conversion done
		brne wait

		; read the value, use XH:XL to store the 10-bit result (ADC receives 10 bit number, i.e. the converted analogue signal)
		lds DATAL, ADCL_BTN
		lds DATAH, ADCH_BTN

		clr r20 ; default value of button_is_pressed is 0
		; check if signal is greater than threshold value of 900
		cp DATAL, BOUNDARY_L
		cpc DATAH, BOUNDARY_H
		brsh skip ; higher => no button being pressed
		ldi r20, 0b00000001 ; otherwise load to indicate button is being pressed

which_button: ; PART-B CODE
		clr r21 ; store LAST_BUTTON_PRESSED

	check_r:
		ldi r22, low(BUTTON_RIGHT_ADC)
		ldi r23, high(BUTTON_RIGHT_ADC)
		cp DATAL, r22
		cpc DATAH, r23
		brsh check_u ; higher => not R
		ldi r21, BUTTON_RIGHT_MASK ; otherwise load to indicate button is being pressed
		rjmp skip

	check_u:
		ldi r22, low(BUTTON_UP_ADC)
		ldi r23, high(BUTTON_UP_ADC)
		cp DATAL, r22
		cpc DATAH, r23
		brsh check_d ; higher => not R or U
		ldi r21, BUTTON_UP_MASK
		rjmp skip

	check_d:
		ldi r22, low(BUTTON_DOWN_ADC)
		ldi r23, high(BUTTON_DOWN_ADC)
		cp DATAL, r22
		cpc DATAH, r23
		brsh check_l ; higher => not R, U or D
		ldi r21, BUTTON_DOWN_MASK
		rjmp skip

	check_l:
		ldi r22, low(BUTTON_LEFT_ADC)
		ldi r23, high(BUTTON_LEFT_ADC)
		cp DATAL, r22
		cpc DATAH, r23
		brsh skip ; higher => not R,U,D or L
		ldi r21, BUTTON_LEFT_MASK
		
	skip: ; store button pressed values in data memory (initialized in .dseg)
		sts BUTTON_IS_PRESSED, r20
		sts LAST_BUTTON_PRESSED, r21

; epilogue
	pop r23
	pop r22
	pop r21
	pop r20
	pop r19
	sts SREG, r19
	pop r16
	pop DATAH
	pop DATAL

reti

; timer3:
;
; Note: There is no "timer3" interrupt handler as you must use
; timer3 in a polling style (i.e. it is used to drive the refreshing
; of the LCD display, but LCD functions cannot be called/used from
; within an interrupt handler).

timer3: ; just a function, not an interrupt handler

	in r16, TIFR3 ; load the Timer/Counter 3 Interrupt Mask Register into general register
	sbrs r16, OCF3A ; if OCF3A is set then timer3 has reached top value
	rjmp timer3 ; if timer3 not at top, loop back

	ldi r16, (1<<OCF3A) ; set bit 1 in TIFR3
	out TIFR3, r16 ; send TIFR3 back

	; set cursor with column and row (from lab 8)
	ldi r16, 1 
	ldi r17, 15 
	push r16
	push r17
	rcall lcd_gotoxy ; updates cursor_xy using byte in stack; row = high(byte), column = low(byte)
	pop r17
	pop r16

	; check button_is_pressed value
	clr r18
	lds r18, BUTTON_IS_PRESSED ; load cur val into general
	
	cpi r18, 0b000000001 ; compare to 1
	breq set_star

; otherwise set dash & poll again
	ldi r16, '-'
	push r16
	rcall lcd_putchar
	pop r16
	rjmp timer3

set_star:
	ldi r16, '*'
	push r16
	rcall lcd_putchar
	pop r16

; PART-B CODE

	; set cursor
	ldi r16, 1 ; row 
	ldi r17, 0 ; column
	push r16
	push r17
	rcall lcd_gotoxy 
	pop r17
	pop r16

	ldi r25, ' ' ; store space char

	; check last_button_pressed value
	clr r19
	lds r19, LAST_BUTTON_PRESSED

	cpi r19, BUTTON_RIGHT_MASK
	breq set_r

	cpi r19, BUTTON_UP_MASK
	breq set_u

	cpi r19, BUTTON_DOWN_MASK
	breq set_d

	cpi r19, BUTTON_LEFT_MASK
	breq set_l

	rjmp set_topline ; if none ?

set_r:
	ldi r18, 'R'

	push r25
	rcall lcd_putchar
	pop r25

	push r25
	rcall lcd_putchar
	pop r25

	push r25
	rcall lcd_putchar
	pop r25

	push r18
	rcall lcd_putchar
	pop r18

	rjmp done_check

set_u:
	ldi r18, 'U'

	push r25
	rcall lcd_putchar
	pop r25

	push r25
	rcall lcd_putchar
	pop r25

	push r18
	rcall lcd_putchar
	pop r18

	push r25
	rcall lcd_putchar
	pop r25

	rjmp set_topline

set_d:
	ldi r18, 'D'

	push r25
	rcall lcd_putchar
	pop r25

	push r18
	rcall lcd_putchar
	pop r18

	push r25
	rcall lcd_putchar
	pop r25

	push r25
	rcall lcd_putchar
	pop r25

	rjmp set_topline

set_l:
	ldi r18, 'L'

	push r18
	rcall lcd_putchar
	pop r18

	push r25
	rcall lcd_putchar
	pop r25

	push r25
	rcall lcd_putchar
	pop r25

	push r25
	rcall lcd_putchar
	pop r25
	
	rjmp done_check

; PART-C CODE
set_topline:
	; set cursor to topline
	ldi r16, 0 ; row 
	ldi r17, 0 ; column is 0 for Part-C
	push r16
	push r17
	rcall lcd_gotoxy
	pop r17
	pop r16

	; display
	lds r16, TOP_LINE_CONTENT
	push r16
	rcall lcd_putchar
	pop r16

done_check:
	rjmp timer3

timer4:
; use values updated by timer1 (i.e BUTTON_IS_PRESSED & LAST_BUTTON_PRESSED) to update the following
	; TOPLINE_CONTENT - actual value
	; CURRENT_CHARSET_INDEX - how far into available charset we are
	; CURRENT_CHAR_INDEX - represents column value of top row

	; prologue
	push ZH
	push ZL
	push r16 ; store BUTTON_IS_PRESSED, available charset
	push r17 ; store LAST_BUTTON_PRESSED
	push r18 ; CCI
	push r19 ; TLC
	push r20 
	lds r20, SREG
	push r20

	; Z Pointer to AVAILABLE_CHARSET
	ldi ZH, high(AVAILABLE_CHARSET<<1)
	ldi ZL, low(AVAILABLE_CHARSET<<1)

	; check if button pressed
	lds r16, BUTTON_IS_PRESSED
	cpi r16, 0
	breq done_4

	; which button?
	lds r17, LAST_BUTTON_PRESSED
	cpi r17, BUTTON_UP_MASK
	breq inc_cci
	cpi r17, BUTTON_DOWN_MASK
	breq dec_cci

inc_cci: ; check if null, increment charset index r18
	lds r18, CURRENT_CHARSET_INDEX ; CURRENT_CHARSET_INDEX
	inc r18
	
	clr r24
	add ZL, r18 ; Low(available) + CCI
	adc ZH, r24 ; High(available) + empty so we can just add the carry from the previous add

	lpm r19, Z ; grab first byte at AVAILABLE_CHARSET pointer
	
	cpi r19, 0 ; check if byte is null
	breq boundary

	sts TOP_LINE_CONTENT, r19 ; store byte in top line
	sts CURRENT_CHARSET_INDEX, r18 ; store new cci
	rjmp done_4

dec_cci: ; check if 0, decrement charset index
	lds r18, CURRENT_CHARSET_INDEX ; CURRENT_CHARSET_INDEX
	tst r18 
	breq boundary ; if index is 0 => number is 0 & we can't go negative
	dec r18
	
	clr r24
	add ZL, r18 ; Low(available) + CCI
	adc ZH, r24 ; High(available) + empty so we can just add the carry from the previous add

	lpm r19, Z ; grab first byte at AVAILABLE_CHARSET pointer
	sts TOP_LINE_CONTENT, r19 ; store byte in top line
	sts CURRENT_CHARSET_INDEX, r18 ; store new cci
	rjmp done_4
	
boundary: ; reset charset index
	clr r18
	sts CURRENT_CHARSET_INDEX, r18 ; store new CCI in CCI

done_4:
	; epilogue
	pop r20
	sts SREG, r20
	pop r20
	pop r19
	pop r18
	pop r17
	pop r16
	pop ZL
	pop ZH

	reti


; ****************************************************
; ******* END OF SECOND "STUDENT CODE" SECTION *******
; ****************************************************


; =============================================
; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
; =============================================

; r17:r16 -- word 1
; r19:r18 -- word 2
; word 1 < word 2? return -1 in r25
; word 1 > word 2? return 1 in r25
; word 1 == word 2? return 0 in r25
;
compare_words:
	; if high bytes are different, look at lower bytes
	cp r17, r19
	breq compare_words_lower_byte

	; since high bytes are different, use these to
	; determine result
	;
	; if C is set from previous cp, it means r17 < r19
	; 
	; preload r25 with 1 with the assume r17 > r19
	ldi r25, 1
	brcs compare_words_is_less_than
	rjmp compare_words_exit

compare_words_is_less_than:
	ldi r25, -1
	rjmp compare_words_exit

compare_words_lower_byte:
	clr r25
	cp r16, r18
	breq compare_words_exit

	ldi r25, 1
	brcs compare_words_is_less_than  ; re-use what we already wrote...

compare_words_exit:
	ret

.cseg
AVAILABLE_CHARSET: .db "0123456789abcdef_", 0


.dseg

BUTTON_IS_PRESSED: .byte 1			; updated by timer1 interrupt, used by LCD update loop
LAST_BUTTON_PRESSED: .byte 1        ; updated by timer1 interrupt, used by LCD update loop

TOP_LINE_CONTENT: .byte 16			; updated by timer4 interrupt, used by LCD update loop
CURRENT_CHARSET_INDEX: .byte 16		; updated by timer4 interrupt, used by LCD update loop
CURRENT_CHAR_INDEX: .byte 1			; ; updated by timer4 interrupt, used by LCD update loop


; =============================================
; ======= END OF "DO NOT TOUCH" SECTION =======
; =============================================


; ***************************************************
; **** BEGINNING OF THIRD "STUDENT CODE" SECTION ****
; ***************************************************

.dseg

; If you should need additional memory for storage of state,
; then place it within the section. However, the items here
; must not be simply a way to replace or ignore the memory
; locations provided up above.


; ***************************************************
; ******* END OF THIRD "STUDENT CODE" SECTION *******
; ***************************************************
