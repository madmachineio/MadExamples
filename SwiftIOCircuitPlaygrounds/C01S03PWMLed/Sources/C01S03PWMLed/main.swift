// Import the SwiftIO library to control input and output.
import SwiftIO
// Import the SwiftIOFeather to use the id of the pins.
import SwiftIOFeather

let led = PWMOut(Id.PWM4A)

led.set(frequency: 1000, dutycycle: 0)

let maxDutycycle: Float = 1.0
let minDutycycle: Float = 0.0
let stepDutycycle: Float = 0.01

var dutycycle: Float = 0.0
var upDirection = true

while true {
    led.setDutycycle(dutycycle)
    sleep(ms: 10)

    if upDirection {
        dutycycle += stepDutycycle
        if dutycycle >= maxDutycycle {
            upDirection = false
        }
    } else {
        dutycycle -= stepDutycycle
        if dutycycle <= minDutycycle {
            upDirection = true
        }
    }
}