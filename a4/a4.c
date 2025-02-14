/* a4.c
 * CSC Fall 2022
 * 
 * Student name: Grace Bertozzi
 * Student UVic ID: V01012576
 * Date of completed work:
 *
 *
 * Code provided for Assignment #4
 *
 * Author: Mike Zastre (2022-Nov-22)
 *
 * This skeleton of a C language program is provided to help you
 * begin the programming tasks for A#4. As with the previous
 * assignments, there are "DO NOT TOUCH" sections. You are *not* to
 * modify the lines within these section.
 *
 * You are also NOT to introduce any new program-or file-scope
 * variables (i.e., ALL of your variables must be local variables).
 * YOU MAY, however, read from and write to the existing program- and
 * file-scope variables. Note: "global" variables are program-
 * and file-scope variables.
 *
 * UNAPPROVED CHANGES to "DO NOT TOUCH" sections could result in
 * either incorrect code execution during assignment evaluation, or
 * perhaps even code that cannot be compiled.  The resulting mark may
 * be zero.
 */


/* =============================================
 * ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
 * =============================================
 */

#define __DELAY_BACKWARD_COMPATIBLE__ 1
#define F_CPU 16000000UL

#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>

#define DELAY1 0.000001
#define DELAY3 0.01

#define PRESCALE_DIV1 8
#define PRESCALE_DIV3 64
#define TOP1 ((int)(0.5 + (F_CPU/PRESCALE_DIV1*DELAY1))) 
#define TOP3 ((int)(0.5 + (F_CPU/PRESCALE_DIV3*DELAY3)))

#define PWM_PERIOD ((long int)500)

volatile long int count = 0;
volatile long int slow_count = 0;


ISR(TIMER1_COMPA_vect) {
	count++;
}


ISR(TIMER3_COMPA_vect) {
	slow_count += 5;
}

/* =======================================
 * ==== END OF "DO NOT TOUCH" SECTION ====
 * =======================================
 */


/* *********************************************
 * **** BEGINNING OF "STUDENT CODE" SECTION ****
 * *********************************************
 */


/* set pins of PORT L as output using DDRL
check if 0 => off or non-0 => on
*/
void led_state(uint8_t LED, uint8_t state) {
	DDRL = 0xFF;

	switch (state) {
		case 0: /* state = 0, i.e. turn led off */
		switch (LED) {
			case 3:
			PORTL &= ~(0b00000010); /* led 4 = bit 1L */
			break;
			case 2:
			PORTL &= ~(0b00001000); /* led 2 = bit 3L */
			break;
			case 1:
			PORTL &= ~(0b00100000); /* led 1 = bit 5L */
			break;
			case 0:
			PORTL &= ~(0b10000000); /* led 0 = bit 7L */
			break;
		}
		break;

		default: /* state = 1, i.e. turn led on */
		switch (LED) {
			case 3:
			PORTL |= 0b00000010; /* led 4 = bit 1L */
			break;
			case 2:
			PORTL |=  0b00001000; /* led 2 = bit 3L */
			break;
			case 1:
			PORTL |=  0b00100000; /* led 1 = bit 5L */
			break;
			case 0:
			PORTL |=  0b10000000; /* led 0 = bit 7L */
			break;
		}
		break;
	}
}


void SOS() {
	/* light patterns; 0x1 = 1 on, 0xff = all on, 0 = all off */
	uint8_t light[] = {
		0x1, 0, 0x1, 0, 0x1, 0,
		0xf, 0, 0xf, 0, 0xf, 0,
		0x1, 0, 0x1, 0, 0x1, 0,
		0x0
	};

	int duration[] = {
		100, 250, 100, 250, 100, 500,
		250, 250, 250, 250, 250, 500,
		100, 250, 100, 250, 100, 250,
		250
	};

	int length = 19;

	/* loop through light to check pattern */
	for (int i = 0 ; i < length ; i++) {
		/*int cur = light[i];*/

		if (light[i] == 0x1) { /* cur = dot */
			led_state(0,1); /* set bit 0 on, others off */
			
			_delay_ms(duration[i]); /* cur duration from array */
		}
		
		else if (light[i] == 0xf) { /* cur = dash */
			
			/* set all leds on */
			led_state(0,1);
			led_state(1,1);
			led_state(2,1);
			led_state(3,1);

			_delay_ms(duration[i]); /* cur duration from array */
		}

		else { /* cur = 0, turn off all*/
			led_state(0,0);
			led_state(1,0);
			led_state(2,0);
			led_state(3,0);

			_delay_ms(duration[i]); /* cur duration from array */
		}
	}
}


