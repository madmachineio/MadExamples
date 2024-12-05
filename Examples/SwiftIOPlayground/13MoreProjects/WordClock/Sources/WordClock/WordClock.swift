import SwiftIO
import MadBoard
import ST7789
import MadGraphics
import PCF8563

@main
public struct WordClock {
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

        // Initialize the rtc.
        let i2c = I2C(Id.I2C0)
        let rtc = PCF8563(i2c)

        // Update the RTC with your current time.
        let currentTime = PCF8563.Time(
            year: 2024, month: 12, day: 5, hour: 18,
            minute: 29, second: 0, dayOfWeek: 4
        )

        sleep(ms: 500)
        rtc.setTime(currentTime)

        let layer = Layer(at: Point.zero, anchorPoint: UnitPoint.zero, width: screen.width, height: screen.height)

        // Calculate the point size for each character.
        // Get masks from the font file for all characters of the word clock.
        let dpi = 220
        let pointSize = min(screen.width / Words.column, screen.height / Words.row) * 72 / dpi * 4 / 5
        let characterMasks = getCharacterMasks(path: "/lfs/Resources/Fonts/Graduate-Regular.ttf", pointSize: pointSize, dpi: dpi)

        let clock = WordView(layer: layer, characterMasks: characterMasks)

        // Define the colors to be used for displaying the words.
        let colors: [Color] = [.red, .orange, .yellow, .lime, .blue, .magenta, .cyan, Color(UInt32(0xFE679A))]
        
        // Highlight each column with different colors in turn.
        var index = 0
        for x in 0..<characterMasks[0].count {
            for y in 0..<characterMasks.count {
                clock.showCharacter(point: Point(x, y), color: colors[index])
            }

            index += 1
            layer.render(into: &frameBuffer, output: &screenBuffer, transform: Color.getRGB565LE) { dirty, data in
                screen.writeBitmap(x: dirty.x, y: dirty.y, width: dirty.width, height: dirty.height, data: data)
            }

            sleep(ms: 100)
            for y in 0..<characterMasks.count {
                clock.showCharacter(point: Point(x, y), color: Color.gray)
            }
        }
        layer.render(into: &frameBuffer, output: &screenBuffer, transform: Color.getRGB565LE) { dirty, data in
            screen.writeBitmap(x: dirty.x, y: dirty.y, width: dirty.width, height: dirty.height, data: data)
        }

        var lastSecond: UInt8 = 60

        while true {
            let rtcTime = rtc.readTime()

            // Display the current time specified in hours and minutes with a precision of 5 minutes.
            if rtcTime.second != lastSecond {
                index = (index + 1) % colors.count
                clock.showTime(hour: Int(rtcTime.hour), minute:  Int(rtcTime.minute), color: colors[index]) 
                layer.render(into: &frameBuffer, output: &screenBuffer, transform: Color.getRGB565LE) { dirty, data in
                    screen.writeBitmap(x: dirty.x, y: dirty.y, width: dirty.width, height: dirty.height, data: data)
                }
                clock.showTime(hour: Int(rtcTime.hour), minute:  Int(rtcTime.minute), color: Color.gray)  
            }

            lastSecond = rtcTime.second
            print("hour: \(Int(rtcTime.hour)), minute: \(Int(rtcTime.minute)), second: \(Int(rtcTime.second)) ")

            sleep(ms: 100)
        }
    }
}


// Read the font file from the specified path. 
// Extract the mask from the font for all the characters to be displayed on the word clock.
func getCharacterMasks(path: String, pointSize: Int, dpi: Int) -> [[Mask]] {
    var characterMasks = [[Mask]](repeating: [Mask](), count: Words.row)

    let font = Font(path: path, pointSize: pointSize, dpi: dpi)
    for y in 0..<Words.row {
        for x in 0..<Words.column {
            let mask = font.getMask(Words.characters[y][x])
            characterMasks[y].append(mask)
        }
    }

    return characterMasks
}