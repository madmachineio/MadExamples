/// This is the library for SHT31 digital humidity and temperature Sensor. 
/// It supports I2C protocol. Refer to the datasheet for more detailed information.

import SwiftIO

class SHT3x {
	// Some common command with 16-bit data used to communicate with the sensor.
    private enum Command {
        static let readStatus: UInt16 = 0xF32D
        static let clearStatus: UInt16 = 0x3041
        static let softReset: UInt16 = 0x30A2
        static let heaterEnable: UInt16 = 0x306D
        static let heaterDisable: UInt16 = 0x3066
        // high repeatability measurement with clock stretching disabled.
        static let measurement: UInt16 = 0x2400

    }
    
    // SHT31 Default Address.
    let address: UInt8 = 0x44
	let i2c: I2C
    
    // Initialize the I2C bus and reset the sensor to prepare for the following commands.
    init(_ i2c: I2C) {
        self.i2c = i2c
        writeCommand(Command.softReset)
        sleep(ms: 10)
    }
    
	// Split the 16-bit data into two 8-bit data. 
    // Write the data to the default address of the sensor.
    func writeCommand(_ value: UInt16) {
        let array: [UInt8] = [UInt8(value >> 8), UInt8(value & 0xFF)]
        i2c.write(array, to: address)
    }
    
	// Send the command to start the measurement. The data returned will be stored in 6 bytes. 
    // The first two bytes are reserved for temperature.
    // Convert the data into a float representing the current temperature.
    func readTemperature() -> Float {
        writeCommand(Command.measurement)
        sleep(ms: 20)
        let array = i2c.read(count: 6, from: address)
        let value = UInt16(array[0]) << 8 | UInt16(array[1])
        let temp: Float = 175.0 / 65535.0 * Float(value) - 45.0
        return temp
    }
    
	// Send the command to start the measurement. The data returned will be stored in 6 bytes. 
    // The fourth and fifth bytes are reserved for humidity.
    // Convert the data into a float representing the current humidity.
    func readHumidity() -> Float {
        writeCommand(Command.measurement)
        sleep(ms: 20)
        let array = i2c.read(count: 6, from: address)
        let value = UInt16(array[3]) << 8 | UInt16(array[4])
        let humidity: Float = 100.0 * Float(value) / 65535.0
        return humidity
    }

}