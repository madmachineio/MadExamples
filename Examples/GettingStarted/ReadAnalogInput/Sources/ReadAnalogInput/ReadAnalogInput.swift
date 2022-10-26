// Read the input voltage on a specified analog pin. The value you get will be a decimal between 0.0 and 3.3.

// Import the library to enable the relevant classes and functions.
import SwiftIO
import MadBoard

@main
public struct ReadAnalogInput {

    public static func main() {
        // Initialize the pin A0 as a analog input pin.
        let pin = AnalogIn(Id.A0)

        // Read the input voltage every second.
        while true {
            // Declare a constant to store the value you read from the analog pin.
            let value = pin.readVoltage()
            // Print the value and you can see it in the serial monitor.
            print(value)
            // Wait a second and then continue to read.
            sleep(ms: 1000)
        }
    }
}
