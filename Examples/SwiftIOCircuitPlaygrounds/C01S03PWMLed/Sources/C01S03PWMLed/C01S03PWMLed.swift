// Import the SwiftIO library to set the input and output and the MadBoard to use the pin id.
import SwiftIO
import MadBoard

@main
public struct C01S03PWMLed {
    public static func main() {
        // Initialize a PWM output pin for the LED.
        let led = PWMOut(Id.PWM4A)

        // Set the PWM output to control the LED. 
        // The frequency is set to 1000Hz or can be other value. 
        // The duty cycle is 0 in the beginning so LED keeps turning off.
        led.set(frequency: 1000, dutycycle: 0)

        // Store the maximum and minimum values of the duty cycle to two constants. 
        let maxDutycycle: Float = 1.0
        let minDutycycle: Float = 0.0

        // Set the change of duty cycle for each action.
        let stepDutycycle: Float = 0.01

        // Create a variable to store the varying duty cycle.
        var dutycycle: Float = 0.0

        // A condition used to decide whether to increase or decrease the duty cycle. 
        var upDirection = true

        while true {
            // Output a PWM signal with the specified duty cycle to control LED brightness.
            led.setDutycycle(dutycycle)
            // Keep each brightness last for 10ms, or you may not see the changes.
            sleep(ms: 10)

            // Increase or decrease the duty cycle within its range according to the value of upDirection.
            if upDirection {
                dutycycle += stepDutycycle
                if dutycycle >= maxDutycycle {
                    upDirection = false
                }
            } else {
                dutycycle -= stepDutycycle
                if dutycycle <= minDutycycle {
                    upDirection = true
                }
            }
        }
    }
}