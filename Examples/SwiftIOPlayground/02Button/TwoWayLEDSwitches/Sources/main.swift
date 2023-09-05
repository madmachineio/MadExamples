// Pressing any of the two buttons (D1, D19) will toggle the LED. 
// The LED state is updated after that button is pressed.

// SwiftIO is used to set input and output of the pins.
import SwiftIO
// MadBoard is for pin ids.
import MadBoard


// Initialize the pins for two buttons and the LED.
let button0 = DigitalIn(Id.D1)
let button1 = DigitalIn(Id.D19)
let led = DigitalOut(Id.D18)

// Store if the LED state is toggled after a button press.
// It ensures the LED state doesn't change again when button is being pressed.
var ledToggled = false

// Toggle the LED after any of the two buttons are pressed.
while true {
    // When any of the buttons are pressed, toggle the LED.
    if !ledToggled && (button0.read() || button1.read()) {
        led.toggle()
        ledToggled = true
    }

    // If both buttons are released, update the state to wait for next press.
    if !button0.read() && !button1.read() {
        ledToggled = false
    }

    sleep(ms: 10)
}