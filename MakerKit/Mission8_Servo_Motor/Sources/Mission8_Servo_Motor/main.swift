/*
  Mission8 Servo Motor

  What you should see?
  Turning the potentiometer will cause the servo arm to turn. See the angle.

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

  Try making the servo move in the opposite direction of the potentiometer.
  Or, try swapping a light sensor in for the potentiometer. Then you can make a dial
  that reads how much light is present! This example code is in the public domain.
  Visit madmachine.io for more.
*/

import SwiftIO

let a0 = AnalogIn(Id.A0)        // reads the value of the potentiometer

// Each cycle in the signal lasts for 20 milliseconds and for most of the time,
// the value is LOW. At the beginning of each cycle, the signal is HIGH for a time
// between 1 and 2 milliseconds. At 1 millisecond it represents 0 degrees and at 2 milliseconds
// it represents 180 degrees. In between, it represents the value from 0–180.    
let servo = PWMOut(Id.PWM4A)

while true {
    let value = a0.readPercent()
    let pulse = Float(500 + 2000 * value)
    servo.set(period:20000,pulse:Int(pulse))        // sets the servo position according to the scaled value

    sleep(ms: 100)
}

