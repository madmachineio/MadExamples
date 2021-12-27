//=== SHT3x.swift ---------------------------------------------------------===//
//
// Copyright (c) MadMachine Limited
// Licensed under MIT License
//
// Authors: Andy Liu
// Created: 02/25/2021
//
// See https://madmachine.io for more information
//
//===----------------------------------------------------------------------===//

import SwiftIO

/// The SHT3x library allows you to read temperature and relative humidity.
/// It supports I2C protocol.
///
/// The sensor contains components sensitive to two factors.
/// During its work, different temperature or humidity levels will lead to
/// corresponding voltages. Your board can read the voltage and calculate
/// the final results.

final public class SHT3x {
    
    let i2c: I2C
    let address: UInt8

    private var readBuffer = [UInt8](repeating: 0, count: 6)
    
    /// Initialize the I2C bus and reset the sensor.
    /// - Parameters:
    ///   - i2c: **REQUIRED** The I2C interface that the sensor connects.
    ///   - address: **OPTIONAL** The sensor's address. It has a default value.
    public init(_ i2c: I2C, address: UInt8 = 0x44) {
        self.i2c = i2c
        self.address = address
        
        reset()
    }
    
    /// Reset the sensor.
    public func reset() {
        sleep(ms: 2)
        try? writeCommand(.softReset)
        sleep(ms: 2)
    }
    
    /// Get the temperature in Celcius.
    /// - Returns: A float representing the current temperature
    public func readCelsius() -> Float {
        try? readRawValue(into: &readBuffer)
        let rawTemp = UInt16(readBuffer[0]) << 8 | UInt16(readBuffer[1])
        return 175.0 * Float(rawTemp) / 65535.0 - 45.0
    }
    
    
    /// Read the temperature in Fahrenheit.
    /// - Returns: A float representing the temperature.
    public func readFahrenheit() -> Float {
        try? readRawValue(into: &readBuffer)
        let rawTemp = UInt16(readBuffer[0]) << 8 | UInt16(readBuffer[1])
        return 315.0 * Float(rawTemp) / 65535.0 - 49.0
    }
 
    /// Read the current relative humidity.
    /// - Returns: A float between 0 and 1 representing the humidity.
    public func readHumidity() -> Float {
        try? readRawValue(into: &readBuffer)
        let rawHumi = UInt16(readBuffer[3]) << 8 | UInt16(readBuffer[4])
        return 100.0 * Float(rawHumi) / 65535.0
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
    private func writeCommand(_ command: Command) throws {
        let value = command.rawValue
        let result = i2c.write([UInt8(value >> 8), UInt8(value & 0xFF)], to: address)
        if case .failure(let err) = result {
            throw err
        }
    }

    private func readRawValue(into buffer: inout [UInt8]) throws {
        for i in 0..<buffer.count {
            buffer[i] = 0
        }

        try? writeCommand(.measureMedium)
        sleep(ms: 8)

        let result = i2c.read(into: &buffer, from: address)
        if case .failure(let err) = result {
            throw err
        }
    }
}
