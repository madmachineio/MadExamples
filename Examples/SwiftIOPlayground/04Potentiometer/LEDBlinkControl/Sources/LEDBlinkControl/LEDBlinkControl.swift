// Use two potentiometers to control LED.
// One changes LED brightness and the other changes the blink rate.

// Import SwiftIO to control input and output.
import SwiftIO
// Import MadBoard to use the pin ids.
import MadBoard

@main
public struct LEDBlinkControl {
    public static func main() {
        // Initialize the analog pin used to adjust LED brightness.
        let brightnessPot = AnalogIn(Id.A0)
        // Initialize the analog pin used to change blink rate. 
        let blinkRatePot = AnalogIn(Id.A11)
        // Initialize the PWM pin for the LED.
        let led = PWMOut(Id.PWM4A)

        while true {
            // Read raw value from the analog pin. It sets the LED blink rate.
            let blinkTime = blinkRatePot.readRawValue() / 2

            // Read value from the analog pin. 
            // It serves as duty cycle for PWM to set LED brightness.
            led.setDutycycle(brightnessPot.readPercent())
            sleep(ms: blinkTime)

            // After a specified time, suspend the output to turn off the LED.
            led.suspend()
            sleep(ms: blinkTime)
        }
    }
}
