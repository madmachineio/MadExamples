// Control the LED with two dedicated buttons.
// The button D1 is used to turn on LED and D19 is to turn off it.

// SwiftIO is used to set all input and output.
import SwiftIO
// MadBoard is for pin ids.
import MadBoard

@main
public struct OnOffButtons {
    public static func main() {
        // Initialize the pin for the button used to turn ON LED.
        let onButton = DigitalIn(Id.D1)
        // Initialize the pin for the button used to turn OFF the LED.
        let offButton = DigitalIn(Id.D19)
        let led = DigitalOut(Id.D18)

        // Store the current LED state.
        var ledOn = false

        // Store the last button state used to decide whether the button is released now.
        var onButtonPressed = false
        var offButtonPressed = false

        while true {
            if ledOn {
                // If the LED is on, check if the off button (D19) is pressed. 
                // If so, turn off the LED after the button is released.

                // Update the OFF button state if it is pressed. 
                if offButton.read() {
                    offButtonPressed = true
                }

                // If the OFF button has been pressed and is released now, turn off the LED and update all states.
                if offButtonPressed && !offButton.read() {
                    led.low()
                    offButtonPressed = false
                    ledOn = false
                }
            } else {
                // If the LED is off, check if the on button (D1) is pressed. 
                // If so, turn on the LED after the button is released.

                // Update the ON button state if it is pressed. 
                if onButton.read() {
                    onButtonPressed = true
                }

                // If the ON button has been pressed and is released now, turn on the LED and update all states.
                if onButtonPressed && !onButton.read() {
                    led.high()
                    onButtonPressed = false
                    ledOn = true
                }
            }
            
            sleep(ms: 10)
        }
    }
}
