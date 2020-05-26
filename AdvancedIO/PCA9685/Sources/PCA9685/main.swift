import SwiftIO

extension PCA9685 {
    func setServoPulse(_ channel: Int, _ pulse: Int) {
        if pulse < 500 || pulse > 2500 {
            return
        }

        let value: UInt32 = UInt32(pulse) * 4096 / 2_0000
        setPWM(UInt8(channel), 0, UInt16(value))
    } 
}

let i2c = I2C(Id.I2C0)
let pwm = PCA9685(i2c)

while true {
    for pulse in stride(from: 500, through: 2500, by: 10)  {
        for channel in 0..<16 {
            pwm.setServoPulse(channel, pulse)
        }
        sleep(ms: 20)
    }
}