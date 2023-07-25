import SwiftIO
import MadBoard

@main
public struct RGBLED {
    public static func main() {
        // Initialize the built-in red, green, blue LED.
        // They need a low level to be turned on.
        // So set the digital value of true to turn them off in the beginning.
        let red = DigitalOut(Id.RED, value: true)
        let green = DigitalOut(Id.GREEN, value: true)
        let blue = DigitalOut(Id.BLUE, value: true)
        
        while true {
            // Red.
            setRGB(true, false, false)
            // Green.
            setRGB(false, true, false)
            // Blue.
            setRGB(false, false, true)
            // Yellow (red + green).
            setRGB(true, true, false)
            // Magenta (red + blue).
            setRGB(true, false, true)
            // Cyan (green + blue).
            setRGB(false, true, true)
            // White (red + green + blue). 
            setRGB(true, true, true)
            // Off.
            setRGB(false, false, false)
        }

        // Control red, green and blue LED with the given values.
        // Apply low voltage to turn on the built-in LEDs. 
        // For example, if you want the red LED on, you should write false.
        func setRGB(_ redOn: Bool, _ greenOn: Bool, _ blueOn: Bool) {
            red.write(!redOn)
            green.write(!greenOn)
            blue.write(!blueOn)
            sleep(ms: 1000)
        }
    }
}
