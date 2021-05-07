/*
  Mission1 Blink RGB LED

  The blue LED will flash on for 1 second, then off for 1 second.

  The circuit:
  - Use the onboard RGB LED.
  - Note: SwiftIO have an on-board RGB LED you can control.
    The onboard LED will be on when the value is set to false.

  created 2019
  by Orange J

  Try to change the RGB Led’s color to Red, Green, and Blue. 
  Add a blinking loop and see what will happen. This example code is in the 
  public domain. Visit madmachine.io for more info.
*/

import SwiftIO

// Import the board library to use the Id of the specific board.
import SwiftIOBoard

// initialize the blue LED
let led = DigitalOut(Id.BLUE)

while true {
     // The code here will run all the time.

     // Set Blue LED off
     led.write(true)
     sleep(ms: 1000)	// Interval of LED blink (milliseconds)

     // Set Blue LED on
     led.write(false)
     sleep(ms: 1000)
}
