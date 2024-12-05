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
        var screenBuffer = [UInt16](repeating: 0, count: screen.width * screen.width)
        var frameBuffer = [UInt32](repeating: 0, count: screen.width * screen.width)

        let layer = Layer(at: Point.zero, anchorPoint: UnitPoint.zero, width: screen.width, height: screen.height)

        // Initialize the accelerometer.
        let i2c = I2C(Id.I2C0)
        let accelerometer = LIS3DH(i2c)

        // Draw the sand particle.
        var sand = Sand(layer: layer, accelerometer.readXYZ())
        layer.render(into: &frameBuffer, output: &screenBuffer, transform: Color.getRGB565LE) { dirty, data in
            screen.writeBitmap(x: dirty.x, y: dirty.y, width: dirty.width, height: dirty.height, data: data)
        }

        // Update sand particle positions based on movement.
        while true {
            sand.update(layer: layer, accelerometer.readXYZ())
            layer.render(into: &frameBuffer, output: &screenBuffer, transform: Color.getRGB565LE) { dirty, data in
                screen.writeBitmap(x: dirty.x, y: dirty.y, width: dirty.width, height: dirty.height, data: data)
            }
            sleep(ms: 1)
        }
    }
}