// Play a scale by changing the frequency of PWM signal.

// Import the library to enable the relevant classes and functions.
import SwiftIO
import MadBoard

@main
public struct PWMSoundOutput {

    public static func main() {
        // Initialize a PWM output pin the speaker is connected to.
        let speaker = PWMOut(Id.PWM0A)

        // Specify several frequencies to produce different sound.
        let fre = [262, 294, 330, 349, 392, 440, 494]

        // Play recurrently these notes.
        while true {
            for f in fre {
                // Set the frequency and the duty cycle of output to produce each note.
                speaker.set(frequency: f, dutycycle: 0.5)
                // Play each note for one second.
                sleep(ms: 1000)
            }
        }
    }
}
