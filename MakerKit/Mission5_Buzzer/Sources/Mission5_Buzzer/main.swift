/*
  Mission5 Buzzer +

  What you should see?
  Different tones will play when you turn the potentiometer, using your finger.

  The circuit:
  - Use Potentiometer Module or Light Sensor, and connect it to an Analog Jack.
  - Use Buzzer Module, and connect it to a Digital Jack.

  created 2019
  by Orange J

  Make it play a wonderful piece of music Happy Birthday! Numbered musical
  notation: 55 65 17 55 65 21 55 53 176 44 31 21. This example code is in the public domain.
  Visit madmachine.io for more.
*/

import SwiftIO

let a0 = AnalogIn(Id.A0)

// PWM, also known as Pulse Width Modulation is a type of digital signal. It is commonly
// used in various applications. For example, the PWM signal can be used to configure a server,
// or to control the dimming of a LED light.
// set PWM parameters:    
let buzzer = PWMOut(Id.PWM2)

while true {
    // read the input voltage:
    let value = a0.readPercent()
    let frequency = Int(1000 + 2000 * value)		// convert float type to UInt type
    buzzer.set(period: frequency, pulse: frequency/2)       // reset PWM parameters

    sleep(ms: 50)
}
