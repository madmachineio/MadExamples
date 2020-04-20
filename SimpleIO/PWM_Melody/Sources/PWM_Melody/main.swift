/// Enable the speaker to play a simple melody by changing the frequency of PWM output.

/// Import the library to enable the relevant classes and functions.
import SwiftIO

/// Initialize a PWM output pin the speaker is connected to.
let speaker = PWMOut(Id.PWM0)

/// Specify several frequencies corresponding to each note of the melody. 
let fre = [
    350,350,393,441,
    441,393,350,330,
    294,294,330,350,
    350,330,330
]

/// Allow the speaker to repeat the melody again and again.
while true {
    for i in 0..<fre.count {
        // Change the frequency and the duty cycle of output to produce each note.
        speaker.set(frequency: fre[i], dutycycle: 0.5)
        sleep(ms: 250)
    }
}
