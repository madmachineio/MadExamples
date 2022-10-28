// Import the SwiftIO to control input and output and the MadBoard to use the pin name.
import SwiftIO
import MadBoard

@main
public struct C01S04PotentiometerBuzzer {
    public static func main() {
        // Initialize the analog pin for the potentiometer and PWM pin for the LED.
        let knob = AnalogIn(Id.A0)
        let buzzer = PWMOut(Id.PWM5A)

        // Read the input value in percentage. 
        // Then calculate the value into the frequency. 
        // Set the PWM with the frequency and a duty cycle.
        while true {
            let value = knob.readPercent()
            let f = 50 + Int(1000 * value)
            buzzer.set(frequency: f, dutycycle: 0.5)
            sleep(ms: 20)
        }
    }
}
