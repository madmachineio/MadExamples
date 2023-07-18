// Import the SwiftIO library to set SPI communication and MadBoard to use pin id.
import SwiftIO
import MadBoard
// Import the driver for the screen.
import ST7789
// Import the accelerometer driver to sense the movement.
import LIS3DH

@main
public struct MovingBall {

    public static func main() {
        // Initialize the i2c interface and use it to intialize the sensor.
        let i2c = I2C(Id.I2C0)
        let accelerometer = LIS3DH(i2c)

        // Initialize the pins for the screen.
        let spi = SPI(Id.SPI0, speed: 30_000_000)
        let cs = DigitalOut(Id.D5)
        let dc = DigitalOut(Id.D4)
        let rst = DigitalOut(Id.D3)
        let bl = DigitalOut(Id.D2)

        // Initialize the screen with the pins above.
        let screen = ST7789(spi: spi, cs: cs, dc: dc, rst: rst, bl: bl, rotation: .angle90)

        typealias Point = (x: Int, y: Int)

        // The original coordinate of the ball. It's at the center.
        var x = screen.width / 2 - 1
        var y = screen.height / 2 - 1

        // Create a ball.
        let ballWidth = 15 
        let ballColor: UInt16 = 0xF800

        // The count of pixels the ball will move each time.
        let step = 5
        // The threshold for the accelerations to move the ball.
        let threshold: Float = 0.2

        // The anchor of the ball when you move it is at the upper left corner of this tile. 
        // But it's at the center when creating the ball.
        x -= ballWidth
        y -= ballWidth
        
        drawSquare(at: (x, y), width: ballWidth, color: ballColor)
        var lastPos: Point = (x, y)

        while true {
            // Read the new accelerations to know the movement.
            let accelerations = accelerometer.readXYZ()

            // Check if the acceleration on x-axis exceeds the threshold.
            if abs(accelerations.x) > threshold {
                // Get the direction of the ball's movement horizontally.
                // When you tilt your board left, the ball moves to the left, and vice versa.
                // Calculate the x coordinate of the ball.
                x += accelerations.x < 0 ? step : -step

                // Keep the ball within the screen.
                if x < 0 {
                    x = 0
                } else if x > screen.width - ballWidth - 1 {
                    x = screen.width - ballWidth - 1
                }
            }

            // Check if the acceleration on y-axis exceeds the threshold.
            if abs(accelerations.y) > threshold {
                // Get the direction of the ball's movement vertically.
                // When you tilt your board forward, the ball moves forward, and vice versa.
                // Calculate the y coordinate of the ball. 
                y += accelerations.y < 0 ? -step : step
                
                // Keep the ball within the screen.
                if y < 0 {
                    y = 0
                } else if y > screen.height - ballWidth - 1 {
                    y = screen.height - ballWidth - 1
                }
            }

            // Update the ball's position on the LCD.
            if x != lastPos.x || y != lastPos.y {
                update(width: ballWidth, height: ballWidth,
                    from: lastPos, bgColor: 0, to: (x, y), color: ballColor
                )
                lastPos = (x, y)
            }
            
            sleep(ms: 20)
        }

        func drawSquare(at point: Point, width: Int, color: UInt16) {
            for py in point.y..<(point.y + width) {
                for px in point.x..<(point.x + width) {
                    screen.writePixel(x: px, y: py, color: color)
                }
            }
        }

        func update(
            width: Int, height: Int,
            from lastPos: Point, bgColor: UInt16,
            to newPos: Point, color: UInt16)
        {
            var x0 = 0
            var x1 = 0
            if lastPos.x < newPos.x {
                x0 = lastPos.x
                x1 = newPos.x + width
            } else {
                x0 = newPos.x
                x1 = lastPos.x + width
            }

            var y0 = 0
            var y1 = 0
            if lastPos.y < newPos.y {
                y0 = lastPos.y
                y1 = newPos.y + height
            } else {
                y0 = newPos.y
                y1 = lastPos.y + height
            }

            var buffer = [UInt16](repeating: bgColor, count: (x1 - x0) * (y1 - y0))

            for py in newPos.y..<newPos.y + height {
                for px in newPos.x..<newPos.x + width {
                    buffer[(py - y0) * (x1 - x0) + (px - x0)] = color
                }
            }

            buffer.withUnsafeBytes {
                screen.writeBitmap(x: x0, y: y0, width: x1 - x0, height: y1 - y0, data: $0)
            }
        }
    }
}