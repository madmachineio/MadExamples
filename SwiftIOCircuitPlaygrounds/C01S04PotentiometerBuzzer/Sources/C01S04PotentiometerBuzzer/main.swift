// Import the SwiftIO library to control input and output.
import SwiftIO
// Import the SwiftIOFeather to use the id of the pins.
import SwiftIOFeather

// Initialize the pin A0 as an analog input pin.
let knob = AnalogIn(Id.A0)

// Initialize a PWM output pin the buzzer connects.
let buzzer = PWMOut(Id.PWM5A)

while true {
    let value = knob.readPercent()
    let f = 50 + Int(1000 * value)

    buzzer.set(frequency: f, dutycycle: 0.5)

    sleep(ms: 20)
}