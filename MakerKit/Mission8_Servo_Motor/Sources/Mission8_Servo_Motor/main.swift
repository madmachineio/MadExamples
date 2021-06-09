/*
  Mission8 Servo Motor

  Turn the potentiometer and the angle of servo arm will change.

  The circuit:
  - Use Potentiometer Module and connect it to an Analog Jack.
  - Most servo motors have the following three connections: 
    Black/Brown ground wire. 
    Red power wire (around 3.3V). 
    Yellow or White PWM wire.
  - In this mission, we will connect the power and ground pins directly to the SwiftIO 3.3V and GND pins. 
  - The PWM input will be connected to one of the SwiftIO's digital output pins.

  created 2019
  by Orange J

  Try to change the servo's movement to an opposite way.
  Or, use a light sensor instead of the potentiometer. Then you reads how much light is present! 
  This example code is in the public domain.
  Visit madmachine.io for more info.
*/

import SwiftIO

// Import the board library to use the Id of the specific board.
import SwiftIOBoard

let a0 = AnalogIn(Id.A0) // Initialize the analog pin.

// Each cycle of the signal lasts for 20 milliseconds.
// The pulse should last between 0.5 and 2.5 milliseconds to activate the servo.
// With a 0.5ms pulse, the servo will turn to 0 degrees and with a 2.5ms pulse, it will at 180 degrees.
// In between, it is at an angle between 0–180.
let servo = PWMOut(Id.PWM4A)

while true {
    let value = a0.readPercent() // Read the analog value and return a value between 0.0 and 1.0.
    let pulse = Int(500 + 2000 * value) // Calculate the value to get the pulse duration.
    servo.set(period: 20000, pulse: pulse) // Set the servo position according to the scaled value.

    sleep(ms: 20)
}

