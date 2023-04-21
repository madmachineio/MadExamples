// Import the SwiftIO library to control input and output and the MadBoard to use the id of the pins.
import SwiftIO
import MadBoard

@main
public struct C01S01TimerLEDToggle {
    public static func main() {
        // Initialize a digital pin for LED module.
        let led = DigitalOut(Id.D18)

        // Initialize the onboard blue LED.
        let blueLed = DigitalOut(Id.BLUE, value: true)

        // Initialize a timer for 1500ms.
        let timer = Timer(period: 1500)

        // Define a new function used to toggle the LED.
        func toggleLed() {
            led.toggle()
        }

        // Set an interrupt to reverse the LED state every time the interrupt occurs.
        timer.setInterrupt(toggleLed)

        // Blink onboard blue LED.
        while true {
            blueLed.low()
            sleep(ms: 500)

            blueLed.high()
            sleep(ms: 500)
        }
    }
}