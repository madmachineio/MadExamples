import SwiftIO
import MadBoard
import ST7789
import MadGraphics
import PCF8563

@main
public struct Calendar {
    public static func main() {
        // Initialize the SPI pin and the digital pins for the LCD.
        let bl = DigitalOut(Id.D2)
        let rst = DigitalOut(Id.D12)
        let dc = DigitalOut(Id.D13)
        let cs = DigitalOut(Id.D5)
        let spi = SPI(Id.SPI0, speed: 30_000_000)
        // Initialize the LCD using the pins above. Rotate the screen to keep the original at the upper left.
        let screen = ST7789(spi: spi, cs: cs, dc: dc, rst: rst, bl: bl, rotation: .angle90)

        let i2c = I2C(Id.I2C0)
        let rtc = PCF8563(i2c)

        let leftButton = DigitalIn(Id.D1)
        let rightButton = DigitalIn(Id.D19)

        var frameBuffer = [UInt32](repeating: 0, count: 240 * 240)
        var screenBuffer = [UInt16](repeating: 0, count: 240 * 240)

        var time = PCF8563.Time(
            year: 2024, month: 5, day: 13, hour: 17,
            minute: 18, second: 0, dayOfWeek: 0)
        rtc.setTime(time)

        let rootLayer = Layer(width: screen.width, height: screen.height)

        time = rtc.readTime()

        var calendarTime = Time(year: Int(time.year), month: Int(time.month), day: Int(time.day))

        // Draw calendar.
        var calendarGrid = generateCalendar(year: calendarTime.year, month: calendarTime.month)

        let gridSize = 30
        let row = 7
        let column = 7
        let xOffset = (rootLayer.frame.width - gridSize * column) / 2
        let yOffset = rootLayer.frame.height - gridSize * row

        // Fill background.
        rootLayer.draw() { canvas in
            canvas.fillRectangle(at: Point(0, 0), width: canvas.width, height: yOffset, data: Pixel.orange) 
            canvas.fillRectangle(at: Point(0, yOffset), width: canvas.width, height: canvas.height - yOffset, data: Pixel.white)
        }
        
        let font = Font(path: "/lfs/Resources/Fonts/Rye-Regular.ttf", pointSize: 6, dpi: 220)

        // Display the year and month.
        let monthString = months[calendarTime.month - 1] + " " + String(calendarTime.year)
        var rect = font.getRect(monthString)
        var point = Point((rootLayer.frame.width - rect.width) / 2, (yOffset - rect.height) / 2)
        let monthLayer = TextLayer(at: point, string: monthString, font: font, foregroundColor: Pixel.white)
        rootLayer.append(monthLayer)

        rect = font.getRect("<")
        point = Point((gridSize - rect.width) / 2 + xOffset, (yOffset - rect.height) / 2)
        let leftArrow = TextLayer(at: point, string: "<", font: font, foregroundColor: Pixel.white)
        rootLayer.append(leftArrow)

        rect = font.getRect(">")
        point = Point(gridSize * (column - 1) + (gridSize - rect.width) / 2 + xOffset, (yOffset - rect.height) / 2)
        let rightArrow = TextLayer(at: point, string: ">", font: font, foregroundColor: Pixel.white)
        rootLayer.append(rightArrow)
        
        let todayIndicator = Layer(at: Point(0, 0), width: gridSize, height: gridSize) 
        todayIndicator.isOpaque = false
        todayIndicator.draw() { canvas in
            canvas.fillCircle(at: Point(gridSize / 2, gridSize / 2), radius: gridSize / 2, data: Pixel.orange)
            //canvas.fillCircle(at: Point(gridSize / 2, gridSize / 2), radius: gridSize / 2, data: 0xFFFF_0000)
        }

        rootLayer.append(todayIndicator)
        
        var textLayers = [TextLayer]()

        initCalendar(calendarGrid: calendarGrid, today: calendarTime, calendarTime: calendarTime)
        rootLayer.render(into: &frameBuffer, output: &screenBuffer, transform: Pixel.toRGB565LE) { dirty, data in
            screen.writeBitmap(x: dirty.x, y: dirty.y, width: dirty.width, height: dirty.height, data: data)
        }

        var changeMonth = 0

        leftButton.setInterrupt(.rising) {
            changeMonth = -1
        }

        rightButton.setInterrupt(.rising) {
            changeMonth = 1
        }

        var sleepCount = 0

        while true {
            // Update the calendar for the new day.
            if sleepCount == 100 {
                let current = rtc.readTime()
                sleepCount = 0

                if current.day != time.day {
                    time = current
                    calendarTime = Time(year: Int(time.year), month: Int(time.month), day: Int(time.day))
                    calendarGrid = generateCalendar(year: calendarTime.year, month: calendarTime.month)
                    updateCalendar(calendarGrid: calendarGrid, today: calendarTime, calendarTime: calendarTime)
                    rootLayer.render(into: &frameBuffer, output: &screenBuffer, transform: Pixel.toRGB565LE) { dirty, data in
                        screen.writeBitmap(x: dirty.x, y: dirty.y, width: dirty.width, height: dirty.height, data: data)
                    }
                }
            }
            
            calendarTime.month += changeMonth
            if calendarTime.month == 13 {
                calendarTime.year += 1
                calendarTime.month = 1
            } else if calendarTime.month == 0 {
                calendarTime.year -= 1
                calendarTime.month = 12
            }

            if changeMonth != 0 {
                let monthString = months[calendarTime.month - 1] + " " + String(calendarTime.year)
                let rect = font.getRect(monthString)
                let point = Point((rootLayer.frame.width - rect.width) / 2, (yOffset - rect.height) / 2)

                monthLayer.string = monthString
                monthLayer.position = point

                calendarGrid = generateCalendar(year: calendarTime.year, month: calendarTime.month)
                let today = Time(year: Int(time.year), month: Int(time.month), day: Int(time.day))
                updateCalendar(calendarGrid: calendarGrid, today: today, calendarTime: calendarTime)
                rootLayer.render(into: &frameBuffer, output: &screenBuffer, transform: Pixel.toRGB565LE) { dirty, data in
                    screen.writeBitmap(x: dirty.x, y: dirty.y, width: dirty.width, height: dirty.height, data: data)
                }
                changeMonth = 0
            }

            sleep(ms: 10)
            sleepCount += 1
        }

        struct Time {
            var year: Int
            var month: Int
            var day: Int
        }

        func updateCalendar(calendarGrid: [[Int]], today: Time, calendarTime: Time) {
            for y in 1..<row {
                for x in 0..<column {
                    var string = " "
                    let day = calendarGrid[y - 1][x]

                    if day != 0 {
                        string = String(day)
                    }

                    // Highlight today's date on the calendar.
                    if day == today.day && calendarTime.month == today.month && calendarTime.year == today.year {
                        textLayers[y * column + x].foregroundColor = Pixel.white
                        todayIndicator.setHidden(false)
                    } else if calendarTime.month != today.month {
                        todayIndicator.setHidden(true)
                        textLayers[y * column + x].foregroundColor = Pixel.gray
                    }
                
                    let rect = font.getRect(string)
                    let point = Point(x * gridSize + (gridSize - rect.width) / 2 + xOffset, y * gridSize + (gridSize - rect.height) / 2 + yOffset)

                    textLayers[y * column + x].string = string
                    textLayers[y * column + x].position = point
                }
            }
        }

        func initCalendar(calendarGrid: [[Int]], today: Time, calendarTime: Time) {
            // Render the days for the calendar display.
            for y in 0..<row {
                for x in 0..<column {
                    var string = " "
                    var color = Pixel.gray
                    
                    if y == 0 {
                        string = daysOfWeek[x]
                    } else {
                        let day = calendarGrid[y - 1][x]

                        if day != 0 {
                            string = String(day)
                        }

                        // Highlight today's date on the calendar.
                        if day == today.day && calendarTime.month == today.month && calendarTime.year == today.year {
                            color = Pixel.white
                            let point = Point(x * gridSize + xOffset, (y) * gridSize + yOffset)
                            todayIndicator.position = point
                        }
                    }
                
                    let rect = font.getRect(string)
                    let point = Point(x * gridSize + (gridSize - rect.width) / 2 + xOffset, y * gridSize + (gridSize - rect.height) / 2 + yOffset)

                    let textLayer = TextLayer(at: point, string: string, font: font, foregroundColor: color)
                    rootLayer.append(textLayer)
                    textLayers.append(textLayer)
                }
            }
        }
    }
}