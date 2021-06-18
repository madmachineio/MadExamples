/*
  Mission11 Reproduce Mission10

  This project is similar to the Mission10, but you will import the libraries of LCD1602 and SHT3x instead of including their code in the project itself.

*/

import SwiftIO

// Import the board library to use the Id of the specific board.
import SwiftIOBoard

// Import LCD1602 and SHT3x driver from MadDrivers which is an online git repo
import LCD1602
import SHT3x

// Initialize the LCD and sensor to use the I2C communication.
let i2c = I2C(Id.I2C0)
let lcd = LCD1602(i2c)
let sht = SHT3x(i2c)

while true{
    // Read and display the temperature on the LCD and update the value every 1s.

    let temp = sht.readCelsius()

    lcd.write(x:0, y:0, "Temperature:")
    lcd.write(x: 0, y: 1, temp)
    lcd.write(x:4, y:1, " ")
    lcd.write(x:5, y:1, "C")

    sleep(ms: 1000)
}
