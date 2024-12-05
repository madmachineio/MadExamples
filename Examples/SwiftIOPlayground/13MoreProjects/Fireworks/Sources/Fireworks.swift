import SwiftIO
import MadBoard
import ST7789
import MadGraphics

// Use lock to protect data from simultaneous access by multiple threads.
let i2sLock = Mutex()
// Whether the speaker will play sound.
var playSound = false

@main
public struct Fireworks {
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

        var colorIndex = 0
        let colors: [Color] = [
            .pink, .red, .lime, .blue, .cyan, 
            .purple, .magenta, .orange, .yellow
        ]

        let layer = Layer(at: Point.zero, anchorPoint: UnitPoint.zero, width: screen.width, height: screen.height)


        let font = Font(path: "/lfs/Resources/Fonts/Roboto-Regular.ttf", pointSize: 10, dpi: 220)
        let text1 = TextLayer(at: Point(x: layer.bounds.size.halfWidth, y: 40), anchorPoint: UnitPoint.center, string: "Happy", font: font, foregroundColor: Color.red)
        let text2 = TextLayer(at: Point(x: layer.bounds.size.halfWidth, y: 80), anchorPoint: UnitPoint.center, string: "Christmas", font: font, foregroundColor: Color.red)

        layer.append(text1)
        layer.append(text2)

        var fireworks: [Firework] = []
        var exploded = false

        createThread(
            name: "play_sound",
            priority: 3,
            stackSize: 1024 * 64,
            soundThread
        )

        sleep(ms: 10)

        while true {
            if Int.random(in: 0..<100) < 10 {         
                fireworks.append(Firework(color: colors[colorIndex], maxWidth: layer.bounds.width))
                // Update firwork's color.
                colorIndex += 1
                if colorIndex == colors.count {
                    colorIndex = 0
                }
            }

            var i = 0
            while i < fireworks.count {
                if fireworks[i].update(layer) {
                    exploded = true
                }
                
                // If a all sparks of a firework disppear, remove the firework.
                if fireworks[i].done() {
                    fireworks.remove(at: i)
                } else {
                    i += 1
                }
            }

            // If any firework has exploded, update the global variable.
            if exploded {
                i2sLock.lock()
                playSound = true
                i2sLock.unlock()

                exploded = false
            }

            layer.render(into: &frameBuffer, output: &screenBuffer, transform: Color.getRGB565LE) { dirty, data in
                screen.writeBitmap(x: dirty.x, y: dirty.y, width: dirty.width, height: dirty.height, data: data)
            }

            sleep(ms: 10)
        }
    }
}