// Visualize analog values on the screen.
// The line height changes with the value from the potentiometer.

import SwiftIO
import MadBoard
import ST7789

@main
public struct AnalogVisualizer {
    public static func main() {
        // Initialize the SPI pin and the digital pins for the LCD.
        let spi = SPI(Id.SPI0, speed: 30_000_000)
        let cs = DigitalOut(Id.D5)
        let dc = DigitalOut(Id.D4)
        let rst = DigitalOut(Id.D3)
        let bl = DigitalOut(Id.D2)

        // Initialize the LCD using the pins above. Rotate the screen to keep the original at the upper left.
        let screen = ST7789(spi: spi, cs: cs, dc: dc, rst: rst, bl: bl, rotation: .angle90)

        // Initialize the analog pin for the potentiometer.
        let pot = AnalogIn(Id.A0)

        // The max line height drawn on the screen.
        let maxHeight = 200

        let white: UInt16 = 0xFFFF
        let black: UInt16 = 0

        // Store the previous heights to make a scrolling display.
        var heightValues = [Int](repeating: 0, count: screen.width)

        while true {
            // Read current analog value and map it to height.
            let height = pot.readRawValue() * maxHeight / pot.maxRawValue

            // Update line heights for display.
            heightValues.removeFirst()
            heightValues.append(height)

            // Iterate over the array to draw vertical lines with the given height.
            for i in 0..<heightValues.count-1 {
                let lastH = heightValues[i]
                let currentH = heightValues[i+1]

                // Compare the line heights and update the line.
                if lastH > currentH {
                    drawLine(x: i, y: screen.height - lastH, height: lastH - currentH, color: black)
                } else if lastH < currentH {
                    drawLine(x: i, y: screen.height - currentH, height: currentH - lastH, color: white)
                }
            }

            sleep(ms: 100)
        }

        // Draw a vertical line on the screen.
        func drawLine(x: Int, y: Int, height: Int, color: UInt16) {
            let buffer = [UInt16](repeating: color, count: height)
            buffer.withUnsafeBytes {
                screen.writeBitmap(x: x, y: y, width: 1, height: height, data: $0)
            }
        }
    }
}
