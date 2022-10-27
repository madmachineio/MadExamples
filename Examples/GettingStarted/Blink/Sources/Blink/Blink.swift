// Turn on and off the onboard LED continuously.

// Import the library to enable the relevant classes and functions.
import SwiftIO
import MadBoard

@main
public struct Blink {
    
    public static func main() {
        // Initialize the onboard green LED with other parameters set to default.
        let green = DigitalOut(Id.GREEN)

        // Blink the LED over and over again.
        while true {
            // Apply a high voltage and turn off the LED.
            green.write(true)
            // Keep the light off for a minute.
            sleep(ms: 1000)
            // Apply a low voltage and turn on the LED.
            green.write(false)
            // Keep the light on for a minute.
            sleep(ms: 1000)
        }
    }
}