void glow(uint8_t LED, float brightness) {
	
	count = 0;

	float threshold = PWM_PERIOD * brightness; /* "duty cycle" i.e. proportionate on time */

	for (;;) { /*do forever*/
		/* count < threshold -> should be on */
		if (count < threshold) {
			led_state(LED, 1);
		}
		/* count < PWM_PERIOD -> should be off */
		else if (count < PWM_PERIOD) {
			led_state(LED, 0);
		}
		/* count > PWM_PERIOD -> led should be on & count reset */
		else {
			count = 0;
			led_state(LED, 1);
		}
	}
}


void pulse_glow(uint8_t LED) {

	int stateOne = 1; /* starts as bright */
	int stateTwo = 0; /* starts as dim */

	for (;;) { /*do forever*/
		
		/* clear counts */
		slow_count = 0;
		count = 0;
		
		/* increment threshold based on timer using slow_count */
		for (float threshold = 0.0 ; threshold < PWM_PERIOD ; threshold = (0.1)*(slow_count)) {
			
			if (count < threshold) {
				led_state(LED, stateOne);
			}
			else if (count < PWM_PERIOD) {
				led_state(LED, stateTwo);
			}
			else {
				count = 0;
				led_state(LED, stateOne);
			}
		}

		/* swap states */
		int temp = stateOne;
		stateOne = stateTwo;
		stateTwo = temp;
	}
}

void light_show() {

	uint8_t light[] = {
		0xF, 0, 0xF, 0, 0xF, 0, /* slow */
		0x6, 0, 0x9, 0, 0xF, /* FAST */
		0, 0xF, 0 , 0xF, 0, /* slow */
		0x9, 0x6, 0, 
		0x8, 0xC, 0x6, 0x3, 0x1, 0x3, 0x6, 0xC, /* 1 traverse */
		0x8, 0xC, 0x6, 0x3, 0x1, 0x3, 0x6,
		0, 0x9, 0, 0x9, 0, 0x6, 0, 0x6,
		0x0
	};

	int duration[] = {
		500, 500, 500, 500, 500, 500, /*6*/
		100, 100, 100, 100, 100, /*5*/
		500, 500, 500, 500, 500, /*5*/
		250, 250, 250, /*3*/
		100, 100, 100, 100, 100, 100, 100, 100, /*8*/
		100, 100, 100, 100, 100, 100, 100, /*7*/
		250, 250, 250, 250, 250, 250, 250, 250, /*8*/
		500 /*1 => total = 43*/
	};
	
	int length = 43;
	
	/* loop through light to check pattern */
	/* I am hungry and so i give up :) */
	
	
}


/* ***************************************************
 * **** END OF FIRST "STUDENT CODE" SECTION **********
 * ***************************************************
 */


/* =============================================
 * ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
 * =============================================
 */

int main() {
    /* Turn off global interrupts while setting up timers. */

	cli();

	/* Set up timer 1, i.e., an interrupt every 1 microsecond. */
	OCR1A = TOP1;
	TCCR1A = 0;
	TCCR1B = 0;
	TCCR1B |= (1 << WGM12);
    /* Next two lines provide a prescaler value of 8. */
	TCCR1B |= (1 << CS11);
	TCCR1B |= (1 << CS10);
	TIMSK1 |= (1 << OCIE1A);

	/* Set up timer 3, i.e., an interrupt every 10 milliseconds. */
	OCR3A = TOP3;
	TCCR3A = 0;
	TCCR3B = 0;
	TCCR3B |= (1 << WGM32);
    /* Next line provides a prescaler value of 64. */
	TCCR3B |= (1 << CS31);
	TIMSK3 |= (1 << OCIE3A);


	/* Turn on global interrupts */
	sei();

/* =======================================
 * ==== END OF "DO NOT TOUCH" SECTION ====
 * =======================================
 */


/* *********************************************
 * **** BEGINNING OF "STUDENT CODE" SECTION ****
 * *********************************************
 */

/* This code could be used to test your work for part A. 

	led_state(0, 1);
	_delay_ms(1000);
	led_state(2, 1);
	_delay_ms(1000);
	led_state(1, 1);
	_delay_ms(1000);
	led_state(2, 0);
	_delay_ms(1000);
	led_state(0, 0);
	_delay_ms(1000);
	led_state(1, 0);
	_delay_ms(1000);
 */

/* This code could be used to test your work for part B.

	SOS();
 */

/* This code could be used to test your work for part C. 

	glow(2, .09);
 
*/


/* This code could be used to test your work for part D.

	pulse_glow(3);
 
*/

/* This code could be used to test your work for the bonus part.

	light_show();
 */

/* ****************************************************
 * **** END OF SECOND "STUDENT CODE" SECTION **********
 * ****************************************************
 */
}
