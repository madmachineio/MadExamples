// Import SwiftIO to set input and output.
import SwiftIO
// Import MadBoard to use the id of the pins.
import MadBoard
// Import this driver to read accelerations on x, y, z-axis.
import LIS3DH

@main
public struct AccelerometerDice {
    public static func main() {
        // Initialize an I2C interface and use it to set the sensor.
        let i2c = I2C(Id.I2C0)
        let dice = LIS3DH(i2c)

        // Initialize an LED used as an indicator when shaking the sensor.
        let indicator = DigitalOut(Id.D18)

        // Create a variable to store the time after the sensor stops movement.
        var steadyCount = 999

        // Read accelerations to judge if the sensor is in motion. 
        // Once the movement stops, a random number prints out.
        while true {
            let diceValue = dice.readXYZ()
            
            if abs(diceValue.x) > 0.3 || abs(diceValue.y) > 0.3 {
                indicator.high()
                steadyCount = 0
            } else {
                steadyCount += 1
                if steadyCount == 50 {
                    indicator.low()
                    print(Int.random(in: 1...6))
                }
            }

            sleep(ms: 5)
        }
    }
}
