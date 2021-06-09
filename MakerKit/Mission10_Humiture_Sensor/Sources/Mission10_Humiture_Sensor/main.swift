/*
  Mission10 Humiture Sensor

  The LCD will show the temperature in Celsius. The data will be updated every second.

  The circuit:
  - Use Humiture Sensor, and connect it to I2C0 Jack.
  - Use LCD Module, and connect it to I2C0 Jack.

  created 2019
  by Orange J

  By changing the code you can display the temperature as a bar graph instead of
  a number. This example code is in the public domain. Visit madmachine.io for more info.
*/

import SwiftIO

// Import the board library to use the Id of the specific board.
import SwiftIOBoard

// Get a number with one decimal place.
extension Float {
    func format(_ f: Int) -> Float {
        guard f > 0 else {return self}
        var mul = 10
        for _ in 1..<f {
            mul *= 10
        }
        let data = Int(self * Float(mul))
        return Float(data) / Float(mul)
    }
}

// Initialize the LCD and sensor to use the I2C communication.
let i2c = I2C(Id.I2C0)
let lcd = LCD1602(i2c)
let sht = SHT3x(i2c)

while true{
    // Read and display the temperature on the LCD and update the value every 1s.

    let temp = sht.readCelsius()

    lcd.write(x:0, y:0, "Temperature:")
    lcd.write(x: 0, y: 1, String(temp.format(1)))
    lcd.write(x:4, y:1, " ")
    lcd.write(x:5, y:1, "C")

    sleep(ms: 1000)
}
