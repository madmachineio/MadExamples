/*
  Mission4 potentiometer & RGB LED

  The LED blinks faster or slower in accordance with the potentiometer.

  The circuit:
  - Use Potentiometer Module, and connect it to an Analog Jack.
  - When the Arduino Sheild is properly plugged in, the LED will be turned on.

  created 2019
  by Orange J

  Try to use photoresistance to change the color of RGB LED.
  This example code is in the public domain.
  Visit madmachine.io for more info.
*/

import SwiftIO

// Import the board library to use the Id of the specific board.
import SwiftIOBoard

let a0 = AnalogIn(Id.A0) // Initialize an AnalogIn pin A0.
let led = DigitalOut(Id.RED) // Initialize the red onboard led.

while true {
    // Return the percentage of the voltage in the range of 0.0 to 1.0.
    let value = a0.readPercent()
    led.toggle()

    // Stop the program for a certain period based on the value to keep current led state.
    sleep(ms: Int(value*500))
}
