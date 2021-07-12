// Import the SwiftIO library to control input and output.
import SwiftIO
// Import the SwiftIOFeather to use the id of the pins.
import SwiftIOFeather

// Initialize the digital output pin the LED connects to.
let led = DigitalOut(Id.D19)

// Initialize the digital input pin the button connects to.
let button = DigitalIn(Id.D1)

// Keep checking the LED state to avoid any omission and allow the button to control the LED all the time.
while true {
    // Read the input pin to check the button state.
    let value = button.read()
    // If the value is true, turn on the LED. Otherwise, turn off the LED.
    if value == true {
        led.write(true)
    } else {
        led.write(false)
    }
}