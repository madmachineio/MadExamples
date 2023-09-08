// First import the SwiftIO and MadBoard libraries into the project to use related functionalities.
import SwiftIO
import MadBoard

// Initialize the specified pin used for digital output.
let led = DigitalOut(Id.D18)

// The code in the loop will run over and over again. 
while true {
    //Output high voltage to turn on the LED.   
    led.write(true)
    // Keep the LED on for 1 second.
    sleep(ms: 1000)

    // Turn off the LED and then keep that state for 1s.
    led.write(false)
    sleep(ms: 1000)
}