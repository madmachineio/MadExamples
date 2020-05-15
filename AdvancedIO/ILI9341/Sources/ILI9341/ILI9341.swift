import SwiftIO

final class ILI9341 {

    public enum Direction {
        case vertical, verticalInverse, horizontal, horizontalInverse
    }

    private let step1Config: [(Command, [UInt8])] = [
        (.POWER_CTRL_B, [0x00, 0xC1, 0x30]),
        (.POWER_ON_SEQ_CTRL, [0x64, 0x03, 0x12, 0x81]),
        (.DRVR_TIMING_CTRL_A_I, [0x85, 0x00, 0x79]),
        (.POWER_CTRL_A, [0x39, 0x2C, 0x00, 0x34, 0x02]),
        (.PUMP_RATIO_CTRL, [0x20]),
        (.DRVR_TIMING_CTRL_B, [0x00, 0x00]),
        (.POWER_CTRL_1, [0x1D]),
        (.POWER_CTRL_2, [0x12]),
        (.VCOM_CTRL_1, [0x33, 0x3F]),
        (.VCOM_CTRL_2, [0x92]),
        (.PIXEL_FORMAT_SET, [0x55]),
    ]

    private var directionConfig: (Command, [UInt8]) {
        switch direction {
            case .vertical:
            return (.MEM_ACCESS_CTRL, [0x08])
            case .verticalInverse:
            return (.MEM_ACCESS_CTRL, [0xC8])
            case .horizontal:
            return (.MEM_ACCESS_CTRL, [0x78])
            case .horizontalInverse:
            return (.MEM_ACCESS_CTRL, [0xA8])
        } 
    }

    private let step2Config: [(Command, [UInt8])] = [
        (.FRAME_CTRL_NORMAL_MODE, [0x00, 0x12]),
        (.DISPLAY_FUNCTION_CTRL, [0x0A, 0xA2]),
        (.ENABLE_3G, [0x00]),
        (.GAMMA_SET, [0x01]),
        (.POSITIVE_GAMMA_CORRECTION, [0x0F, 0x22, 0x1C, 0x1B, 0x08, 0x0F, 0x48, 0xB8, 0x34, 0x05, 0x0C, 0x09, 0x0F, 0x07, 0x00]),
        (.NEGATIVE_GAMMA_CORRECTION, [0x00, 0x23, 0x24, 0x07, 0x10, 0x07, 0x38, 0x47, 0x4B, 0x0A, 0x13, 0x06, 0x30, 0x38, 0x0F]),
        (.EXIT_SLEEP, []),
        (.DISPLAY_ON, [])
    ]

	let spi: SPI
    let rst, dc: DigitalOut
    let direction: Direction
    public let width: Int
    public let height: Int

    public init(spi: SPI, dc: DigitalOut, rst: DigitalOut, direction: Direction = .horizontal) {
        self.spi = spi
        self.rst = rst
        self.dc = dc
        self.direction = direction

        switch direction {
            case .vertical, .verticalInverse:
            width = 240
            height = 320
            case .horizontal, .horizontalInverse:
            width = 320
            height = 240
        }

        reset()

        step1Config.forEach { config in
            writeConfig(config)
        }

        writeConfig(directionConfig)
        
        step2Config.forEach { config in
            writeConfig(config)
        }
    }

    @inline(__always)
    public func writePixel(x: Int, y: Int, color: UInt16) {
        setAddrWindow(x: x, y: y, width: 1, height: 1)
        writeData(color)
    }

    public func writeBitmap(x: Int, y: Int, width w: Int, height h: Int, data: [UInt8]) {
        setAddrWindow(x: x, y: y, width: w, height: h) 
        writeData(data)
    }

    public func writeBitmap(x: Int, y: Int, width w: Int, height h: Int, data: UnsafeRawBufferPointer) {
        setAddrWindow(x: x, y: y, width: w, height: h) 
        writeData(data)
    }

    public func writeScreen(_ data: [UInt8]) {
        guard data.count <= width * height * 2 else { return }
        setAddrWindow(x: 0, y: 0, width: width, height: height) 
        writeData(data)
    }

