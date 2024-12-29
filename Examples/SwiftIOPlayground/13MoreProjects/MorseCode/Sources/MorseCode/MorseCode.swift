// Import the SwiftIO library to set input/output and MadBoard to use pin id.
import SwiftIO
import MadBoard
// Import the driver for the screen.
import ST7789
import MadGraphics

@main
public struct MorseCode {
    public static func main() {
        // Initialize an LED as an indicator.
        let led = DigitalOut(Id.D18)
        // Initialize a button used to type characters.
        let button = DigitalIn(Id.D1)
        // Initialize a buzzer used to tell typing states.
        let buzzer = PWMOut(Id.PWM5A)

        // Initialize the SPI pin and the digital pins for the LCD.
        let bl = DigitalOut(Id.D2)
        let rst = DigitalOut(Id.D12)
        let dc = DigitalOut(Id.D13)
        let cs = DigitalOut(Id.D5)
        let spi = SPI(Id.SPI0, speed: 30_000_000)

        // Initialize the LCD using the pins above. Rotate the screen to keep the original at the upper left.
        let screen = ST7789(spi: spi, cs: cs, dc: dc, rst: rst, bl: bl, rotation: .angle90)
        var screenBuffer = [UInt16](repeating: 0, count: 240 * 240)
        var frameBuffer = [UInt32](repeating: 0, count: 240 * 240)

        // Store the morse code for 26 letters and 0-9.
        let dict: [String: String] = [
            ".-": "A",      "-...": "B",        "-.-.": "C",        "-..": "D",         ".": "E",
            "..-.": "F",    "--.": "G",         "....": "H",        "..": "I",          ".---": "J",
            "-.-": "K",     ".-..": "L",        "--":  "M",         "-.": "N",          "---": "O",
            ".--.": "P",    "--.-": "Q",        ".-.": "R",         "...":  "S",        "-": "T",
            "..-": "U",     "...-": "V",        ".--": "W",         "-..-": "X",        "-.--": "Y",
            "--..": "Z",
            ".----": "1",   "..---": "2",       "...--": "3",       "....-": "4",       ".....": "5",
            "-....": "6",   "--...": "7",       "---..": "8",       "----.": "9",       "-----": "0"
        ]

        // Each morse code consists of a sequence of dits and dahs.
        let dit = "."
        let dah = "-"
        // Store the input morse code for a character.
        var morseCode = ""
        // Store all characters.
        var text = ""

        // A threshold for a long press which matches a dah.
        let longPressCount = 15

        // Thresholds to decide if you have finished type a character or a word.
        let letterReleaseCount = 30
        let wordReleaseCount  = 100

        // Store the duration of a specified button state to compare with the thresholds above.
        var pressCount = 0
        var releaseCount = 1

        // Store the states of the button.
        var justPressed = false
        var justReleased = false

        var lastLetter = ""

        var drawPixel = false
        var drawLow = true
        var drawLine = true

        var buzzerCount = 0

        let font = Font(path: "/lfs/Resources/Fonts/Roboto-Regular.ttf" , pointSize: 12, dpi: 220)
        let rootLayer = Layer(at: Point.zero, anchorPoint: UnitPoint.zero, width: 240, height: 240)

        let animationLayer = Layer(at: Point(0, 229), anchorPoint: UnitPoint.zero, width: 240, height: 10)
        rootLayer.append(animationLayer)

        let colors = [
            Color.red,
            Color.orange,
            Color.yellow,
            Color.lime,
            Color.cyan,
            Color.blue,
            Color.purple
        ]
        var colorIndex = 0

        var lineText = TextLayer(at: Point.zero, anchorPoint: UnitPoint.zero, font: font, foregroundColor: colors[colorIndex])
        rootLayer.append(lineText)

        // Create a periodic timer that alerts every 10ms.
        let timer = Timer(period: 10)
        timer.setInterrupt() {
            if button.read() {
                // If button is pressed, store the duration to judge if it's long press or short press.
                // The LED will be on as an indicator.
                if pressCount == 0 {
                    justPressed = true
                }
                pressCount += 1
            } else {
                // If the button is not pressed, store the duration to judge if 
                // you have finished typing a character or a word.
                // Turn off the LED.
                // If you haven't pressed the button after downloading your project, 
                // releaseCount also increases. So the variable justReleased is used to 
                // check if the button is pressed and then release.
                if releaseCount == 0 {
                    justReleased = true
                }
                releaseCount += 1
                led.write(false)
            }

            // Mute the buzzer after a specified period.
            buzzerCount += 1
            if buzzerCount > 10 {
                buzzer.suspend()
            }

            drawPixel = true
        }

        while true {
            // Check if you finish typing a single character or a word.
            if releaseCount > wordReleaseCount {
                // If the time after the button is releases exceeds the threshold, 
                // add a space after what you have typed.
                // The buzzer produces a higher sound as a notification.
                if lastLetter != "" && lastLetter != " "{
                    text = ""
                    
                    buzzer.set(frequency: 2000, dutycycle: 0.5)
                    buzzerCount = 0
                    lastLetter = " "

                    colorIndex += 1
                    colorIndex = colorIndex % colors.count

                    let y = lineText.position.y + Int(Float(lineText.frame.size.height) * 1.2)
                    lineText = TextLayer(at: Point(0, y), anchorPoint: UnitPoint.zero, font: font, foregroundColor: colors[colorIndex])
                    rootLayer.append(lineText)
                }
                morseCode = ""
            } else if releaseCount > letterReleaseCount {
                // Check if the morse code matches a character.
                // If so, display it on the LCD and make the buzzer to produce a sound.
                if let letter = dict[morseCode] {
                    text += letter
                    print("Message: \"\(text)\"")
                    
                    lastLetter = letter
                    
                    lineText.string = text
                    morseCode = ""
                    buzzer.set(frequency: 1200, dutycycle: 0.5)
                    buzzerCount = 0
                }
            }

            // Right after you release the button, get the morse code based on the time that the button is pressed and store it.
            if justReleased {
                if pressCount > longPressCount {
                    morseCode += dah
                } else {
                    morseCode += dit
                }
                led.write(false)

                drawLine = true
                drawLow = true

                justReleased = false
                pressCount = 0
            }

            // Check if you have press the buuton. If so, it will get ready to store the duration after the button is release.
            if justPressed {
                led.write(true)

                drawLine = true
                drawLow = false

                justPressed = false
                releaseCount = 0
            }

            if drawPixel {
                drawAnimationLayer(layer: animationLayer, low: drawLow, line: drawLine)

                drawPixel = false
                drawLine = false
            }

            rootLayer.render(into: &frameBuffer, output: &screenBuffer, transform: Color.getRGB565LE) { dirty, data in
                screen.writeBitmap(x: dirty.x, y: dirty.y, width: dirty.width, height: dirty.height, data: data)
            }

            sleep(ms: 1)
        }
    }
}

func drawAnimationLayer(layer: Layer, low: Bool, line: Bool) {
    let newContent = Canvas(width: layer.bounds.width, height: layer.bounds.height)

    var oldRect = layer.bounds
    oldRect.size.width -= 1
    oldRect.origin.x = 1
    newContent.merge(from: layer.contents!, in: oldRect, to: Point.zero)

    if line {
        newContent.drawLine(from: Point(layer.bounds.width - 1, 0), to: Point(layer.bounds.width - 1, layer.bounds.height - 1), data: Color.red.rawValue)
    } else {
        if low {
            newContent.setPixel(at: Point(layer.bounds.width - 1, layer.bounds.height - 1), Color.red.rawValue)
        } else {
            newContent.setPixel(at: Point(layer.bounds.width - 1, 0), Color.red.rawValue)
        }
    } 
    
    layer.draw() { canvas in
        canvas.merge(from: newContent)    
    }
}