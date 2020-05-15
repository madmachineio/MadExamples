import SwiftIO

let spi = SPI(Id.SPI0, speed: 36000000)
let dc = DigitalOut(Id.D0)
let rst = DigitalOut(Id.D1)

let lcd = ILI9341(spi: spi, dc: dc, rst: rst, direction: .vertical)

func clearScreenTest() {
    let white: UInt16 = 0xFFFF
    let red:   UInt16 = 0xF800
    let green: UInt16 = 0x07E0
    let blue:  UInt16 = 0x001F
    let black: UInt16 = 0x0000

    lcd.clearScreen(color: white)
    lcd.clearScreen(color: red)
    lcd.clearScreen(color: green)
    lcd.clearScreen(color: blue)
    lcd.clearScreen(color: black)
}

func pixelTest() {
    let rainbow: [UInt16] = [
        0xF800,
        0xFBE0,
        0xFFE0,
        0x07E0,
        0x07FF,
        0x001F,
        0x781F
    ]

    let colorHeight = lcd.height / rainbow.count

    for index in 0..<rainbow.count {
        for y in colorHeight * index ..< colorHeight * (index + 1) {
            for x in 0..<lcd.width {
                lcd.writePixel(x: x, y: y, color: rainbow[index])
            }
        }
    }
}

while true {
    clearScreenTest()
    pixelTest()
    sleep(ms: 2000)
}