// When you press the button, the LED turns on. 
// If yo continue to hold it, the LED stays on.
// After you release it, the LED turns off.

// Import the SwiftIO library to control input and output and the MadBoard to use the id of the pins.
import SwiftIO
import MadBoard

@main
public struct C01S02ButtonLED {
    public static func main() {
        // Initialize the input pin for the button and output pin for the LED.
        let led = DigitalOut(Id.D18)
        let button = DigitalIn(Id.D1)

        // Keep repeating the following steps.
        while true {
            // Read the input pin to check the button state.
            let value = button.read()

            // If the value is true which means the button is pressed, turn on the LED. Otherwise, turn off the LED.
            if value == true {
                led.write(true)
            } else {
                led.write(false)
            }
            
            // Alternatively
            // led.write(button.read())

            sleep(ms: 10)
        }
    }
}