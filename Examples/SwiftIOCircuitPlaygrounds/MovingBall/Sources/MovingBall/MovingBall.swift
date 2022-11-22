// Import the SwiftIO library to set SPI communication and MadBoard to use pin id.
import SwiftIO
import MadBoard
// Import the driver for the screen and graphical library for display.
import ST7789
import MadDisplay
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
        let cs = DigitalOut(Id.D9)
        let dc = DigitalOut(Id.D10)
        let rst = DigitalOut(Id.D14)
        let bl = DigitalOut(Id.D2)

        // Initialize the screen with the pins above.
        let screen = ST7789(spi: spi, cs: cs, dc: dc, rst: rst, bl: bl, rotation: .angle90)

        // Create an instance using the screen to display graphics.
        let display = MadDisplay(screen: screen)

        // The size of the screen.
        var height = 240
        var width = 240

        // The original coordinate of the ball. It's at the center.
        var x = width / 2 - 1
        var y = height / 2 - 1

        // Create a ball.
        let radius = 15 
        let ball = Circle(x: x, y: y, radius: radius, fill: Color.yellow)

        // Add the ball to a group for display.
        let group = Group()
        group.append(ball)

        // The count of pixels the ball will move each time.
        var change = 5
        // The threshold for the accelerations to move the ball.
        let threshold: Float = 0.2

        // The anchor of the ball when you move it is at the upper left corner of this tile. 
        // But it's at the center when creating the ball.
        x -= radius
        y -= radius

        while true {
            // Read the new accelerations to know the movement.
            let accelerations = accelerometer.readXYZ()

            // Check if the acceleration on x-axis exceeds the threshold.
            if abs(accelerations.x) > threshold {
                // Get the direction of the ball's movement horizontally.
                // When you tilt your board left, the ball moves to the left, and vice versa.
                if accelerations.x < 0 {
                    change = abs(change)
                } else {
                    change = -abs(change)
                }

                // Calculate the x coordinate of the ball.
                x += change
                // Keep the ball within the screen.
                if x < 0 {
                    x = 0
                } else if x > width - radius * 2 - 1 {
                    x = width - radius * 2 - 1
                }
            }

            // Check if the acceleration on y-axis exceeds the threshold.
            if abs(accelerations.y) > threshold {
                // Get the direction of the ball's movement vertically.
                // When you tilt your board forward, the ball moves forward, and vice versa.
                if accelerations.y < 0 {
                    change = -abs(change)
                } else {
                    change = abs(change)
                }

                // Calculate the y coordinate of the ball. 
                y += change
                // Keep the ball within the screen.
                if y < 0 {
                    y = 0
                } else if y > height - radius * 2 - 1 {
                    y = height - radius * 2 - 1
                }
            }

            // Update the ball's position on the LCD.
            ball.setXY(x: x, y: y)
            display.update(group)
            sleep(ms: 20)
        }
    }
}
