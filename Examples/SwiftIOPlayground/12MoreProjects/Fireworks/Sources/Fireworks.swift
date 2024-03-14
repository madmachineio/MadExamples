import SwiftIO
import MadBoard
import ST7789
import MadGraphics

// Use lock to protect data from simultaneous access by multiple threads.
let i2sLock = Mutex()
// Whether the speaker will play sound.
var playSound = false

@main
public struct DefaultApp {
    public static func main() {
        // Initialize the SPI pin and the digital pins for the LCD.
        let bl = DigitalOut(Id.D2)
        let rst = DigitalOut(Id.D12)
        let dc = DigitalOut(Id.D13)
        let cs = DigitalOut(Id.D5)
        let spi = SPI(Id.SPI0, speed: 30_000_000)

        // Initialize the LCD using the pins above. Rotate the screen to keep the original at the upper left.
        let screen = ST7789(spi: spi, cs: cs, dc: dc, rst: rst, bl: bl, rotation: .angle90)

        var colorIndex = 0
        let colors: [Color] = [
            .pink, .red, .lime, .blue, .cyan, 
            .purple, .magenta, .orange, .yellow
        ]

        let canvas = Canvas(width: screen.width, height: screen.height)
        var frameBuffer = [UInt16](repeating: 0, count: 240 * 240)

        var fileLength = 0
        let fontDataBuffer = readFontFile(path: "/lfs/Resources/Fonts/Roboto-Regular.ttf", length: &fileLength)

        var font: Font?
        if let fontDataBuffer {
            // Generate font info with the given point size (a point is 1/72 of an inch) and screen dpi.
            font = Font(from: fontDataBuffer, length: fileLength, pointSize: 10, dpi: 220)
            
            drawText()
            updateDisplay(canvas: canvas, frameBuffer: &frameBuffer, screen: screen)
        }

        var fireworks: [Firework] = []
        var exploded = false

        createThread(
            name: "play_sound",
            priority: 3,
            stackSize: 1024 * 64,
            soundThread
        )

        sleep(ms: 10)

        while true {
            if Int.random(in: 0..<100) < 10 {         
                fireworks.append(Firework(color: colors[colorIndex], canvas: canvas))
                // Update firwork's color.
                colorIndex += 1
                if colorIndex == colors.count {
                    colorIndex = 0
                }
            }

            var i = 0
            while i < fireworks.count {
                if fireworks[i].update() {
                    exploded = true
                }
                
                // If a all sparks of a firework disppear, remove the firework.
                if fireworks[i].done() {
                    fireworks.remove(at: i)
                } else {
                    i += 1
                }
            }

            // If any firework has exploded, update the global variable.
            if exploded {
                i2sLock.lock()
                playSound = true
                i2sLock.unlock()

                exploded = false
            }

            drawText()

            updateDisplay(canvas: canvas, frameBuffer: &frameBuffer, screen: screen)

            sleep(ms: 15)
        }

        func drawText() {
            if let font {
                // Get UInt8 mask from the font info.
                let text1 = font.getMask("Happy")
                let text2 = font.getMask("Women's Day!")
                
                // Blend the mask with a desired color to getg bg text color data.
                canvas.blend(from: text1, foreground: Color.red, to: Point(x: (canvas.width - text1.width) / 2, y: 50))
                canvas.blend(from: text2, foreground: Color.red, to: Point(x: (canvas.width - text2.width) / 2, y: 120))
            }
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

        func readFontFile(path: String, length: inout Int) -> UnsafeMutableRawBufferPointer? {
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
    }
}