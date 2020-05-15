import SwiftIO

let i2c = I2C(Id.I2C0)
let lcd = LCD1602(i2c)

lcd.write(x: 0, y: 0, "Hello World!")

while true {

}