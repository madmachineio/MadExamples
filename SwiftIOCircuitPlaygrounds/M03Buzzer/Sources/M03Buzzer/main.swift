// Import the SwiftIO library to control input and output.
import SwiftIO
// Import the SwiftIOFeather to use the id of the pins.
import SwiftIOFeather

// Initialize a PWM output pin the buzzer connects.
let buzzer = PWMOut(Id.PWM5A)

// Specify the frequencies to produce different sounds.
let fre = [262, 294, 330, 349, 392, 440, 494, 523]
for f in fre {
    // Set the frequency and the duty cycle to produce each note.
    buzzer.set(frequency: f, dutycycle: 0.5)
    // Play each note for one second.
    sleep(ms: 1000)
}

buzzer.suspend()

// Leave it here even if it is empty.
while true {
   
}