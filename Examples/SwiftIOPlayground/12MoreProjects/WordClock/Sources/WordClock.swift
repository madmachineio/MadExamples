import SwiftIO
import MadBoard
import ST7789
import MadGraphics
import PCF8563

@main
public struct WordClock {
    public static func main() {
        // Initialize the SPI pin and the digital pins for the LCD.
        let bl = DigitalOut(Id.D2)
        let rst = DigitalOut(Id.D12)
        let dc = DigitalOut(Id.D13)
        let cs = DigitalOut(Id.D5)
        let spi = SPI(Id.SPI0, speed: 30_000_000)

        // Initialize the LCD using the pins above. Rotate the screen to keep the original at the upper left.
        let screen = ST7789(spi: spi, cs: cs, dc: dc, rst: rst, bl: bl, rotation: .angle90)

        // Initialize the rtc.
        let i2c = I2C(Id.I2C0)
        let rtc = PCF8563(i2c)

        // Update the RTC with your current time.
        let currentTime = PCF8563.Time(
            year: 2024, month: 4, day: 17, hour: 15,
            minute: 44, second: 0, dayOfWeek: 2
        )
        rtc.setTime(currentTime)

        let canvas = Canvas(width: screen.width, height: screen.height)
        var frameBuffer = [UInt16](repeating: 0, count: canvas.width * canvas.height)

        // Calculate the point size for each character.
        // Get masks from the font file for all characters of the word clock.
        let dpi = 220
        let pointSize = min(canvas.width / Words.column, canvas.height / Words.row) * 72 / dpi * 4 / 5
        let characterMasks = getCharacterMasks(path: "/lfs/Resources/Fonts/Graduate-Regular.ttf", pointSize: pointSize, dpi: dpi)

        let clock = WordView(canvas: canvas, characterMasks: characterMasks)

        // Define the colors to be used for displaying the words.
        let colors: [Color] = [.red, .orange, .yellow, .lime, .blue, .magenta, .cyan, Color(UInt32(0xFE679A))]
        
        // Highlight each column with different colors in turn.
        var index = 0
        for x in 0..<characterMasks[0].count {
            for y in 0..<characterMasks.count {
                clock.showCharacter(point: Point(x, y), color: colors[index])
            }

            index += 1
            updateDisplay(canvas: canvas, frameBuffer: &frameBuffer, screen: screen)

            sleep(ms: 100)
            for y in 0..<characterMasks.count {
                clock.showCharacter(point: Point(x, y), color: Color.gray)
            }
        }
        updateDisplay(canvas: canvas, frameBuffer: &frameBuffer, screen: screen)

        var lastSecond: UInt8 = 60

        while true {
            let time = rtc.readTime()

            // Display the current time specified in hours and minutes with a precision of 5 minutes.
            if time.second != lastSecond {
                index = (index + 1) % colors.count
                clock.showTime(hour: Int(time.hour), minute:  Int(time.minute), color: colors[index]) 
                updateDisplay(canvas: canvas, frameBuffer: &frameBuffer, screen: screen)
                clock.showTime(hour: Int(time.hour), minute:  Int(time.minute), color: Color.gray)  
            }

            lastSecond = time.second

            sleep(ms: 10)
        }
    }
}


// Read the font file from the specified path. 
// Extract the mask from the font for all the characters to be displayed on the word clock.
func getCharacterMasks(path: String, pointSize: Int, dpi: Int) -> [[Mask]] {
    var fileLength = 0
    var characterMasks = [[Mask]](repeating: [Mask](), count: Words.row)


    if let fontDataBuffer = openFontFile(path: path, length: &fileLength) {
        let font = Font(from: fontDataBuffer, length: fileLength, pointSize: pointSize, dpi: dpi)

        for y in 0..<Words.row {
            for x in 0..<Words.column {
                let mask = font.getMask(Words.characters[y][x])
                characterMasks[y].append(mask)
            }
        }

        fontDataBuffer.deallocate()
    }

    return characterMasks
}

func openFontFile(path: String, length: inout Int) -> UnsafeMutableRawBufferPointer? {
    var fontDataBuffer: UnsafeMutableRawBufferPointer? = nil

    print("open file:")
    do {
        let file = try FileDescriptor.open(path, .readOnly)

        try file.seek(offset: 0, from: FileDescriptor.SeekOrigin.end)
        let bytes = try file.tell()
        fontDataBuffer = UnsafeMutableRawBufferPointer.allocate(byteCount: bytes, alignment: 8)
        length = bytes

        try file.seek(offset: 0, from: FileDescriptor.SeekOrigin.start)
        try file.read(into: fontDataBuffer!, count: bytes)
        try file.close()
    } catch {
        print("Error, file handle error")
        if let buffer = fontDataBuffer {
            buffer.deallocate()
        }
        return nil
    }

    print("open file success")
    return fontDataBuffer
}

// Get the region that needs to be updated and send data to the screen.
func updateDisplay(canvas: Canvas, frameBuffer: inout [UInt16], screen: ST7789) {
    guard let dirty = canvas.getDirtyRect() else {
        return
    }

    var index = 0
    let stride = canvas.width
    let canvasBuffer = canvas.buffer
    for y in dirty.y0..<dirty.y1 {
        for x in dirty.x0..<dirty.x1 {
            frameBuffer[index] = Color.getRGB565LE(canvasBuffer[y * stride + x])
            index += 1
        }
    }
    
    frameBuffer.withUnsafeBytes { ptr in
        screen.writeBitmap(x: dirty.x, y: dirty.y, width: dirty.width, height: dirty.height, data: ptr)
    }

    canvas.finishRefresh()
}