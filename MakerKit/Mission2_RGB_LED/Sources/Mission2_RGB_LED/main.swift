/*
  Mission2 RGB LED Control

  The Red, Green and Blue LED blink one by one. The delay between each flash is 1s.

  The circuit:
  - Connect the anode (long leg) of each LED to digital pins D16, D17 and D18 (via a 330 ohm resistor).
  - Connect the cathodes (short leg) to the SwiftIO’s ground.

  created 2019
  by Orange J

  Add more LEDs to your circuit. Don’t forget the current-limiting resistors. 
  You will need to declare the new pins in your code and set them all to OUTPUT. 
  Try to simulate traffic light logic. This example code is in the public domain. 
  Visit madmachine.io for more info.
*/

import SwiftIO

// Import the board library to use the Id of the specific board.
import SwiftIOBoard

// Initialize three LEDs.
let red = DigitalOut(Id.D16)
let green = DigitalOut(Id.D17)
let blue = DigitalOut(Id.D18)

while true {
    // Turn on red LED for 1 second, then off.
    red.write(true)
    sleep(ms: 1000)
    red.write(false)

    // Turn on green LED for 1 second, then off.
    green.write(true)
    sleep(ms: 1000)
    green.write(false)

    // Turn on blue LED for 1 second, then off.
    blue.write(true)
    sleep(ms: 1000)
    blue.write(false)
}