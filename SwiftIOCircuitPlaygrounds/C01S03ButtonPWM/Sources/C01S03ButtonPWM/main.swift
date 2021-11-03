// Import the SwiftIO library to control input and output.
import SwiftIO
// Import the SwiftIOFeather to use the id of the pins.
import MadBoard

let led = PWMOut(Id.PWM4A)

led.set(frequency: 1000, dutycycle: 0)

let maxDutycycle: Float = 1.0
let minDutycycle: Float = 0.0
let stepDutycycle: Float = 0.1

var dutycycle: Float = 0.0

let downButton = DigitalIn(Id.D1)
let upButton = DigitalIn(Id.D21)

downButton.setInterrupt(.rising) {
    dutycycle -= stepDutycycle
    dutycycle = max(dutycycle, minDutycycle)

    led.setDutycycle(dutycycle)
}

upButton.setInterrupt(.rising) {
    dutycycle += stepDutycycle
    dutycycle = min(dutycycle, maxDutycycle)

    led.setDutycycle(dutycycle)
}

while true {
    sleep(ms: 1000)
}