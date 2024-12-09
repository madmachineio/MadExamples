import SwiftIO
import MadBoard

func ioThread(_ a: UnsafeMutableRawPointer?, _ b: UnsafeMutableRawPointer?, _ c: UnsafeMutableRawPointer?) -> () {
    sleep(ms: 100)

    let a0 = AnalogIn(Id.A0)
    var a0Count = 0
    var a0PreviousValue = -1

    let a11 = AnalogIn(Id.A11)
    var a11Count = 0
    var a11PreviousValue = -1

    let d1 = DigitalIn(Id.D1)
    var d1PressCount = 0

    let d19 = DigitalIn(Id.D19)
    var d19PressCount = 0



    while true {
        sleep(ms: 4)


        let a0Value = Int(a0.readPercentage() * 100)
        if a0Value != a0PreviousValue {
            a0Count += 1
        } else {
            a0Count = 0
        }

        if a0Count > 5 {
            a0Count = 0
            a0PreviousValue = a0Value
            ioLock.lock()
            globalIOValue[a0Module] = a0Value
            ioLock.unlock()
        }



        let a11Value = Int(a11.readPercentage() * 100)
        if a11Value != a11PreviousValue {
            a11Count += 1
        } else {
            a11Count = 0
        }

        if a11Count > 5 {
            a11Count = 0
            a11PreviousValue = a11Value
            ioLock.lock()
            globalIOValue[a11Module] = a11Value
            ioLock.unlock()
        }



        if d1.read() {
            d1PressCount += 1
        } else {
            d1PressCount -= 1
            d1PressCount = max(0, d1PressCount)
        }

        if d1PressCount > 10 && !d1.read() {
            d1PressCount = 0
            ioLock.lock()
            globalIOValue[d1Module] = 1
            ioLock.unlock()
        }



        if d19.read() {
            d19PressCount += 1
        } else {
            d19PressCount -= 1
            d19PressCount = max(0, d19PressCount)
        }
        if d19PressCount > 10 && !d19.read() {
            d19PressCount = 0
            ioLock.lock()
            if globalIOValue[d19Module]! < 0 {
                globalIOValue[d19Module] = 3
            }
            ioLock.unlock()
        }
    }
}