// Fill the screen with rainbow colors.

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

let red: UInt32 = 0xFF0000
let orange: UInt32 = 0xFF7F00
let yellow: UInt32 = 0xFFFF00
let green: UInt32 = 0x00FF00
let blue: UInt32 = 0x0000FF
let indigo: UInt32 = 0x4B0082
let violet: UInt32 = 0x9400D3
let colors888 = [red, orange, yellow, green, blue, indigo, violet]
// Get 16bit color data.
let colors565: [UInt16] = colors888.map { getRGB565BE($0) }

// The width for each color bar.
let width = screen.width / colors565.count

while true {
    // Use 7 colors in order to draw rectangles on display.
    for i in colors565.indices {
        for y in 0..<screen.height {
            for x in (width*i)..<(width*(i+1)) {
                screen.writePixel(x: x, y: y, color: colors565[i])
            }
        }
    }

    sleep(ms: 1000)
    // Fill the display with black.
    screen.clearScreen(0)
}

// The screen needs RGB565 color data, so change color data from UInt32 to UInt16.
// Besides, the board uses little endian format, so the bytes are swapped.
func getRGB565BE(_ color: UInt32) -> UInt16 {
    return (UInt16((color & 0xF80000) >> 8) | UInt16((color & 0xFC00) >> 5) | UInt16((color & 0xF8) >> 3)).byteSwapped
}