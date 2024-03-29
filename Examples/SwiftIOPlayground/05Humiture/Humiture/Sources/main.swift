// Import SwiftIO to use I2C communication and MadBoard to use pin id. 
import SwiftIO
import MadBoard
// Import SHT3x to use its functionalities to read values. 
import SHT3x


// Initialize the I2C interface and use it to initialize the sensor.
let i2c = I2C(Id.I2C0)
let humiture = SHT3x(i2c)

// Read the temperature and humidity and print their values out. 
// Stop for 1s and repeat it.
while true {
    let temp = humiture.readCelsius()
    let humidity = humiture.readHumidity()
    print("Temperature: \(temp)C")
    print("Humidity: \(humidity)%")
    sleep(ms: 1000)
}