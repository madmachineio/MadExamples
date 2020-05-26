import SwiftIO

final class PCA9685 {
    private struct Mode1: OptionSet {
        let rawValue: UInt8

        static let ALLCALL = Mode1(rawValue: 0x01)
        static let SUB3    = Mode1(rawValue: 0x02)
        static let SUB2    = Mode1(rawValue: 0x04)
        static let SUB1    = Mode1(rawValue: 0x08)
        static let SLEEP   = Mode1(rawValue: 0x10)
        static let AI      = Mode1(rawValue: 0x20)
        static let EXTCLK  = Mode1(rawValue: 0x40)
        static let RESTART = Mode1(rawValue: 0x80)

        static let all     = Mode1(rawValue: 0xFF)
    }
    
    private struct Mode2: OptionSet {
        let rawValue: UInt8

        static let OUTNE0 = Mode2(rawValue: 0x01)
        static let OUTNE1 = Mode2(rawValue: 0x02)
        static let OUTDRV = Mode2(rawValue: 0x04)
        static let OCH    = Mode2(rawValue: 0x08)
        static let INVRT  = Mode2(rawValue: 0x10)

        static let all    = Mode2(rawValue: 0xFF)
    }

    private enum Register: UInt8 {
        case MODE1 = 0x00
        case MODE2 = 0x01
        case SUBADR1 = 0x02
        case SUBADR2 = 0x03
        case SUBADR3 = 0x04
        case ALLCALLADR = 0x05
        case LED0_ON_L = 0x06
        case LED0_ON_H = 0x07
        case LED0_OFF_L = 0x08
        case LED0_OFF_H = 0x09
        case ALLLED_ON_L = 0xFA
        case ALLLED_ON_H = 0xFB
        case ALLLED_OFF_L = 0xFC
        case ALLLED_OFF_H = 0xFD
        case PRESCALE = 0xFE
        case TESTMODE = 0xFF
    }

	let i2c: I2C
    let address = UInt8(0x40)
    let oscFrequency = Int(25_000_000)
    let prescaleMin = Float(3)
    let prescaleMax = Float(255)
    
    init(_ i2c: I2C) {
        self.i2c = i2c

        reset()
        setPWMFreq(1000)
    }

    func reset() {
        writeMode1(.RESTART)
        sleep(ms: 10)
    }

    func standby() {
        let oldMode = Mode1(rawValue: readRegister(.MODE1))
        let setting = oldMode.union(.SLEEP)               //[oldMode, .SLEEP]
        writeMode1(setting)
        sleep(ms: 5)
    }

    func wakeup() {
        let oldMode = Mode1(rawValue: readRegister(.MODE1))
        var setting: Mode1 = .all
        setting.subtract(.SLEEP)
        setting.formIntersection(oldMode)

        writeMode1(setting)
    }

    func setPWMFreq(_ freq: Float) {
        var freq = freq

        if freq < 1 {
            freq = 1.0
        } else if freq > 3500 {
            freq = 3500.0
        }

        var prescaleval = (Float(oscFrequency) / (freq * 4096.0)) + 0.5 - 1
        if prescaleval < prescaleMin {
            prescaleval = prescaleMin
        } else if prescaleval > prescaleMax {
            prescaleval = prescaleMax
        }

        let prescale = UInt8(prescaleval)

        let oldMode = Mode1(rawValue: readRegister(.MODE1))
        var newMode: Mode1 = .all
        newMode.subtract(.RESTART)
        newMode.formIntersection(oldMode)
        newMode.formUnion(.SLEEP)
        
        writeMode1(newMode)
        writeRegister(.PRESCALE, prescale)
        writeMode1(oldMode)
        sleep(ms: 5)

        newMode = oldMode.union([.RESTART, .AI])
        writeMode1(newMode)
    }

    func setOutputMode(_ totempole: Bool) {
        let oldMode = Mode2(rawValue: readRegister(.MODE2))
        var newMode: Mode2

        if totempole {
            newMode = oldMode.union(.OUTDRV) 
        } else {
            newMode = .all
            newMode.subtract(.OUTDRV)
            newMode.formIntersection(oldMode)
        }

        writeMode2(newMode)
    }

    func readPrescale() -> UInt8 {
        return readRegister(.PRESCALE)
    }

    func getPWM(_ channel: UInt8) -> UInt8 {
        let data: [UInt8] = [Register.LED0_ON_L.rawValue + 4 * channel, 4]
        i2c.write(data, to: address)
        return i2c.readByte(from: address)
    }

    func setPWM(_ channel: UInt8, _ on: UInt16, _ off: UInt16) {
        let data: [UInt8] = [Register.LED0_ON_L.rawValue + 4 * channel,
                             UInt8(on & 0xFF),
                             UInt8(on >> 8),
                             UInt8(off & 0xFF),
                             UInt8(off >> 8)]
        i2c.write(data, to: address)
    }

    func setPin(_ channel: UInt8, _ val: UInt16, _ invert: Bool) {
        var val = val
        val = min(val, 4095)

        if invert {
            if val == 0 {
                setPWM(channel, 4096, 0)
            } else if val == 4095 {
                setPWM(channel, 0, 4096)
            } else {
                setPWM(channel, 0, 4095 - val)
            }
        } else {
            if val == 4095 {
                setPWM(channel, 4096, 0)
            } else if val == 0 {
                setPWM(channel, 0, 4096)
            } else {
                setPWM(channel, 0, val)
            }
        }
    }

    func writeMicroseconds(_ channel: UInt8, _ microseconds: UInt16) {
        var pulse = Double(microseconds)
        var pulseLength = Double(1_000_000.0)

        var prescale = Double(readPrescale())

        prescale += 1
        pulseLength *= prescale
        pulseLength /= Double(oscFrequency)

        pulse /= pulseLength
        setPWM(channel, 0, UInt16(pulse))
    }


    @inline(__always)
    private func readRegister(_ r: Register) -> UInt8 {
        i2c.write(r.rawValue, to: address)
        return i2c.readByte(from: address)
    }

    @inline(__always)
    private func writeRegister(_ r: Register, _ setting: UInt8) {
        let data: [UInt8] = [r.rawValue, setting]
        i2c.write(data, to: address)
    } 


    private func writeMode1(_ setting: Mode1) {
        let data: [UInt8] = [Register.MODE1.rawValue, setting.rawValue]
        i2c.write(data, to: address)
    }

    private func writeMode2(_ setting: Mode2) {
        let data: [UInt8] = [Register.MODE2.rawValue, setting.rawValue]
        i2c.write(data, to: address)
    }
}