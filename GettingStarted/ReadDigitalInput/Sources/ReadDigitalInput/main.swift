// Read the input voltage on a specified digital pin. The value you get will be either true or false.

// Import the library to enable the relevant classes and functions.
import SwiftIO

// Initialize the pin D0 as a digital input pin.
let pin = DigitalIn(Id.D0)

// read the input every second.
while true {
    // Declare a constant to store the value you read from the digital pin.
    let value = pin.read()
    // Print the value and you can see it in the serial monitor.
    print(value)
    // Wait a second and then continue to read.
    sleep(ms: 1000)
}

