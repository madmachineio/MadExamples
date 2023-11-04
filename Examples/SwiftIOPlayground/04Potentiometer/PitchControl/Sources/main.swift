// Import the SwiftIO to control input and output and the MadBoard to use the pin name.
import SwiftIO
import MadBoard


// Initialize the analog pin for the potentiometer and PWM pin for the LED.
let pot = AnalogIn(Id.A0)
let buzzer = PWMOut(Id.PWM5A)

// Read the input value in percentage. 
// Then calculate the value into the frequency. 
// Set the PWM with the frequency and a duty cycle.
while true {
    let potPercentage = pot.readPercentage()
    let frequency = 50 + Int(1000 * potPercentage)
    buzzer.set(frequency: frequency, dutycycle: 0.5)
    sleep(ms: 20)
}
