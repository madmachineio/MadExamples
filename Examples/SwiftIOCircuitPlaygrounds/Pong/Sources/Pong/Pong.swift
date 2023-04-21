// Import the SwiftIO to control all the pins.
import SwiftIO
// Import MadBoard to use the pin ids.
import MadBoard
// Import ST7789 driver to communicate with the screen.
import ST7789

@main
public struct Pong {
    public static func main() {
        // Initialize the SPI pin.
        let spi = SPI(Id.SPI0, speed: 30_000_000)
        
        // Initialize the pins used for the screen.
        let cs = DigitalOut(Id.D5)
        let dc = DigitalOut(Id.D4)
        let rst = DigitalOut(Id.D3)
        let bl = DigitalOut(Id.D2)
        // Initialize the LCD using the pins above. 
        // Rotate the screen to keep the original at the upper left.
        let screen = ST7789(spi: spi, cs: cs, dc: dc, rst: rst, bl: bl, rotation: .angle90)

        // Initialize the analog pins for the potentiometers.
        let leftPot = AnalogIn(Id.A0)
        let rightPot = AnalogIn(Id.A11)
        // Initialize the pin for the button used to reset the game.
        let resetButton = DigitalIn(Id.D1)

        // Start the game.
        var game = PongGame(leftPot: leftPot, rightPot: rightPot, screen: screen)

        var lastButtonState = false

        while true {
            /// Check if the reset button is pressed.
            if resetButton.read() {
                lastButtonState = true
            }

            /// Reset the game after the button is released.
            if !resetButton.read() && lastButtonState {
                game.reset()
                lastButtonState = false
            }

            // Play the game. 
            // Rotate the potentiometers to move two paddles on the screen to hit the ball.
            // If the ball hits the wall, the opposite player scores.
            game.play()

            sleep(ms: 10)
        }
    }
}
