// Import the SwiftIO library to control input and output.
import SwiftIO
// Import the SwiftIOFeather to use the id of the pins.
import MadBoard

import ST7789


let spi = SPI(Id.SPI0, speed: 50_000_000)
let cs = DigitalOut(Id.D9)
let dc = DigitalOut(Id.D10)
let rst = DigitalOut(Id.D14)
let bl = DigitalOut(Id.D2)

let screen = ST7789(spi: spi, cs: cs, dc: dc, rst: rst, bl: bl, rotation: .angle90)

let black: UInt16 = 0x0000
let red: UInt16 = 0xF800
let green: UInt16 = 0x07E0
let blue: UInt16 = 0x001F
let white: UInt16 = 0xFFFF

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

for y in stride(from: 0, to: screen.height, by: 10) {
    for x in 0..<screen.width {
        screen.writePixel(x: x, y: y, color: red)
    }
}
sleep(ms: 1000)

for x in stride(from: 0, to: screen.width, by: 10) {
    for y in 0..<screen.height {
        screen.writePixel(x: x, y: y, color: blue)
    }
}
sleep(ms: 1000)

screen.clearScreen(black)
sleep(ms: 1000)

let colors = [red, green, blue, white]
let width = 80

while true {
    var x = 0, y = 0

    for color in colors {
        fillSquare(x: x, y: y, width: width, color: color)
        x += width / 2
        y += width / 2
        sleep(ms: 1000)
    }
}

func fillSquare(x: Int, y: Int, width: Int, color: UInt16) {
    for px in y..<(y + width) {
        for py in x..<(x + width) {
            screen.writePixel(x: px, y: py, color: color)
        }
    }
}