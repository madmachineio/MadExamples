import SwiftIO
import MadBoard
import MadGraphics
import ST7789
    

@main
public struct AnimatedEyes {
    public static func main() {
        // Initialize the SPI pin and the digital pins for the LCD.
        let bl = DigitalOut(Id.D2)
        let rst = DigitalOut(Id.D12)
        let dc = DigitalOut(Id.D13)
        let cs = DigitalOut(Id.D5)
        let spi = SPI(Id.SPI0, speed: 30_000_000)
        // Initialize the LCD using the pins above. Rotate the screen to keep the original at the upper left.
        let screen = ST7789(spi: spi, cs: cs, dc: dc, rst: rst, bl: bl, rotation: .angle90)

        var eyes = Eyes.close
        let animatedEyes = EyesAnimation(screen: screen)
        
        while true {
            animatedEyes.draw(eyes: eyes)

            var rawValue = eyes.rawValue + 1
            if rawValue == Eyes.allCases.count {
                rawValue = 0
            }
            eyes = Eyes(rawValue: rawValue)!

            sleep(ms: 1000)
        }
    }
}