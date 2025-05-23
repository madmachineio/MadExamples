import SwiftIO
import MadBoard
import ST7789
import MadGraphics


let a0Module = 0
let d1Module = 1
let a11Module = 2
let d19Module = 3

let temperature = 5
let humidityKey = 6

let accValue = 8


nonisolated(unsafe) var globalIOValue: [Int: Int] = [
    a0Module: -1,
    d1Module: -1,
    a11Module: -1,
    d19Module: -1,
]
let ioLock = Mutex()


nonisolated(unsafe) var globalI2CValue: [Int: Int] = [
    temperature: -1,
    humidityKey: -1,
    accValue: -1,
]
let i2cLock = Mutex()


@main
public struct DefaultApp {
    public static func main() {
        sleep(ms: 500)

        let red = DigitalOut(Id.RED, value: true)
        let green = DigitalOut(Id.GREEN, value: true)
        let blue = DigitalOut(Id.BLUE, value: true)

        let led = PWMOut(Id.PWM4A)
        led.set(frequency: 2000, dutycycle: 0.0)
        let buzzer = PWMOut(Id.PWM5A)

        let spi = SPI(Id.SPI0, speed: 30_000_000)

        let bl = DigitalOut(Id.D2)
        let rst = DigitalOut(Id.D12)
        let dc = DigitalOut(Id.D13)
        let cs = DigitalOut(Id.D5)

        let screen = ST7789(spi: spi, cs: cs, dc: dc, rst: rst, bl: bl, width: 240, rotation: .angle90)
        var screenBuffer = [UInt16](repeating: 0, count: screen.width * screen.height)
        var frameBuffer = [UInt32](repeating: 0, count: screen.width * screen.height)

        let colors = [
            Pixel.black,
            Pixel.gray,
            Pixel.silver,
            Pixel.red,
            Pixel.pink,
            Pixel.maroon,
            Pixel.lime,
            Pixel.green,
            Pixel.olive,
            Pixel.blue,
            Pixel.navy,
            Pixel.teal,
            Pixel.cyan,
            Pixel.aqua,
            Pixel.purple,
            Pixel.magenta,
            Pixel.orange,
            Pixel.yellow,
            Pixel.white,
        ]
        var colorIndex = 0

        var uptime = getSystemUptimeInMilliseconds() / 1000

        let robotoFont = Font(path: "/lfs/Resources/Fonts/Roboto-Regular.ttf" , pointSize: 6, dpi: 220)

        let rootLayer = rootBackgroundInit(font: robotoFont)
        rootLayer.render(into: &frameBuffer, output: &screenBuffer, transform: Pixel.toRGB565LE) { dirty, data in
            screen.writeBitmap(x: dirty.x, y: dirty.y, width: dirty.width, height: dirty.height, data: data)
        }


        let temperatureText = TextLayer(at: Point(10, 12), string: "°C", font: robotoFont, foregroundColor: Pixel(0xFF39E910))
        temperatureText.pointSize = 10
        rootLayer.append(temperatureText)

        let humidityText = TextLayer(at: Point(10, 48), string: "%", font: robotoFont, foregroundColor: Pixel(0xFF1e9cf4))
        humidityText.pointSize = 10
        rootLayer.append(humidityText)

        let colorBar = Layer(at: Point(10, 185), width: 100, height: 30, backgroundColor: Pixel.white)
        rootLayer.append(colorBar)


        let timeText = TextLayer(at: Point(124, 22), string: " ", font: robotoFont, foregroundColor: Pixel.purple)
        rootLayer.append(timeText)

        let soundState = TextLayer(at: Point(124, 42), string: "Play sound", font: robotoFont, foregroundColor: Pixel.red)
        rootLayer.append(soundState)
        
        let buzzerBar = Layer(at: Point(130, 106), width: 1, height: 28, backgroundColor: Pixel(0xFFFFF568))
        rootLayer.append(buzzerBar)
        
        let accBar = Layer(at: Point(130, 186), width: 5, height: 27, backgroundColor: Pixel.orange)
        rootLayer.append(accBar)



        createThread(
            name: "play_sound",
            priority: 3,
            stackSize: 1024 * 64,
            soundThread
        )
        sleep(ms: 10)

        createThread(
            name: "normal_io",
            priority: 4,
            stackSize: 1024 * 64,
            ioThread
        )
        sleep(ms: 10)

        createThread(
            name: "i2c_io",
            priority: 5,
            stackSize: 1024 * 64,
            i2cIOThread
        )
        sleep(ms: 10)

        while true {
            sleep(ms: 5)
            blue.toggle()

            ioLock.lock()
            let ioSendState = globalIOValue.filter { (step, value) in
                value >= 0
            }
            ioLock.unlock()

            for (key, value) in ioSendState {
                if key == a0Module {
                    let dutycycle = Float(value) / 100.0
                    led.setDutycycle(dutycycle)
                    rootLayer.draw() { canvas in
                        canvas.fillRectangle(at: Point(x: 10, y: 106), width: 100, height: 28, data: Pixel.white)
                    }
                    if value != 0 {
                        rootLayer.draw() { canvas in
                            canvas.fillRectangle(at: Point(x: 10, y: 106), width: value, height: 28, data: Pixel(0xFFFF5E5E))
                        }
                    }
                }

                if key == a11Module {
                    let fre = 400 + 40 * value
                    if value > 1 {
                        buzzer.set(frequency: fre, dutycycle: 0.5)
                        buzzerBar.frame.size.width = value
                    } else {
                        buzzer.set(frequency: fre, dutycycle: 0)
                        buzzerBar.frame.size.width = 1
                    }
                }

                if key == d1Module {
                    let color = colors[colorIndex]
                    colorBar.backgroundColor = color
                    colorIndex += 1
                    if colorIndex >= colors.count {
                        colorIndex = 0
                    }
                }

                if key == d19Module && value == 2 {
                    soundState.foregroundColor = Pixel.lime
                }

                if key == d19Module && value == 0 {
                    soundState.foregroundColor = Pixel.red
                }
            }

            ioLock.lock()
            for (key, value) in ioSendState {
                if key == d19Module {
                    if value == 2 || value == 0 {
                        let newValue = globalIOValue[key]! - 1
                        globalIOValue[key] = newValue
                    }
                } else {
                    globalIOValue[key] = -1
                }
            }
            ioLock.unlock()


            i2cLock.lock()
            let i2cSendState = globalI2CValue.filter { (step, value) in
                value >= 0
            }
            i2cLock.unlock()

            for (key, value) in i2cSendState {
                if key == temperature {
                    temperatureText.string = String(value / 10) + "." + String(value % 10) + "°C"
                }

                if key == humidityKey {
                    humidityText.string = String(value / 10) + "." + String(value % 10) + "%"
                }

                if key == accValue {
                    let x = value & 0xFF
                    accBar.position.x = 130 + x
                }
            }

            i2cLock.lock()
            for key in i2cSendState.keys {
                globalI2CValue[key] = -1
            }
            i2cLock.unlock()


            let currentTime = getSystemUptimeInMilliseconds() / 1000
            if uptime != currentTime {
                uptime = currentTime
                let hour = uptime / 3600
                let minute = (uptime / 60) % 60
                let second = uptime % 60

                let hourStr = (hour < 10 ? String(0) + String(hour) : String(hour)) + ":"               
                let minStr = (minute < 10 ? String(0) + String(minute) : String(minute)) + ":"               
                let secStr = (second < 10 ? String(0) + String(second) : String(second))            

                timeText.string = hourStr + minStr + secStr
            }

            rootLayer.render(into: &frameBuffer, output: &screenBuffer, transform: Pixel.toRGB565LE) { dirty, data in
                screen.writeBitmap(x: dirty.x, y: dirty.y, width: dirty.width, height: dirty.height, data: data)
            }
        }
    }
}


