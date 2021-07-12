// Import the SwiftIO library to control input and output.
import SwiftIO
// Import the SwiftIOFeather to use the id of the pins.
import SwiftIOFeather

// Initialize the pin A0 as an analog input pin.
let knob = AnalogIn(Id.A0)

let led = PWMOut(Id.PWM4A)
led.set(frequency: 1000, dutycycle: 0)

while true {
    let dutycycle = knob.readPercent()
    led.setDutycycle(dutycycle)

    sleep(ms: 20)
}