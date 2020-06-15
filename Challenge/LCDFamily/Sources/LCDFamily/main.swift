import SwiftIO

let spi = SPI(Id.SPI0, speed: 36000000)
let dc = DigitalOut(Id.D0)
let rst = DigitalOut(Id.D1)
//let tft = ILI9341(spi: spi, dc: dc, rst: rst)
let bl = DigitalOut(Id.D2)
let tft = ST7789(spi: spi, dc: dc, rst: rst, bl: bl,
            width: 320, height: 240, rotation: .angle270)

let spi1 = SPI(Id.SPI1, speed: 10000000)
let dc1 = DigitalOut(Id.D38)
let rst1 = DigitalOut(Id.D39)
let oled = SSD1315(spi: spi1, dc: dc1, rst: rst1)

let i2c = I2C(Id.I2C0)
let lcd1602 = LCD1602(i2c)

var tftScreen = TinyCanvas(width: tft.width, height: tft.height)
tft.writeScreen(tftScreen.data)

var oledScreen = TinyCanvas(width: oled.width, height: oled.height, colorMode: .MONO)

let rainbow: [UInt32] = [
    0xFF0000,
    0xFF7F00,
    0xFFFF00,
    0x00FF00,
    0x00FFFF,
    0x0000FF,
    0x7F00FF
]


func drawRect() {
    var x = 0, y = 0, wT = 320, hT = 240, wO = 128, hO = 64, count = 0
    lcd1602.write(x: 0, y: 0, "Draw Rectangle")
    sleep(ms: 500)

    let step = 4
    for i in stride(from: 0, to: 120, by: step) {
        x = i
        y = i
        wT -= step * 2
        hT -= step * 2
        wO -= step * 2
        hO -= step * 2

        if x < 32 {
            oledScreen.drawRect(x: x, y: y, width: wO, height: hO, color: Color.white)
            oled.writeScreen(oledScreen.data)
        }

        count += 1
        tftScreen.drawRect(x: x, y: y, width: wT, height: hT, color: rainbow[count % 7])
        tft.writeScreen(tftScreen.data)
        sleep(ms: 100)
    }

    sleep(ms: 2000)

    lcd1602.write(x: 0, y: 0, "              ")
    oledScreen.clear()
    tftScreen.clear()
}

func randomCircle() {
    var x, y, r: Int
    lcd1602.write(x: 0, y: 0, "Draw Circle")
    sleep(ms: 500)

    for count in 0..<50 {

        if count < 50 {
            x = Int.random(in: 0..<128)
            y = Int.random(in: 0..<64)
            r = Int.random(in: 2..<15)
            oledScreen.drawCircle(x: x, y: y, r: r, color: Color.white)
            oled.writeScreen(oledScreen.data)
        }

        x = Int.random(in: 0..<320)
        y = Int.random(in: 0..<240)
        r = Int.random(in: 5..<40)
        tftScreen.drawCircle(x: x, y: y, r: r, color: rainbow[count % 7])

        tft.writeScreen(tftScreen.data)
        sleep(ms: 100)
    }

    sleep(ms: 2000)

    lcd1602.write(x: 0, y: 0, "           ")
    oledScreen.clear()
    tftScreen.clear()
}


func drawCat() {
    lcd1602.write(x: 0, y: 0, "Introducing")
    lcd1602.write(x: 0, y: 1, "Our cat:")
    sleep(ms: 500)

    oledScreen.setCursor(x: 0, y: oledScreen.font.advanceY * 2)
    oledScreen.drawString("Mr. Fatty!", color: Color.white)
    oled.writeScreen(oledScreen.data)

    for r in 0..<2 {
        for c in 0..<3 {
            let y = r * 100 + r * 20
            let x = c * 100 + c * 5
            tftScreen.drawBitmap(x: x, y: y, width: 100, height: 100, data: cat)
            tft.writeScreen(tftScreen.data)
            sleep(ms: 500)
        }
    }

    sleep(ms: 2000)

    tftScreen.clear()
    oledScreen.clear()
    lcd1602.write(x: 0, y: 0, "           ")
    lcd1602.write(x: 0, y: 1, "        ")
}


func sayHello() {
    lcd1602.setCursor(x: 0, y: 0)

    oledScreen.setFont(Roboto12pt.self)
    oledScreen.setCursor(x: 0, y: oledScreen.font.advanceY * 2)

    tftScreen.setFontSize(1)
    tftScreen.setCursor(x: 0, y: tftScreen.font.advanceY * 3)
    tftScreen.drawBitmap(x: 120, y: 0, width: 64, height: 64, data: swiftLogo)

    let str = ["H", "e", "l", "l", "o", " ", "S", "w", "i", "f", "t", "!"]

    for i in 0..<str.count {
        let color = rainbow[i % 7]

        lcd1602.write(str[i])

        oledScreen.drawString(str[i], color: Color.white)
        tftScreen.drawString(str[i], color: color)

        oled.writeScreen(oledScreen.data)
        tft.writeScreen(tftScreen.data)

        if str[i] != " " {
            sleep(ms: 500)
        }
    }
    sleep(ms: 2000)

    lcd1602.setCursor(x: 0, y: 0)
    lcd1602.write("            ")
    oledScreen.clear()
    tftScreen.clear()
}



