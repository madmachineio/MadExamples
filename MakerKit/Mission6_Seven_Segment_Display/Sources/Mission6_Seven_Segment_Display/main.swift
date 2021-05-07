/*
  Mission6 7-Segment Display

  You should see a number "6" on the 7-segment display.

  The circuit:
  - Connect the 7-segment display into the Arduino Sheild.
  - Note: 7-segment display consists of 7 LEDs, called segments, arranged in the shape of an “8”. 
    Most 7-segment displays actually have 8 segments, with a dot on the right side of the digit 
    that serves as a decimal point.

  created 2019
  by Orange J

  Try to show characters like “H” “E” “L” “L” “O” on it. 
  This example code is in the public domain.
  Visit madmachine.io for more info.
*/

import SwiftIO

// Import the board library to use the Id of the specific board.
import SwiftIOBoard

let number = 6
let sevenSeg = SevenSegment()

while true {
    sevenSeg.print(number)

}
