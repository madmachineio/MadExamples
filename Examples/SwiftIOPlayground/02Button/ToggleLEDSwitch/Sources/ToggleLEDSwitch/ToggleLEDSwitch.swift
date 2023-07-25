// After the button (D1) is pressed and released, the LED (D19) is toggled.

// Import the SwiftIO library to control input and output and 
// the MadBoard to use the id of the pins.
import SwiftIO
import MadBoard

@main
public struct ToggleLEDSwitch {
    public static func main() {
        // Initialize the input pin for the button and output pin for the LED.
        let led = DigitalOut(Id.D18)
        let button = DigitalIn(Id.D1)

        var buttonPressed = false

        while true {
            // If buttonPressing is false, the button is released. 
            // Besides, if buttonPressed is true, it means the button has been pressed.
            // So it checks if the button has been pressed and released. 
            // If so, toggle the LED.
            let buttonPressing = button.read()
            if !buttonPressing && buttonPressed {
                led.toggle()
            }
            // Store the latest button state.
            buttonPressed = buttonPressing
            sleep(ms: 10)
        }
    }
}