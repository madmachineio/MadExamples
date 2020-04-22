/*
  Mission4 potentiometer & RGB LED

  What you should see?
  You should see the LED blink faster or slower in accordance with the potentiometer.

  The circuit:
  - Use Potentiometer Module, and connect it to an Analog Jack.
  - When the Arduino Sheild properly pluged in, the LED will turn on.

  created 2019
  by Orange J

  Try using photoresistance to have your RGB LED change between multiple
  colors. This example code is in the public domain.
  Visit madmachine.io for more.
*/

import SwiftIO

let a0 = AnalogIn(Id.A0)		// initialize an AnalogIn to Id.A0
let led = DigitalOut(Id.RED)

while true {
    // returns the percentage of the referenced voltage in the range of 0.0 to 1.0.
    let value = a0.readPercent()
    led.toggle()

    // stop the program for <ms: value> milliseconds:
    sleep(ms: Int(value*500))
}
