Computer Architecture and Assembly Language - Assignment 2

Objectives
- Implement functions to control LEDs on the Arduino Mega 2560.
- Encode each letter of a message into a pattern of LEDs with specific durations.
- Develop assembly functions for controlling LED states, handling timing, and encoding letters.

Key Functions Implemented
1. **set_leds**: Controls which LEDs are on or off based on a passed byte value.
2. **fast_leds**: Turns on LEDs for a short duration (about 0.25 seconds).
3. **slow_leds**: Turns on LEDs for a longer duration (about 1 second).
4. **leds_with_speed**: Adjusts the LED duration based on the top two bits of the passed byte.
5. **encode_letter**: Encodes a single letter into an LED pattern with the appropriate duration.
6. **display_message**: Displays an entire message by encoding each letter and controlling the LEDs accordingly.

Usage
- The program takes a message in uppercase letters (no spaces) and displays it using LED patterns.
- Each letter is encoded using a predefined pattern with a specified duration for the LEDs.
