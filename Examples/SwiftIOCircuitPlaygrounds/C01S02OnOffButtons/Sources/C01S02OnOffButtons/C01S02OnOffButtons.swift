// Control the LED with two dedicated buttons.
// The button D1 is used to turn on LED and D21 is to turn off it.

// SwiftIO is used to set all input and output.
import SwiftIO
// MadBoard is for pin ids.
import MadBoard

@main
public struct C01S02OnOffButtons {
    public static func main() {
        // Initialize the pin for the button used to turn on LED.
        let onButton = DigitalIn(Id.D1)
        // Initialize the pin for the button used to turn off the LED.
        let offButton = DigitalIn(Id.D21)
        let led = DigitalOut(Id.D19)

        // Store the current LED state.
        var ledState = false

        // Store the last button state used to decide whether the button is released.
        var lastOnButtonState = false
        var lastOffButtonState = false

        while true {
            if !ledState {
                // If the LED is off, check if the on button (D1) is pressed. 
                // If so, turn on the LED after the button is released.

                // Update the button state if it is pressed. 
                if onButton.read() {
                    lastOnButtonState = true
                }

                // If the button has been pressed and is released now, turn on the LED and update all states.
                if lastOnButtonState && !onButton.read() {
                    led.high()
                    lastOnButtonState = false
                    ledState = true
                }
            } else {
                // If the LED is on, check if the off button (D21) is pressed. 
                // If so, turn off the LED after the button is released.

                // Update the button state if it is pressed. 
                if offButton.read() {
                    lastOffButtonState = true
                }

                // If the button has been pressed and is released now, turn off the LED and update all states.
                if lastOffButtonState && !offButton.read() {
                    led.low()
                    lastOffButtonState = false
                    ledState = false
                }
            }
            
            sleep(ms: 10)
        }
    }
}
