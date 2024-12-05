import SwiftIO
import MadBoard
import ST7789
import MadGraphics
import LIS3DH

@main
public struct MazeGame {
    public static func main() {
        // Initialize the SPI pin and the digital pins for the LCD.
        let bl = DigitalOut(Id.D2)
        let rst = DigitalOut(Id.D12)
        let dc = DigitalOut(Id.D13)
        let cs = DigitalOut(Id.D5)
        let spi = SPI(Id.SPI0, speed: 30_000_000)

        // Initialize the LCD using the pins above. Rotate the screen to keep the original at the upper left.
        let screen = ST7789(spi: spi, cs: cs, dc: dc, rst: rst, bl: bl, rotation: .angle90)

        let i2c = I2C(Id.I2C0)
        let accelerometer = LIS3DH(i2c)

        let layer = Layer(at: Point.zero, anchorPoint: UnitPoint.zero, width: screen.width, height: screen.height)
        let mazeGame = Game(screen: screen, layer: layer)

        let resetButton = DigitalIn(Id.D1)

        var reset = false
        resetButton.setInterrupt(.falling) {
            reset = true
        }

        var sleepTime: Float = 0
        let maxTime: Float = 20
        let minTime: Float = 5

        while true {
            // If the reset button is pressed, restart the game.
            if reset {
                mazeGame.reset()
                reset = false
            }
            
            // Update ball's position based on the acceleration.
            let acceleration = accelerometer.readXYZ()
            mazeGame.update(acceleration)

            // Map the acceleration into a sleep time in order to control the speed of the ball.
            sleepTime = min(max(abs(acceleration.x), abs(acceleration.y)), 1) * (minTime - maxTime) + maxTime
            sleep(ms: Int(sleepTime))
        }
    }
}