// Read the analog input and use it to set the rate of LED blink.

// Import the library to enable the relevant classes and functions.
import SwiftIO
import MadBoard

@main
public struct BlinkRate {

    public static func main() {
       // Initialize an analog input and a digital output pin that the components are connected to.
        let sensor = AnalogIn(Id.A0)
        let led = DigitalOut(Id.D1)

        // Enable the LED to blink over and over again.
        while true {
            // Read the input voltage in percentage.
            let value = sensor.readRawValue()
            // Change the current LED state.
            led.toggle()
            // Keep the LED on or off for a certain period determined by the value you get.
            sleep(ms: value)
        }
    }
}
