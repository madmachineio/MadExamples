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
import MadBoard

@main
public struct Mission10_Humiture_Sensor {

    public static func main() {
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
    }
}