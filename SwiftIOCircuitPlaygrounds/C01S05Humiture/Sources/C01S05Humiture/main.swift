// Import the SwiftIO library to control input and output.
import SwiftIO
// Import the SwiftIOFeather to use the id of the pins.
import MadBoard
// Import the SHT3x to read the temperature and humidity values directly.
import SHT3x

// Initialize the I2C bus and the sensor.
let i2c = I2C(Id.I2C0)
let sht = SHT3x(i2c)

// Send the command to the sensor to obtain the value and print it every second.
while true {
    let temp = sht.readCelsius()
    let humidity = sht.readHumidity()
    print("Temperature: \(temp)C")
    print("Humidity: \(humidity)%")
    sleep(ms: 1000)
}