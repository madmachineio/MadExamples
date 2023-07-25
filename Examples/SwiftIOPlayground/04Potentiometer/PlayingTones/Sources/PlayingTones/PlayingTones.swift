// Play scales by rotating a potentiometer slowly.

// Import the SwiftIO library to set the input and output, and the MadBoard to use the pin ids.
import SwiftIO
import MadBoard

@main
public struct PlayingTones {
    public static func main() {
        // Initialize a PWM pin for the buzzer.
        let buzzer = PWMOut(Id.PWM5A)
        // Initialize a analog pin for the potentiometer.
        let pot = AnalogIn(Id.A0)

        // Declare a constant to store an array of frequencies. 
        // They matches respectively notes C4, D4, E4, F4, G4, A4, B4, C5.
        let frequencies = [262, 294, 330, 349, 392, 440, 494, 523]

        // Store the last frequency index to avoid playing the same note.
        var lastFrequencyIndex = frequencies.count

        while true {
            // Read the raw analog value from the pin.
            // Map the value into the index of the array.
            let frequencyIndex = Int((Float(pot.readRawValue() * (frequencies.count - 1)) / Float(pot.maxRawValue)).rounded(.toNearestOrAwayFromZero))

            // Check if the note hasn't been played.
            if frequencyIndex != lastFrequencyIndex {
                // Play the new note for 500ms.
                buzzer.set(frequency: frequencies[frequencyIndex], dutycycle: 0.5)
                sleep(ms: 500)
                buzzer.suspend()
                lastFrequencyIndex = frequencyIndex
            }
            sleep(ms: 10)
        }
    }
}
