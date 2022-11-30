// Import the SwiftIO library to control input and output and 
// the MadBoard to use the id of the pins.
import SwiftIO
import MadBoard

@main
public struct C01S02ToggleLED {
    public static func main() {
        // Initialize the input pin for the button and output pin for the LED.
        let led = DigitalOut(Id.D19)
        let button = DigitalIn(Id.D1)

        var lastState = false

        while true {
            // If currentState is false, the button is released. 
            // Besides, if lastState is true, it means the button has been pressed.
            // So it checks if the button has been pressed and released. 
            // If so, toggle the LED.
            let currentState = button.read()
            if !currentState && currentState != lastState {
                led.toggle()
            }
            // Store the latest button state.
            lastState = currentState
            sleep(ms: 20)
        }
    }
}