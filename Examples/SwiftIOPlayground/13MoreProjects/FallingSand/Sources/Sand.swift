import SwiftIO
import ST7789
typealias Point = (x: Int, y: Int)

struct Sand {
    let screen: ST7789
    // Keep the size greater than 1.
    let sandSize: Int = 4
    let row: Int
    let column: Int

    // The entire screen is made up of grids.
    // When a new sand particle appears, its color fills the corresponding grid.
    // This array stores the color value for each grid.
    var gridColors: [[UInt16]]
    
    // The x coordinate of the cursor used to add new sand.
    var cursorPos = 0
    var lastCursorPos = 0

    // Store the index to get current color value from the `colors` array.
    var colorIndex = 0
    let colors = Colors.colors565

    // Duration in milliseconds.
    let colorChangeDuration = 10000
    
    // Timestamp used to update display.
    var lastColorChangeTime: Int64 = 0

    // Initialize the screen with all grids defaulting to black and display the cursor.
    init(screen: ST7789, cursor: AnalogIn) {
        self.screen = screen

        row = screen.height / sandSize
        column = screen.width / sandSize
        
        // Initially, as there's no sand, all grids are set to black.
        gridColors = [[UInt16]](repeating: [UInt16](repeating: 0, count: column), count: row)

        // Read the potentiometer value and draw the cursor accordingly in the corresponding position.
        let cursorPos = getCursorPos(cursor: cursor)
        screen.drawEmptyRect(at: (cursorPos * sandSize, 0), width: sandSize, height: sandSize, stroke: 1, color: 0xFFFF) 

        lastCursorPos = cursorPos
        lastColorChangeTime = getSystemUptimeInMilliseconds()
    }

    // Update the position of the cursor and sand particles over time.
    mutating func update(cursor: AnalogIn) {
        updateCursor(cursor: cursor)

        // Update the color for newly added sand particles.
        let current = getSystemUptimeInMilliseconds()
        if current - lastColorChangeTime >= colorChangeDuration {
            colorIndex += 1
            if colorIndex == colors.count {
                colorIndex = 0
            }
            lastColorChangeTime = current
        }
        
        updateSand()
    }

    // Update the cursor's position as you rotate the potentiometer.
    mutating func updateCursor(cursor: AnalogIn) {
        cursorPos = getCursorPos(cursor: cursor)
        
        if cursorPos != lastCursorPos {
            screen.drawRect(at: (lastCursorPos * sandSize, 0), width: sandSize, height: sandSize, color: 0)
            screen.drawEmptyRect(at: (cursorPos * sandSize, 0), width: sandSize, height: sandSize, stroke: 1, color: 0xFFFF) 
            lastCursorPos = cursorPos
        }
    }

    // Calculate the cursor's position based on the potentiometer's reading.
    func getCursorPos(cursor: AnalogIn) -> Int {
        var values: Float = 0

        for _ in 0..<10 {
            values += cursor.readPercentage()
        }
        
        var x = values * Float(row - 1) / 10
        x.round(.toNearestOrAwayFromZero)
        return Int(x)
    }

    // Move the sand particles down.
    mutating func updateSand() {
        for y in (0..<gridColors.count-1).reversed() {
            for x in gridColors[y].indices {
                let color = gridColors[y][x]
                if color > 0 {
                    // If the grid below the particle is black, fill this grid with the sand color.
                    if gridColors[y+1][x] == 0 {
                        gridColors[y+1][x] = color
                        gridColors[y][x] = 0

                        screen.drawRect(at: (x * sandSize, y * sandSize), width: sandSize, height: sandSize, color: 0)
                        screen.drawRect(at: (x * sandSize, (y + 1) * sandSize), width: sandSize, height: sandSize, color: color)
                    } else {
                        // If the grid below is unavailable, the particle moves randomly to the left or right.
                        let left = Bool.random()
                        if left && x > 0 && gridColors[y+1][x-1] == 0 {
                            gridColors[y+1][x-1] = color
                            gridColors[y][x] = 0

                            screen.drawRect(at: (x * sandSize, y * sandSize), width: sandSize, height: sandSize, color: 0)
                            screen.drawRect(at: ((x - 1) * sandSize, (y + 1) * sandSize), width: sandSize, height: sandSize, color: color)
                        } else if !left && x < gridColors[y].count - 1 && gridColors[y+1][x+1] == 0 {
                            gridColors[y+1][x+1] = color
                            gridColors[y][x] = 0

                            screen.drawRect(at: (x * sandSize, y * sandSize), width: sandSize, height: sandSize, color: 0)
                            screen.drawRect(at: ((x + 1) * sandSize, (y + 1) * sandSize), width: sandSize, height: sandSize, color: color)
                        }
                    } 
                }
            }
        }
    }

    // Randomly add new sand particles below the cursor, then update the colors of the corresponding grids.
    mutating func drawNewSand() {
        // Define the area of the new particles.
        let extent = 4

        for y in 1...extent {
            for x in -extent/2...extent/2 {
                if Bool.random() {
                    let newSandPos: Point = (cursorPos + x, y)
                    if newSandPos.x < column && newSandPos.x >= 0 {
                        gridColors[newSandPos.y][newSandPos.x] = colors[colorIndex]
                        screen.drawRect(
                            at: (newSandPos.x * sandSize, newSandPos.y * sandSize), 
                            width: sandSize, 
                            height: sandSize, 
                            color: colors[colorIndex]
                        )
                    }
                }
            }
        }
    }
}


struct Colors {
    static let red: UInt32 = 0xFF0000
    static let orange: UInt32 = 0xFF7F00
    static let yellow: UInt32 = 0xFFFF00
    static let green: UInt32 = 0x00FF00
    static let blue: UInt32 = 0x0000FF
    static let indigo: UInt32 = 0x4B0082
    static let violet: UInt32 = 0x9400D3
    static let colors888 = [red, orange, yellow, green, blue, indigo, violet]
    // Get 16bit color data.
    static let colors565: [UInt16] = colors888.map { getRGB565BE($0) }

    // The screen needs RGB565 color data, so change color data from UInt32 to UInt16.
    // Besides, the board uses little endian format, so the bytes are swapped.
    static func getRGB565BE(_ color: UInt32) -> UInt16 {
        return UInt16(((color & 0xF80000) >> 8) | ((color & 0xFC00) >> 5) | ((color & 0xF8) >> 3)).byteSwapped
    }
}

extension ST7789 {
    func drawRect(at point: Point, width: Int, height: Int, color: UInt16) {
        var buffer = [UInt16](repeating:color, count: width * height)
        for py in 0..<height {
            for px in 0..<width {
                buffer[py * width + px] = color
            }
        }

        screen.writeBitmap(x: point.x, y: point.y, width: width, height: height, data: buffer)
    }

    func drawEmptyRect(at point: Point, width: Int, height: Int, stroke: Int, color: UInt16) {        
        for w in 0..<width {
            for line in 0..<stroke {
                writePixel(x: point.x + w, y: point.y + line, color: color)
                writePixel(x: point.x + w, y: point.y + height - stroke + line, color: color)
            }
        }

        for h in stroke..<height-stroke {
            for line in 0..<stroke {
                writePixel(x: point.x + line, y: point.y + h, color: color)
                writePixel(x: point.x + width - stroke + line, y: point.y + h, color: color)
            }
        }
    }
}