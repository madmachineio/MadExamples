/*
  Mission3 Push Button

  The Red LED will be turned on when you press the button.

  The circuit:
  - Use Button Module, and connect it to a Digital Jack. 
  - When the Arduino Sheild is properly plugged in, the LED will be on.

  created 2019
  by Orange J

  Each time the input pin goes from LOW to HIGH (e.g. because of a push-button press), the
  output pin is toggled from LOW to HIGH or HIGH to LOW. There's a minimum delay between toggles
  to debounce the circuit (i.e. to ignore noise). Try solve the issue. This example code is in the public domain.
  Visit madmachine.io for more info.
*/

import SwiftIO


let led = DigitalOut(Id.RED) // Initialize the red onboard led.
let button = DigitalIn(Id.D10) // Initialize an input pin D10 on board.

while true {

    // Read the button value. If it is pressed, turn on the led.
    if button.read() {
        led.write(false)
    } else {
        led.write(true)
    }
}
