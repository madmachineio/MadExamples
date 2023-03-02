// Pressing any of the two buttons (D1, D21) will toggle the LED. 
// The LED state is updated after that button is pressed.

// SwiftIO is used to set input and output of the pins.
import SwiftIO
// MadBoard is for pin ids.
import MadBoard

@main
public struct C01S02TwoButtonsOneLED {
    public static func main() {
        // Initialize the pins for two buttons and the LED.
        let button0 = DigitalIn(Id.D1)
        let button1 = DigitalIn(Id.D21)
        let led = DigitalOut(Id.D19)

        // Store if a button has been pressed.
        var pressed = false

        // Toggle the LED after any of the two buttons are pressed.
        while true {
            // When any of the buttons are pressed, toggle the LED.
            if !pressed && (button0.read() || button1.read()) {
                led.toggle()
                pressed = true
            }

            // If the buttons are released, update the state to wait for next press.
            if !button0.read() && !button1.read() {
                pressed = false
            }

            sleep(ms: 10)
        }
    }
}
