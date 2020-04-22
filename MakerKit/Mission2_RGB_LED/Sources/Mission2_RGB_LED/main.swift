/*
  Mission2 RGB LED Control

  What you should see?
  You should see the Red Green Blue LED blink one by one. The delay between each flash is 1s.

  The circuit:
  - Connect the anode (long leg) of each LED to digital pins D16, D17 and D18 (via a 1000-ohm resistor).   
  - Connect the cathodes (short leg) to the SwiftIO’s ground.

  created 2019
  by Orange J

  Add more LEDs to your circuit. Don’t forget the current-limiting resistors. 
  You will need to declare the new pins in your code and set them all to OUTPUT. 
  Try simulating traffic light logic. This example code is in the public domain. 
  Visit madmachine.io for more.
*/

import SwiftIO


// Variables will change
let red = DigitalOut(Id.D16)
let green = DigitalOut(Id.D17)
let blue = DigitalOut(Id.D18)

while true {
    // red on for 1 second, then off
    red.write(true)
    sleep(ms: 1000)
    red.write(false)

    // green on for 1 second, then off      
    green.write(true)
    sleep(ms: 1000)
    green.write(false)

    // blue on for 1 second, then off        
    blue.write(true)
    sleep(ms: 1000)
    blue.write(false)
}