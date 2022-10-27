// Import SwiftIO library to control input and output, and MadBoard to use the pin name.
import SwiftIO
import MadBoard

@main
public struct C01S04Potentiometer {
    public static func main() {
        // Initialize the analog pin A0 for the potentiometer.
        let knob = AnalogIn(Id.A0)

        // Read the voltage value and print it out every second.
        while true {
            let value = knob.readVoltage()
            print(value)
            sleep(ms: 1000)
        }
    }
}