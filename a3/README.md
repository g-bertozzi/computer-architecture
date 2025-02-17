Arduino Interrupts and LCD Panel - Assignment 3 

The assignment is broken into four parts:

1. **Part A: Button Press Detection**  
   - Detect and display whether a button is pressed on the LCD screen using a timer interrupt.

2. **Part B: Button Identification**  
   - Display which of the four directional buttons (left, up, down, right) is pressed or the last button pressed.

3. **Part C: Hexadecimal Digit Control**  
   - Use the "up" and "down" buttons to adjust a hexadecimal digit displayed in the top-left corner of the LCD screen.

4. **Part D: Multiple Hexadecimal Digit Control**  
   - Extend Part C functionality to allow the "left" and "right" buttons to move the cursor across the top row of the LCD screen and set other hexadecimal digits.

Key Features

- **Timers & Interrupts**:  
  The solution utilizes multiple timers (Timer1, Timer3, and Timer4) to handle button presses, detect user input, and update the LCD display at specified intervals.

- **LCD Display**:  
  The LCD is used to show the state of the buttons and the hexadecimal digits being controlled. The display updates periodically based on the timer interrupts.

- **Button Debouncing**:  
  The solution uses a timer-based polling technique to avoid button "bouncing" issues and detect button presses accurately.

## Files

- `a3part-A.asm`: Code for detecting button presses and displaying the state on the LCD.
- `a3part-B.asm`: Code for identifying and displaying the pressed button.
- `a3part-C.asm`: Code for setting and adjusting a hexadecimal digit on the LCD using the "up" and "down" buttons.
- `a3part-D.asm`: Code for controlling multiple hexadecimal digits across the top row of the LCD using the "left" and "right" buttons.
