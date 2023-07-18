// Import two necessary libraries.
import SwiftIO
import MadBoard

@main
public struct ButtonDimmer {
    public static func main() {
        // Initialize the PWM pin.
        let led = PWMOut(Id.PWM4A)

        // Store the max and min values of duty cycle to two constants. 
        let maxDutycycle: Float = 1.0
        let minDutycycle: Float = 0.0

        // The variation of duty cycle per button press.
        let stepDutycycle: Float = 0.1

        // Create a variable to store the value of duty cycle.
        var dutycycle: Float = 0.0

        // Initialize the digital pins. downButton is to dim the LED and the upButton is to brighten the LED.
        let downButton = DigitalIn(Id.D1)
        let upButton = DigitalIn(Id.D19)

        var changed = false

        // Each time this button is pressed, the LED will dim a little until it reaches the minimum brightness.
        downButton.setInterrupt(.rising) {
            dutycycle -= stepDutycycle
            dutycycle = max(dutycycle, minDutycycle)
            changed = true
        }

        // Once this button is pressed, the LED becomes brighter until it reaches the maximum brightness.
        upButton.setInterrupt(.rising) {
            dutycycle += stepDutycycle
            dutycycle = min(dutycycle, maxDutycycle)
            changed = true
        }

        // Update the duty cycle of PWM signal to change the LED brightness.
        while true {
            if changed {
                led.setDutycycle(dutycycle)
                changed = false
            }
            sleep(ms: 10)
        }
    }
}
