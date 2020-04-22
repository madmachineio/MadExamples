/*
  Mission10 Humiture Sensor

  What you should see?
  The LCD will show the temperature in Celsius. The data readings will update every second.

  The circuit:
  - Use Humiture Sensor, and connect it to I2C0 Jack.
  - Use LCD Module, and connect it to I2C0 Jack.

  created 2019
  by Orange J

  By changing the code you can display the temperature as a bar graph instead of
  a number. This example code is in the public domain. Visit madmachine.io for more.
*/

import SwiftIO

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

// to do
// I2C is a two wire serial protocol for communicating between devices.
let i2c = I2C(Id.I2C0)
let lcd = LCD16X02(i2c)
let sht = SHT3X(i2c)
    
// initialize the sensor
sht.Init()

while true{   
    let array = i2c.read(count:2,from:0x44)
    let value:UInt16 = UInt16(UInt16(array[0]) << 8) | UInt16(array[1])
    let data:Float = 175 * Float(value) / 65535 - 45

    // display for example
    // Temperature:
    // 26.8  C
    lcd.print("Temperature:",x:0,y:0)
    lcd.print(String(data.format(1)),x: 0,y: 1)
    lcd.print(" ",x:4,y:1)
    lcd.print("C",x:5,y:1)

    sleep(ms: 1000)
}   
