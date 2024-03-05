import SwiftIO
import MadBoard
import ST7789


// Initialize the SPI pin and the digital pins for the LCD.
let bl = DigitalOut(Id.D2)
let rst = DigitalOut(Id.D12)
let dc = DigitalOut(Id.D13)
let cs = DigitalOut(Id.D5)
let spi = SPI(Id.SPI0, speed: 30_000_000)

// Initialize the LCD using the pins above. Rotate the screen to keep the original at the upper left.
let screen = ST7789(spi: spi, cs: cs, dc: dc, rst: rst, bl: bl, rotation: .angle90)

let cursor = AnalogIn(Id.A0)
let button = DigitalIn(Id.D1)
var pressCount = 0

var sand = Sand(screen: screen, cursor: cursor)

while true {
    // Add more sand particles if the button is been pressed.
    if pressCount > 10 {        
        sand.drawNewSand()
        pressCount = 0
    }

    if button.read() {
        pressCount += 1
    } else {
        pressCount = 0
    }
    
    sleep(ms: 5)

    // Update the position of sand and cursor over time.
    sand.update(cursor: cursor)
}