// Import SwiftIO to use I2C communication and MadBoard to use pin id. 
import SwiftIO
import MadBoard
// Import SHT3x to use its functionalities to read values. 
import SHT3x

@main
public struct Humiture {
    public static func main() {
        // Initialize the I2C interface and use it to initialize the sensor.
        let i2c = I2C(Id.I2C0)
        let sht = SHT3x(i2c)

        // Read the temperature and humidity and print their values out. 
        // Stop for 1s and repeat it.
        while true {
            let temp = sht.readCelsius()
            let humidity = sht.readHumidity()
            print("Temperature: \(temp)C")
            print("Humidity: \(humidity)%")
            sleep(ms: 1000)
        }
    }
}