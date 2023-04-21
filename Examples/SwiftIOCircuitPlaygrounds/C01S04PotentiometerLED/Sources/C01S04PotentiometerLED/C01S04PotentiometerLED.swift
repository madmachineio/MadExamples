// Import SwiftIO library to control input and output, and MadBoard to use the pin name.
import SwiftIO
import MadBoard

@main
public struct C01S04PotentiometerLED {
    public static func main() {
        // Initialize the analog pin for the potentiometer and PWM pin for the LED.
        let knob = AnalogIn(Id.A0)
        let led = PWMOut(Id.PWM4A)

        // Read the input value. 
        // The value is represented in percentage, while the duty cycle is also between 0 and 1, 
        // so you can directly use the reading value to set the PWM.
        while true {
            let dutycycle = knob.readPercent()
            led.setDutycycle(dutycycle)

            sleep(ms: 20)
        }
    }
}