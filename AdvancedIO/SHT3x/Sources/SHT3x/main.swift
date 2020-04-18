/// Read the current temperature and humidity.
import SwiftIO

/// Initialize the I2C bus and the sensor for the communication.
let i2c = I2C(.I2C0)
let sht = SHT3x(i2c)

/// Send the command to the sensor to obtain the value and print it every sencond.
while true {
    let temp = sht.readTemperature()
    let humidity = sht.readHumidity()
    print(temp)
    print(humidity)
    sleep(ms: 1000)
}