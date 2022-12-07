// Import SwiftIO to set the communication and MadBoard to use pin id. 
import SwiftIO
import MadBoard
// Import the library to configure the LCD and write pixels on it.
import ST7789

@main
public struct PlayTicTacToe {
    public static func main() {
         // Initialize the SPI pin and the digital pins for the LCD.
        let spi = SPI(Id.SPI0, speed: 30_000_000)
        let cs = DigitalOut(Id.D9)
        let dc = DigitalOut(Id.D10)
        let rst = DigitalOut(Id.D14)
        let bl = DigitalOut(Id.D2)

        // Initialize the LCD using the pins above. Rotate the screen to keep the original at the upper left.
        let screen = ST7789(spi: spi, cs: cs, dc: dc, rst: rst, bl: bl, rotation: .angle90)

        // Initialize the two players.
        // The potentiometer is used to select grid and the button is to confirm the selection.
        let player1 = Player(
            pot: AnalogIn(Id.A0),
            button: DigitalIn(Id.D1),
            color: Color.orange
        )

        let player2 = Player(
            pot: AnalogIn(Id.A11),
            button: DigitalIn(Id.D21),
            color: Color.lime
        )

        var game = TicTacToe(player1: player1, player2: player2, screen: screen)

        // Play the game and check if anyone wins the game or the game ends in a tie.
        // If a player wins, the screen will be filled with its color. 
        // If it's a tie, the screen will be filled with background color (white). 
        while true {
            game.play()
            sleep(ms: 10)
        }
    }
}
