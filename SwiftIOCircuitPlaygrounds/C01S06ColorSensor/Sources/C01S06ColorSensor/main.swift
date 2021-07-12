// Import the SwiftIO library to control input and output.
import SwiftIO
// Import the SwiftIOFeather to use the id of the pins.
import SwiftIOFeather

import VEML6040

// Initialize the I2C bus and the sensor.
let i2c = I2C(Id.I2C0)
let color = VEML6040(i2c)

// Send the command to the sensor to obtain the value and print it every second.
while true {
    let lux = color.readWhite()
    print("Lux: \(lux)lux")
    sleep(ms: 1000)
}