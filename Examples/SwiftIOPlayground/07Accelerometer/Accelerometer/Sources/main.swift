// Import SwiftIO to set the communication and MadBoard to use pin id. 
import SwiftIO
import MadBoard
// Import LIS3DH to read the accelerations from the sensor.
import LIS3DH


// Initialize the I2C pins and the sensor.
let i2c = I2C(Id.I2C0)
let accelerometer = LIS3DH(i2c)

// Read the accelerations and each of them.
while true {
    let accelerations = accelerometer.readXYZ()
    let xValue = getFloatString(accelerations.x) + "g"
    let yValue = getFloatString(accelerations.y) + "g"
    let zValue = getFloatString(accelerations.z) + "g"

    print("x: " + xValue)
    print("y: " + yValue)
    print("z: " + zValue)
    print("\n")

    sleep(ms: 1000)
}


func getFloatString(_ num: Float) -> String {
    let int = Int(num)
    let frac = Int((num - Float(int)) * 100)
    return "\(int).\(frac)"
}