func countDown() {

    oledScreen.setFont(Roboto28ptBlack.self)
    oledScreen.drawString(x: 42, y: oledScreen.font.advanceY, "3")
    oled.writeScreen(oledScreen.data)
    sleep(ms: 1000)

    lcd1602.write(x: 7, y: 0, "2")
    sleep(ms: 1000)

    tftScreen.setFont(Roboto28ptBlack.self)
    tftScreen.setFontSize(5)
    tftScreen.drawString(x: 90, y: oledScreen.font.advanceY * 5, "1", color: 0xFF0000)
    tft.writeScreen(tftScreen.data)
    sleep(ms: 1000)

    lcd1602.write(x: 7, y: 0, " ")
    oledScreen.clear()
    tftScreen.clear()
}

func drawLines() {
    lcd1602.write(x: 0, y: 0, "Draw Lines")
    sleep(ms: 500)

    var xOled = oled.width - 1, yOled = 0
    var xTft = tft.width - 1, yTft = 0

    var count = 0


    for i in stride(from: 0, to: 64, by: 6) {
        yOled = i
        oledScreen.drawLine(x1: 0, y1: 0, x2: xOled, y2: yOled)
        oled.writeScreen(oledScreen.data)
        sleep(ms: 20)
    }

    yOled = 63

    for i in stride(from: xOled, through: 0, by: -6) {
        xOled = i
        oledScreen.drawLine(x1: 0, y1: 0, x2: xOled, y2: yOled)
        oled.writeScreen(oledScreen.data)
        sleep(ms: 50)
    }



    for i in stride(from: 0, to: 240, by: 8) {
        yTft = i
        let color = rainbow[count % 7]
        count += 1
        tftScreen.drawLine(x1: 0, y1: 0, x2: xTft, y2: yTft, color: color)
        tft.writeScreen(tftScreen.data)
        //sleep(ms: 20)
    }

    yTft = 239

    for i in stride(from: xTft, through: 0, by: -8) {
        xTft = i
        let color = rainbow[count % 7]
        count += 1
        tftScreen.drawLine(x1: 0, y1: 0, x2: xTft, y2: yTft, color: color)
        tft.writeScreen(tftScreen.data)
        //sleep(ms: 20)
    }


    sleep(ms: 2000)


    lcd1602.write(x: 0, y: 0, "          ")
    oledScreen.clear()
    tftScreen.clear()
}



func sayGoodbye() {

    oledScreen.setFont(Roboto12pt.self)
    oledScreen.setCursor(x: 0, y: oledScreen.font.advanceY * 2)
    oledScreen.drawString("Visit:", color: Color.white)
    oled.writeScreen(oledScreen.data)

    sleep(ms: 500)
    lcd1602.write(x: 0, y: 0, "madmachine.io")

    tftScreen.setFontSize(1)
    tftScreen.setCursor(x: 0, y: tftScreen.font.advanceY * 2)

    let str = ["T", "h", "a", "n", "k", "s", " ", "f", "o", "r", "\n", "w", "a", "t", "c", "h", "i", "n", "g", " ", ":", " ", ")"]

    for i in 0..<str.count {
        let color = rainbow[i % 7]


        tftScreen.drawString(str[i], color: color)

        tft.writeScreen(tftScreen.data)

        if str[i] != " " && str[i] != "\n" {
            sleep(ms: 500)
        }
    }

    sleep(ms: 5000)

    lcd1602.setCursor(x: 0, y: 0)
    lcd1602.write(x: 0, y: 0, "             ")
    oledScreen.clear()
    tftScreen.clear()
}


func drawCatAlone() {
    var x, y: Int

    for r in 0..<2 {
        for c in 0..<3 {
            y = r * 100 + r * 20
            x = c * 100 + c * 5
            tftScreen.drawBitmap(x: x, y: y, width: 100, height: 100, data: cat)
            tft.writeScreen(tftScreen.data)
            sleep(ms: 1000)
        }
    }



    sleep(ms: 2000)

    tftScreen.clear()
    tft.writeScreen(tftScreen.data)

    for i in 0..<cat.count {
        let ox = i % 100
        let oy = i / 100

        x = ox * 2
        y = oy * 2

        tftScreen.fillRect(x: x, y: y, width: 2, height: 2, color: cat[i])

        if ox == 0 {
            tft.writeScreen(tftScreen.data)
        }
    }

    tft.writeScreen(tftScreen.data)

    sleep(ms: 2000)
    tftScreen.clear()



}

while true {
    countDown()
    sayHello()
    drawLines()
    drawRect()
    randomCircle()
    drawCat()
    sayGoodbye()
    
    //drawCatAlone()
}

