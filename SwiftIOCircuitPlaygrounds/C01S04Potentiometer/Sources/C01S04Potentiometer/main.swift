// Import the SwiftIO library to control input and output.
import SwiftIO
// Import the SwiftIOFeather to use the id of the pins.
import SwiftIOFeather

// Initialize the pin A0 as an analog input pin.
let knob = AnalogIn(Id.A0)

// Read the input voltage every second.
while true {
    // Declare a constant to store the value read from the pin.
    let value = knob.readVoltage()
    // Print the value and you can see it in the serial monitor.
    print(value)
    // Wait a second and then continue to read.
    sleep(ms: 1000)
}