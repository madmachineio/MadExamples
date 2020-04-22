/*
  Mission3 Push Button

  What you should see?
  The Red LED will turn on when you press the key.

  The circuit:
  - Use Button Module, and connect it to a Digital Jack. 
  - When the Arduino Sheild properly pluged in, the LED will turn on.

  created 2019
  by Orange J

  Each time the input pin goes from LOW to HIGH (e.g. because of a push-button press), the
  output pin is toggled from LOW to HIGH or HIGH to LOW. There's a minimum delay between toggles
  to debounce the circuit (i.e. to ignore noise). Try solve the issue. This example code is in the public domain.
  Visit madmachine.io for more.
*/

import SwiftIO

let led = DigitalOut(Id.RED)
let button = DigitalIn(Id.D10)	// initiate an input to the D10 pin on board.

while true {
    sleep(ms: 50)

    // read the button value and turn off the led as a signal
    if button.read() {
        led.write(false)
    } else {
        led.write(true)
    }
}
