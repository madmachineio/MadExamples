// Blink LED every second.

import SwiftIO
import MadBoard
import PCF8563

@main
public struct C01S06BlinkUsingRTC {
    public static func main() {
        let i2c = I2C(Id.I2C0)
        let rtc = PCF8563(i2c)
        let led = DigitalOut(Id.D18)

        while true {
            let time = rtc.readTime()
            led.write(time.second % 2 == 0)
            sleep(ms: 10)
        }
    }
}
