/// Check if the button is definitely pressed.

/// Import the library to enable the relevant classes and functions.
import SwiftIO

/// Initialize the red onboard LED.
let red = DigitalOut(Id.RED)

/// Initialize a digital input pin D0 the button is connected to.
let button = DigitalIn(Id.D0, mode: .pullUp)

/// Declare the values in order to record and judge the button state.
var count = 0
var triggered = false


while true {
    // Read from the input pin.
    let value = button.read()
    
    // Ignore the change due to the noise.
    if value == false {
        count += 1
    } else {
        count = 0
        triggered = false
    }
    
    // Wait a certain period to check if the button is definitely pressed. 
    // Toggle the LED and then reset the value for next press.
    if count > 50 && !triggered {
        red.toggle()
        triggered = true
        count = 0
    }
    
    // Wait a millisecond and then read to ensure the current state last for enough time. 
    sleep(ms: 1)

}

