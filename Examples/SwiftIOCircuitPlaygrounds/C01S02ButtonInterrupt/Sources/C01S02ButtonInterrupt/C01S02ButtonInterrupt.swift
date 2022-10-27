// Import the SwiftIO library to control input and output and the MadBoard to use the id of the pins.
import SwiftIO
import MadBoard

@main
public struct C01S02ButtonInterrupt {
    public static func main() {
        // Initialize the input pin for the button and output pin for the LED.
        let button = DigitalIn(Id.D1)
        let led = DigitalOut(Id.D19)

        // Define a new function used to toggle the LED.
        func toggleLed() {
            led.toggle()
        }

        // Set the interrupt to detect the rising edge. Once detected, the LED will change its state.
        button.setInterrupt(.rising, callback: toggleLed)

        // Keep sleeping if the interrupt hasn't been triggered.
        while true {
            sleep(ms: 1000)
        }
    }
}
