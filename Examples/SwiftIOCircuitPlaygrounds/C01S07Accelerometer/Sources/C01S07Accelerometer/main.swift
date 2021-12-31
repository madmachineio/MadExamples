// Import the SwiftIO library to control input and output.
import SwiftIO
// Import the SwiftIOFeather to use the id of the pins.
import MadBoard

import LIS3DH

// Initialize the I2C bus and the sensor.
let i2c = I2C(Id.I2C0)
let acc = LIS3DH(i2c)


// Send the command to the sensor to obtain the value and print it every second.
while true {
    let value = acc.readXYZ()
    print("x: \(value.x)g")
    print("y: \(value.y)g")
    print("z: \(value.z)g")
    print("\n")
    sleep(ms: 1000)
}