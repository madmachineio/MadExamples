// Import the SwiftIO library to set the input and output, and the MadBoard to use the pin id.
import SwiftIO
import MadBoard

@main
public struct PlayingScale {
    public static func main() {
        // Initialize a PWM pin for the buzzer.
        let buzzer = PWMOut(Id.PWM5A)

        // Declare a constant to store an array of frequencies. 
        // Consult the pitch-frequency chart above and list all the necessary frequencies in order in the array.
        let frequencies = [262, 294, 330, 349, 392, 440, 494, 523]

        // Use the for-in loop to iterate through each frequency.
        // Set the frequency of the PWM signal to generate sounds. Each note will last 1s.
        for frequency in frequencies {
            buzzer.set(frequency: frequency, dutycycle: 0.5)
            sleep(ms: 1000)
        }

        // Stop the buzzer sound.
        buzzer.suspend()

        while true {
            sleep(ms: 1000)
        }
    }
}
