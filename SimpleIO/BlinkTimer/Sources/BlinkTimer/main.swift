// Change the LED state every second by setting the interrupt.

// Import the library to enable the relevant classes and functions.
import SwiftIO

// Import the board library to use the Id of the specific board.
import SwiftIOBoard

// Initialize the red onboard LED and a timer to set interrupt.
let red = DigitalOut(Id.RED)
let timer = Timer()

// Raise the interrupt to turn on or off the LED every second.
timer.setInterrupt(ms: 1000) {
    red.toggle()
}


while true {

}