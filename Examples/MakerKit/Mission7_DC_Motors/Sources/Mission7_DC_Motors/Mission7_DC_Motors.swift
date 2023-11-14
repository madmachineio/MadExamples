/*
  Mission7 DC Motor

  Turn the potentiometer and the motor will rotate in a different speed.

  The circuit:
  - Use Potentiometer Module, and connect it to an Analog Jack.
  - Use Motor Driver Module, and connect it to a Digital Jack.

  created 2019
  by Orange J

  Try to change the motor rotate in a diverse direction.
  This example code is in the public domain.
  Visit madmachine.io for more info.
*/

import SwiftIO
import MadBoard

@main
public struct Mission7_DC_Motors {

    public static func main() {
        // Initialize the analog pin and the PWM pin 
        let a0 = AnalogIn(Id.A0)
        let motor = PWMOut(Id.PWM2B)

        while true {
            // Read the input value and use it to set the duty cycle of pwm.
            let value = a0.readPercentage()
            motor.setDutycycle(value) 
            sleep(ms: 50)
        }
    }
}
