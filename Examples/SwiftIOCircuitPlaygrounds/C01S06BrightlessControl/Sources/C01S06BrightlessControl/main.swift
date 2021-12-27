// Import the SwiftIO library to control input and output.
import SwiftIO
// Import the SwiftIOFeather to use the id of the pins.
import MadBoard

import VEML6040

// Initialize the I2C bus and the sensor.
let i2c = I2C(Id.I2C0)
let color = VEML6040(i2c)

let led = PWMOut(Id.PWM4A)

// Send the command to the sensor to obtain the value and print it every second.
while true {
    let lux = color.readWhite()
    var rate: Float = Float(lux) / 600.0
    rate = min(1.0, rate)
    rate = max(0.0, rate)
    rate = 1 - rate

    led.setDutycycle(rate)

    sleep(ms: 20)
}