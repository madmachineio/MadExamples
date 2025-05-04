import SwiftIO
import MadBoard

import SHT3x
import LIS3DH
import PCF8563

func i2cIOThread(_ a: UnsafeMutableRawPointer?, _ b: UnsafeMutableRawPointer?, _ c: UnsafeMutableRawPointer?) -> () {
    sleep(ms: 500)

    let i2c = I2C(Id.I2C0, speed: .fast)
    sleep(ms: 10)

    let sht = SHT3x(i2c)
    sleep(ms: 10)
    var temp = 0
    var humidity = 0
    var tempCount = 0
    var humidityCount = 0
    var previousTemp = -1
    var previousHumidity = -1


    let acc = LIS3DH(i2c)
    sleep(ms: 10)
    var x = 50

    var accCount = 0
    var previousX = 50







    while true {
        sleep(ms: 10)

        let ret = acc.readXYZ()
        x = 100 - (Int(ret.x * 100.0) + 50)
        x = min(93, x)
        x = max(1, x)

        if x != previousX {
            accCount += 1
            if accCount > 2 {
                accCount = 0
                i2cLock.lock()
                globalI2CValue[accValue] = (previousX << 8) | x
                i2cLock.unlock()
                previousX = x
            }
        }




        temp = Int(sht.readCelsius() * 10)
        humidity = Int(sht.readHumidity() * 10)

        if temp != previousTemp {
            tempCount += 1

            if tempCount > 5 {
                i2cLock.lock()
                globalI2CValue[temperature] = temp
                i2cLock.unlock()
                previousTemp = temp
                tempCount = 0
            }
        }

        if humidity != previousHumidity {
            humidityCount += 1

            if humidityCount > 5 {
                i2cLock.lock()
                globalI2CValue[humidityKey] = humidity
                i2cLock.unlock()
                previousHumidity = humidity
                humidityCount = 0
            }
        }

    }

}