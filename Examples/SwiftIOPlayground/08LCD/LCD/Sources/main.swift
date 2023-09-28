// Import SwiftIO to set the communication and MadBoard to use pin id. 
import SwiftIO
import MadBoard
// Import the library to configure the LCD and write pixels on it.
import ST7789


// Initialize the SPI pin and the digital pins for the LCD.
let bl = DigitalOut(Id.D2)
let rst = DigitalOut(Id.D12)
let dc = DigitalOut(Id.D13)
let cs = DigitalOut(Id.D5)
let spi = SPI(Id.SPI0, speed: 30_000_000)

// Initialize the LCD using the pins above. Rotate the screen to keep the original at the upper left.
let screen = ST7789(spi: spi, cs: cs, dc: dc, rst: rst, bl: bl, rotation: .angle90)

// Store some color values for easier reference later.
let black = UInt16(0x0000).byteSwapped
let red   = UInt16(0xF800).byteSwapped
let green = UInt16(0x07E0).byteSwapped
let blue = UInt16(0x001F).byteSwapped
let white = UInt16(0xFFFF).byteSwapped

// Fill the whole screen with red, green, blue, white, and black in turns. 
// The color changes every second. 
screen.clearScreen(red)
sleep(ms: 1000)

screen.clearScreen(green)
sleep(ms: 1000)

screen.clearScreen(blue)
sleep(ms: 1000)

screen.clearScreen(white)
sleep(ms: 1000)

screen.clearScreen(black)
sleep(ms: 1000)

// Draw red horizontal lines every 10 rows, so the lines will be on rows 0, 10, 20, ..., 230.
for y in stride(from: 0, to: screen.height, by: 10) {
    for x in 0..<screen.width {
        screen.writePixel(x: x, y: y, color: red)
    }
}
sleep(ms: 1000)

// Draw blue vertical lines every 10 columns, so the lines will be on columns 0, 10, 20, ..., 230.
for x in stride(from: 0, to: screen.width, by: 10) {
    for y in 0..<screen.height {
        screen.writePixel(x: x, y: y, color: blue)
    }
}
sleep(ms: 1000)

// Paint the screen black to erase all stuff on it.
screen.clearScreen(black)
sleep(ms: 1000)

// Store the colors of four squares for later use.
let colors = [red, green, blue, white]

// Set the size of the square.
let width = 80

// First, draw a 80x80 red square from the origin. 
// After one second, draw a green one from the centre of the red square.
// The blue and white ones are similar.
while true {
    var x = 0, y = 0

    for color in colors {
        fillSquare(x: x, y: y, width: width, color: color)
        x += width / 2
        y += width / 2
        sleep(ms: 1000)
    }
}

// This function allows you to draw a square on the LCD from the point (x,y).
func fillSquare(x: Int, y: Int, width: Int, color: UInt16) {
    for px in y..<(y + width) {
        for py in x..<(x + width) {
            screen.writePixel(x: px, y: py, color: color)
        }
    }
}