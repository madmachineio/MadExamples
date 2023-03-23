// Visualize the x, y , z accelerations in the range by moving the corresponding sliders.

import SwiftIO
import MadBoard
import LIS3DH
import ST7789

@main
public struct C01S08AccelerationVisualizer {
    public static func main() {
        // Initialize the SPI pin and the digital pins for the LCD.
        let spi = SPI(Id.SPI0, speed: 30_000_000)
        let cs = DigitalOut(Id.D9)
        let dc = DigitalOut(Id.D10)
        let rst = DigitalOut(Id.D14)
        let bl = DigitalOut(Id.D2)
        // Initialize the LCD using the pins above. Rotate the screen to keep the original at the upper left.
        let screen = ST7789(spi: spi, cs: cs, dc: dc, rst: rst, bl: bl, rotation: .angle90)

        // Initialize the accelerometer using I2C communication.
        let i2c = I2C (Id.I2C0)
        let accelerometer = LIS3DH(i2c)

        // 16-bit colors for acceleration bars.
        let red: UInt16 = 0x07E0
        let green: UInt16 = 0x001F
        let blue: UInt16 = 0xF800

        // Get the acceleration range of the sensor.
        let gRange: Int
        switch accelerometer.getRange() {
        case .g2: gRange = 4
        case .g4: gRange = 8
        case .g8: gRange = 16
        case .g16: gRange = 32
        }

        // Draw the bars of accelerations on x, y, z-axis.
        let barWidth = 200
        let barHeight = 40
        let spacer = 20
        let startY = (screen.height - barHeight * 3 - spacer * 2) / 2

        var xBar = Bar(y: startY, width: barWidth, height: barHeight, color: red, screen: screen)
        var yBar = Bar(y: startY + barHeight + spacer, width: barWidth, height: barHeight, color: green, screen: screen)
        var zBar = Bar(y: startY + (barHeight + spacer) * 2, width: barWidth, height: barHeight, color: blue, screen: screen)

        while true {
            // Update the indicators' position in each bar according to the current accelerations.
            let values = accelerometer.readXYZ()
            xBar.update(values.x, gRange: gRange)
            yBar.update(values.y, gRange: gRange)
            zBar.update(values.z, gRange: gRange)
            sleep(ms: 10)
        }
    }

    struct Bar {
        let x: Int
        let y: Int
        let width: Int
        let height: Int
        let screen: ST7789
        let color: UInt16

        var indicatorPos: Int?
        let indicatorColor: UInt16 = 0xFFFF

        // Draw a bar on the screen.
        init(y: Int, width: Int, height: Int, color: UInt16, screen: ST7789) {
            self.y = y
            self.width = width
            self.height = height
            self.color = color
            self.screen = screen
            x = (screen.width - width) / 2

            let data = [UInt16](repeating: color, count: width * height)
            data.withUnsafeBytes {
                screen.writeBitmap(x: x, y: y, width: width, height: height, data: $0)
            }
        }

        // Update indicator's position in the bar with the latest value.
        mutating func update(_ accel: Float, gRange: Int) {
            let currentPos = x + Int((accel + 2) * Float((width - 1) / gRange))

            if indicatorPos != currentPos {
                // Draw the indicator at its current position.
                for py in y..<y+height {
                    screen.writePixel(x: currentPos, y: py, color: indicatorColor)
                }

                if let indicatorPos {
                    // Remove the indicator from its previous position.
                    for py in y..<y+height {
                        screen.writePixel(x: indicatorPos, y: py, color: color)
                    }
                }

                indicatorPos = currentPos
            }
        }
    }
}
