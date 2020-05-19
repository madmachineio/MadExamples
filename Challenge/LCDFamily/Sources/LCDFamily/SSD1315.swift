import SwiftIO

final class SSD1315{

    private enum Command: UInt8 {
        case entireDisplayOff   = 0xA4
        case normalDisplay      = 0xA6
        case displayOff         = 0xAE
        case displayOn          = 0xAF
        case clockDivRatio      = 0xD5
        case multiplexRatio     = 0xA8
        case displayOffset      = 0xD3
        case startLine          = 0x40
        case chargePump         = 0x8D
        case memoryMode         = 0x20
        case mapNormal          = 0xA0
        case mapRemaped         = 0xA1
        case scanNormal         = 0xC0
        case scanFlipped        = 0xC8
        case hwConfig           = 0xDA
        case contrastCtrl       = 0x81
        case chargePeriod       = 0xD9
        case vcomDeselectLevel  = 0xDB
    }

    private let config: [(Command, UInt8?)] = [
        (.displayOff, nil),
        (.clockDivRatio, 0x80),
        (.multiplexRatio, 0x3F),
        (.displayOffset, 0x00),
        (.startLine, nil),
        (.chargePump, 0x14),
        (.memoryMode, 0x00),
        (.mapRemaped, nil),
        (.scanNormal, nil),
        (.hwConfig, 0x12),
        (.contrastCtrl, 0xCF),
        (.chargePeriod, 0xF1),
        (.vcomDeselectLevel, 0x40),
        (.entireDisplayOff, nil),
        (.normalDisplay, nil),
        (.displayOn, nil)
    ]

	private let spi: SPI
    private let rst, dc: DigitalOut
    public let width, height: Int

    private var frameBuffer = Array<UInt8>(repeating: 0x00, count: 128 * 8)
   
    init(spi: SPI, dc: DigitalOut, rst: DigitalOut) {
        self.spi = spi
        self.dc = dc
        self.rst = rst
        width = 128
        height = 64

        reset()
        config.forEach { item in
            writeConfig(item)
        }
        clearScreen()
    }

    public func reset() {
        rst.write(false)
        sleep(ms: 100)
        rst.write(true)
        sleep(ms: 100)
    }

    @inline(__always)
    private func writePixelToFramBuffer(x: Int, y: Int, color: Bool) {
        if x >= width || y >= height {
            return
        }
        var pos = 0, bx = 0
        var data: UInt8 = 0

        pos = 7 - y / 8
        bx = y % 8
        data = UInt8(1 << (7 - bx))

        if color {
            frameBuffer[pos * width + x] |= data
        } else {
            frameBuffer[pos * width + x] &= ~data
        }
    }

    func writePixel(x: Int, y: Int, color: Bool) {
        writePixelToFramBuffer(x: x, y: y, color: color)
        updateScreen()
    }

    func writeScreen(_ data: [UInt8]) {
        guard data.count >= height * width else {
            return
        }

        for y in 0..<height {
            for x in 0..<width {
                if data[y * width + x] == 0 {
                    writePixelToFramBuffer(x: x, y: y, color: false)
                } else {
                    writePixelToFramBuffer(x: x, y: y, color: true)
                }
            }
        }
        updateScreen()
    }

    func writeScreen(_ data: UnsafeRawBufferPointer) {
        guard data.baseAddress != nil else { return }
        let ptr = data.bindMemory(to: UInt8.self)

        for y in 0..<height {
            for x in 0..<width {
                if ptr[y * width + x] == 0 {
                    writePixelToFramBuffer(x: x, y: y, color: false)
                } else {
                    writePixelToFramBuffer(x: x, y: y, color: true)
                }
            }
        }
        updateScreen()
    }

    func clearScreen(color: Bool = false) {
        let value: UInt8 = color ? 0xFF : 0x00
        for i in 0..<frameBuffer.count {
            frameBuffer[i] = value
        }
        updateScreen()
    }

    func updateScreen() {
        dc.write(true)
        spi.write(frameBuffer)
    }

    private func writeConfig(_ config: (Command, UInt8?)) {
        writeCommand(config.0.rawValue)
        if let value = config.1 {
            writeCommand(value)
        }
    }

    private func writeCommand(_ data: UInt8) {
        dc.write(false)
        spi.write(data)
    }

    private func writeCommand(_ data: [UInt8]) {
        dc.write(false)
        spi.write(data)
    }

    private func writeData(_ data: [UInt8]) {
        dc.write(true)
        spi.write(data)
    }
}