import SwiftIO
import MadBoard
import ST7789

@main
public struct BreakoutGame {
    public static func main() {
        // Initialize the SPI pin and the digital pins for the LCD.
        let spi = SPI(Id.SPI0, speed: 30_000_000)
        let cs = DigitalOut(Id.D9)
        let dc = DigitalOut(Id.D10)
        let rst = DigitalOut(Id.D14)
        let bl = DigitalOut(Id.D2)

        // Initialize the LCD using the pins above. Rotate the screen to keep the original at the upper left.
        let screen = ST7789(spi: spi, cs: cs, dc: dc, rst: rst, bl: bl, rotation: .angle90)

        let pot = AnalogIn(Id.A0)
        var breakoutGame = Breakout(pot: pot, screen: screen)

        while true {
            breakoutGame.play()
            sleep(ms: 5)
        }
    }
}
