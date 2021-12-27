
/// This is the library for SHT3x digital humidity and temperature Sensor. 
/// It supports I2C protocol. Refer to the datasheet for more detailed information.
import SwiftIO

final public class SHT3x {
    
	let i2c: I2C
    let address: UInt8
    
    // Initialize the I2C bus and reset the sensor to prepare for the following commands.
    public init(_ i2c: I2C, address: UInt8 = 0x44) {
        self.i2c = i2c
        self.address = address

        reset()
    }
    
    public func reset() {
        sleep(ms: 2)
        writeCommand(.softReset)
        sleep(ms: 2)
    }
    
	// Send the command to start the measurement. The data returned will be stored in 6 bytes. 
    // The first two bytes are reserved for temperature.
    // Convert the data into a float representing the current temperature.
    public func readCelsius() -> Float {
        let value = startMeasure().rawTemp
        return 175.0 * Float(value) / 65535.0 - 45.0
    }

    public func readFahrenheit() -> Float {
        let value = startMeasure().rawTemp
        return 315.0 * Float(value) / 65535.0 - 49.0
    }
    
	// Send the command to start the measurement. The data returned will be stored in 6 bytes. 
    // The fourth and fifth bytes are reserved for humidity.
    // Convert the data into a float representing the current humidity.
    public func readHumidity() -> Float {
        let value = startMeasure().rawHumi
        return 100.0 * Float(value) / 65535.0
    }
}

extension SHT3x {
	// Some common command with 16-bit data used to communicate with the sensor.
    private enum Command: UInt16 {
        case readStatus     = 0xF32D
        case clearStatus    = 0x3041
        case softReset      = 0x30A2
        case heaterEnable   = 0x306D
        case heaterDisable  = 0x3066

        case measureHigh    = 0x2400
        case measureMedium  = 0x240B
        case measureLow     = 0x2416

        case measureStretchHigh     = 0x2C06
        case measureStretchMedium   = 0x2C0D
        case measureStretchLow      = 0x2C10
    }

	// Split the 16-bit data into two 8-bit data. 
    // Write the data to the default address of the sensor.
    private func writeCommand(_ command: Command) {
        let value = command.rawValue
        i2c.write([UInt8(value >> 8), UInt8(value & 0xFF)], to: address)
    }

    private func startMeasure() -> (rawTemp: UInt16, rawHumi: UInt16) {
        writeCommand(.measureMedium)
        sleep(ms: 8)
        let array = i2c.read(count: 6, from: address)
        if array.count == 6 {
            let temp = UInt16(array[0]) << 8 | UInt16(array[1])
            let humi = UInt16(array[3]) << 8 | UInt16(array[4])
            return (temp, humi)
        } else {
            return (0, 0)
        }
    }
}