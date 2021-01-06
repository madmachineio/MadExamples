// Enable the speaker to play a simple melody by changing the frequency of PWM output.

// Import the library to enable the relevant classes and functions.
import SwiftIO

// Initialize a PWM output pin the speaker is connected to.
let speaker = PWMOut(Id.PWM0A)

// Specify several frequencies corresponding to each note of the melody. 
let fre = [
    330,330,349,392,
    392,349,330,294,
    262,262,294,330,
    330,294,294
]

// Allow the speaker to repeat the melody again and again.
while true {
    for f in fre {
        // Change the frequency and the duty cycle of output to produce each note.
        speaker.set(frequency: f, dutycycle: 0.5)
        sleep(ms: 250)
    }
}