func rootBackgroundInit(font: Font) -> Layer {
    let layer = Layer(at: Point.zero, width: 240, height: 240)

    layer.draw() { canvas in
        canvas.fill(Pixel.white)
        canvas.drawLine(from: Point(x: 120, y: 0), to: Point(x: 120, y: 239), stroke: 2, data: Pixel.pink)
        canvas.drawLine(from: Point(x: 120, y: 40), to: Point(x: 239, y: 40), stroke: 2, data: Pixel.pink)
        canvas.drawLine(from: Point(x: 0, y: 80), to: Point(x: 239, y: 80), stroke: 2, data: Pixel.pink)
        canvas.drawLine(from: Point(x: 0, y: 160), to: Point(x: 239, y: 160), stroke: 2, data: Pixel.pink)
    }

    layer.draw() { canvas in
        canvas.drawRectangle(at: Point(x: 10, y: 105), width: 100, height: 30, stroke: 3, data: Pixel(0xFF252525))
        canvas.drawRectangle(at: Point(x: 130, y: 105), width: 100, height: 30, stroke: 3, data: Pixel(0xFF252525))
        canvas.drawRectangle(at: Point(x: 130, y: 185), width: 100, height: 30, stroke: 2, data: Pixel(0xFF252525))
    }

    print("display init 0")
    let time = TextLayer(at: Point(124, 2), string: "Uptime", font: font, foregroundColor: Pixel.black)
    layer.append(time)

    print("display init 1")
    let soundAction = TextLayer(at: Point(124, 65), string: "Press Button D19", font: font, foregroundColor: Pixel.gray)
    soundAction.pointSize = 5
    layer.append(soundAction)


    print("display init 2")
    let led = TextLayer(at: Point(0, 82), string: "LED brightness", font: font, foregroundColor: Pixel(0xFF252525))
    let ledAction = TextLayer(at: Point(0, 142), string: "Rotate Knob A0", font: font, foregroundColor: Pixel.gray)
    ledAction.pointSize = 5
    layer.append(led)
    layer.append(ledAction)

    print("display init 3")
    let buzzer = TextLayer(at: Point(124, 82), string: "Buzzer pitch", font: font, foregroundColor: Pixel(0xFF252525))
    let buzzerAction = TextLayer(at: Point(124, 142), string: "Rotate Knob A11", font: font, foregroundColor: Pixel.gray)
    buzzerAction.pointSize = 5
    layer.append(buzzer)
    layer.append(buzzerAction)


    print("display init 4")
    let color = TextLayer(at: Point(0, 165), string: "Color picker", font: font, foregroundColor: Pixel(0xFF252525))
    let colorAction = TextLayer(at: Point(0, 225), string: "Press Button D1", font: font, foregroundColor: Pixel.gray)
    colorAction.pointSize = 5
    layer.append(color)
    layer.append(colorAction)

    print("display init 5")
    let acc = TextLayer(at: Point(124, 165), string: "Acceleration", font: font, foregroundColor: Pixel(0xFF252525))
    let accAction = TextLayer(at: Point(124, 225), string: "Tilt the board", font: font, foregroundColor: Pixel.gray)
    accAction.pointSize = 5
    layer.append(acc)
    layer.append(accAction)

    return layer.presentation()
}