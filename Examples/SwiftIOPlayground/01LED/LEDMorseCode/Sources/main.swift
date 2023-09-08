// Import the libraries to use all their functionalities.
import SwiftIO
import MadBoard

// Initialize the digital output pin.
let led = DigitalOut(Id.D18)

// Define the LED states to represent the letter s and o.
let sSignal = [false, false, false]
let oSignal = [true, true ,true]

// Set the LED blink rate according to the values in the array.
func send(_ values: [Bool], to light: DigitalOut) {
    // The duration of slow flash and quick flash.
    let long = 1000
    let short = 500

    // Iterate all the values in the array. 
    // If the value is true, the LED will be on for 1s, which is a slow flash.
    // And if it’s false, the LED will be on for 0.5s, which is a quick flash.
    for value in values {
        light.high()
        if value {
            sleep(ms: long)
        } else {
            sleep(ms: short)
        }
        light.low()
        sleep(ms: short)
    }
}

// Blink the LED.
// At first, the LED starts 3 fast blink to represent s, then 3 slow blink to represent o, and 3 fast blink again.
// Wait 1s before repeating again.
while true {
    send(sSignal, to: led)
    send(oSignal, to: led)
    send(sSignal, to: led)
    sleep(ms: 1000)
}