    public func writeScreen(_ data: UnsafeRawBufferPointer) {
        guard data.count <= width * height * 2 else { return }
        setAddrWindow(x: 0, y: 0, width: width, height: height) 
        writeData(data)
    }

    public func clearScreen(_ color: UInt16 = 0x0000) {
        let highByte = UInt8(color >> 8)
        let lowByte = UInt8(color & 0xFF)

        setAddrWindow(x: 0, y: 0, width: width, height: height)

        dc.write(true)
        for _ in 0..<width * height {
            spi.write(highByte)
            spi.write(lowByte)
        }
    }

    public func reset() {
        rst.write(false)
        sleep(ms: 100)
        rst.write(true)
        sleep(ms: 100)
    }

    public func setAddrWindow(x: Int, y: Int, width w: Int, height h: Int) {
        let x0 = UInt16(x)
        let y0 = UInt16(y)
        let x1 = UInt16(x + w - 1)
        let y1 = UInt16(y + h - 1)

        writeCommand(Command.COLUMN_ADDR.rawValue)
        writeData(x0)
        writeData(x1)

        writeCommand(Command.PAGE_ADDR.rawValue)
        writeData(y0)
        writeData(y1)

        writeCommand(Command.MEM_WRITE.rawValue)
    }
}

extension ILI9341 {
    private enum Command: UInt8 {
        case SOFTWARE_RESET = 0x01
        case ENTER_SLEEP = 0x10
        case EXIT_SLEEP = 0x11
        case GAMMA_SET = 0x26
        case DISPLAY_OFF = 0x28
        case DISPLAY_ON = 0x29
        case COLUMN_ADDR = 0x2A
        case PAGE_ADDR = 0x2B
        case MEM_WRITE = 0x2C
        case MEM_ACCESS_CTRL = 0x36
        case PIXEL_FORMAT_SET = 0x3A
        case FRAME_CTRL_NORMAL_MODE = 0xB1
        case DISPLAY_FUNCTION_CTRL = 0xB6
        case POWER_CTRL_1 = 0xC0
        case POWER_CTRL_2 = 0xC1
        case VCOM_CTRL_1 = 0xC5
        case VCOM_CTRL_2 = 0xC7
        case POSITIVE_GAMMA_CORRECTION = 0xE0
        case NEGATIVE_GAMMA_CORRECTION = 0xE1

        case POWER_CTRL_A = 0xCB
        case POWER_CTRL_B = 0xCF
        case DRVR_TIMING_CTRL_A_I = 0xE8
        case DRVR_TIMING_CTRL_A_E = 0xE9
        case DRVR_TIMING_CTRL_B = 0xEA
        case POWER_ON_SEQ_CTRL = 0xED
        case ENABLE_3G = 0xF2
        case PUMP_RATIO_CTRL = 0xF7
    }

    private enum DataAccessConfig: UInt8 {
        case MEM_ACCESS_CTRL_MY = 0x80
        case MEM_ACCESS_CTRL_MX = 0x40
        case MEM_ACCESS_CTRL_MV = 0x20
        case MEM_ACCESS_CTRL_ML = 0x10
        case MEM_ACCESS_CTRL_BGR = 0x08
        case MEM_ACCESS_CTRL_MH = 0x04

        case PIXEL_FORMAT_RGB_18_BIT = 0x60
        case PIXEL_FORMAT_RGB_16_BIT = 0x50
        case PIXEL_FORMAT_MCU_18_BIT = 0x06
        case PIXEL_FORMAT_MCU_16_BIT = 0x05
    }

    private func writeConfig(_ config: (Command, [UInt8])) {
        writeCommand(config.0.rawValue)
        if config.1.count > 0 {
            writeData(config.1)
        }
    }

    private func writeCommand(_ command: UInt8) {
        dc.write(false)
        spi.write(command)
    }

    private func writeData(_ data: UInt16) {
        let array = [UInt8(data >> 8), UInt8(data & 0xFF)]
        dc.write(true)
        spi.write(array)
    }

    private func writeData(_ data: [UInt8]) {
        dc.write(true)
        spi.write(data)
    }

    private func writeData(_ data: UnsafeRawBufferPointer) {
        dc.write(true)
        spi.write(data)
    }
}