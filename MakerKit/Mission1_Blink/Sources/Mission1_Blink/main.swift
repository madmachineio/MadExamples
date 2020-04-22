/*
  Mission1 Blinking RGB LED

  What you should see?
  The LED will flash on for 1 second, then off for 1 second. The color is blue.

  The circuit:
  - Use the onboard RGB LED.
  - Note: SwiftIO have an on-board RGB LED you can control.

  created 2019
  by Orange J

  Try changing the RGB Led’s color to Red, Green, and Blue. 
  Add a blinking loop and see what will happen. This example code is in the 
  public domain. Visit madmachine.io for more.
*/

import SwiftIO


// initiate the blue LED and set led as Blue:
let led = DigitalOut(Id.BLUE)

while true {
     // here is where you'd put code that needs to be running all the time.

     // set Blue LED off
     led.write(true)
     sleep(ms: 1000)	// interval at which to blink (milliseconds)

     // set Blue LED on
     led.write(false)
     sleep(ms: 1000)
}
