let lcd = LCD1602(i2c)
let sht = SHT3x(i2c)

@main
public struct Mission11_Reproduce_Mission10 {

    public static func main() {
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
