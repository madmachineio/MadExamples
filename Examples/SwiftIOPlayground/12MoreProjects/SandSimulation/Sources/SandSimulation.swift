import SwiftIO
import MadBoard
import ST7789
import MadGraphics
import LIS3DH

@main
public struct SandSimulation {
    public static func main() {
        // Initialize the SPI pin and the digital pins for the LCD.
        let bl = DigitalOut(Id.D2)
        let rst = DigitalOut(Id.D12)
        let dc = DigitalOut(Id.D13)
        let cs = DigitalOut(Id.D5)
        let spi = SPI(Id.SPI0, speed: 30_000_000)

        // Initialize the LCD using the pins above. Rotate the screen to keep the original at the upper left.
        let screen = ST7789(spi: spi, cs: cs, dc: dc, rst: rst, bl: bl, rotation: .angle90)

        let canvas = Canvas(width: screen.width, height: screen.height)
        var frameBuffer = [UInt16](repeating: 0, count: canvas.width * canvas.height)

        // Initialize the accelerometer.
        let i2c = I2C(Id.I2C0)
        let accelerometer = LIS3DH(i2c)

        // Draw the sand particle.
        var sand = Sand(canvas: canvas, accelerometer.readXYZ())
        updateDisplay(canvas: canvas, frameBuffer: &frameBuffer, screen: screen)

        // Update sand particle positions based on movement.
        while true {
            sand.update(accelerometer.readXYZ())
            updateDisplay(canvas: canvas, frameBuffer: &frameBuffer, screen: screen)
            sleep(ms: 1)
        }
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