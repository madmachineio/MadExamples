// Brighten or dimming the LED by changing the duty cycle of PWM signal.

// Import the library to enable the relevant classes and functions.
import SwiftIO
import MadBoard

@main
public struct BreathingLED {

    public static func main() {
        // Initialize the PWM pin the LED is connected to, with other parameters set to default.
        let led = PWMOut(Id.PWM0A)

        // Initialize a variable to store the value of duty cycle.
        var value: Float = 0.0

        // Change the brightness from on to off and off to on over and over again.
        while true {
            // Brighten the LED in two seconds.
            while value <= 1.0 {
                led.setDutycycle(value)
                sleep(ms: 20)
                value += 0.01
            }
            // Keep the duty cycle between 0.0 and 1.0.
            value = 1.0

            // Dimming the LED in two seconds.
            while value >= 0 {
                led.setDutycycle(value)
                sleep(ms: 20)
                value -= 0.01
            }
            // Keep the duty cycle between 0.0 and 1.0.
            value = 0.0
        }
    }
}
