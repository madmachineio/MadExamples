// Import the SwiftIO library to control input and output and the MadBoard to use the id of the pins.
import SwiftIO
import MadBoard

@main
public struct LEDBlinkWithTimer {
    public static func main() {
        // Initialize a digital pin for LED module.
        let led = DigitalOut(Id.D18)

        // Initialize the onboard blue LED.
        let blueLed = DigitalOut(Id.BLUE)

        // Initialize a timer for 1500ms.
        let timer = Timer(period: 1500)

        // Define a new function used to toggle the LED.
        func ToggleLEDSwitch() {
            led.toggle()
        }

        // Set an interrupt to reverse the LED state every time the interrupt occurs.
        timer.setInterrupt(ToggleLEDSwitch)

        // Blink onboard blue LED.
        while true {
            blueLed.high()
            sleep(ms: 500)

            blueLed.low()
            sleep(ms: 500)
        }
    }
}
