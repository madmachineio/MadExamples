// Import SwiftIO to set the communication and MadBoard to use pin id. 
import SwiftIO
import MadBoard
// Import LIS3DH to read the accelerations from the sensor.
import LIS3DH

@main
public struct Accelerometer {
    public static func main() {
        // Initialize the I2C pins and the sensor.
        let i2c = I2C(Id.I2C0)
        let accelerometer = LIS3DH(i2c)

        // Read the accelerations and each of them.
        while true {
            let accelerations = accelerometer.readXYZ()
            print("x: \(accelerations.x)g")
            print("y: \(accelerations.y)g")
            print("z: \(accelerations.z)g")
            print("\n")
            sleep(ms: 1000)
        }
    }
}
