import SwiftIO

let dc = DigitalOut(Id.D0)
let rst = DigitalOut(Id.D1)
let spi = SPI(Id.SPI0, speed: 20000000)

let oled = SSD1315(spi: spi, dc: dc, rst: rst)

func clearScreenTest() {
    oled.clearScreen(color: true)
    sleep(ms: 1000)
    oled.clearScreen(color: false)
    sleep(ms: 1000)
}

func pixelTest() {
    for y in 0..<oled.height {
        for x in 0..<oled.width {
            oled.writePixel(x: x, y: y, color: true)
        }
    }
}

while true {
    clearScreenTest()
    pixelTest()
}
