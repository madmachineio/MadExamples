// Import two necessary libraries.
import SwiftIO
import MadBoard

@main
public struct C01S03ButtonPWM {
    public static func main() {
        // Initialize the PWM pin.
        let led = PWMOut(Id.PWM4A)

        // Set the frequency of the PWM signal and set the duty cycle to 0 to keep the LED off.
        led.set(frequency: 1000, dutycycle: 0)

        // Store the max and min values of duty cycle to two constants. 
        let maxDutycycle: Float = 1.0
        let minDutycycle: Float = 0.0

        // The variation of duty cycle per button press.
        let stepDutycycle: Float = 0.1

        // Create a variable to store the value of duty cycle.
        var dutycycle: Float = 0.0

        // Initialize the digital pins. downButton is to dim the LED and the upButton is to brighten the LED.
        let downButton = DigitalIn(Id.D1)
        let upButton = DigitalIn(Id.D21)

        // Each time this button is pressed, the LED will dim a little until it reaches the minimum brightness.
        downButton.setInterrupt(.rising) {
            dutycycle -= stepDutycycle
            dutycycle = max(dutycycle, minDutycycle)

            led.setDutycycle(dutycycle)
        }

        // Once this button is pressed, the LED becomes brighter until it reaches the maximum brightness.
        upButton.setInterrupt(.rising) {
            dutycycle += stepDutycycle
            dutycycle = min(dutycycle, maxDutycycle)

            led.setDutycycle(dutycycle)
        }

        // Keep the board sleeping when the button is not pressed.
        while true {
            sleep(ms: 1000)
        }
    }
}
