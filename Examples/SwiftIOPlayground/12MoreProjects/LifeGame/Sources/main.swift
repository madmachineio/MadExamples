import SwiftIO
import MadBoard
import ST7789

let spi = SPI(Id.SPI0, speed: 30_000_000)
let cs = DigitalOut(Id.D5)
let dc = DigitalOut(Id.D13)
let rst = DigitalOut(Id.D12)
let bl = DigitalOut(Id.D2)

// Initialize the LCD using the pins above. Rotate the screen to keep the original at the upper left.
let screen = ST7789(spi: spi, cs: cs, dc: dc, rst: rst, bl: bl, rotation: .angle90)

let gridSize = 3

let rowCount = screen.height / gridSize
let columnCount = screen.width / gridSize

var lastStates = [[Int]](repeating: [Int](repeating: 0, count: columnCount), count: rowCount)
var states = lastStates
var screenBuffer = [UInt16](repeating: 0, count: screen.width * screen.height)

for y in 0..<rowCount { 
    for x in 0..<columnCount {
        states[y][x] = Int.random(in: 0...1)
    }
}

while true {
    updateScreen(states)
    lastStates = states

    sleep(ms: 10)
    updateCells()
}

func updateCells() {
    for row in 0..<rowCount {
        for column in 0..<columnCount {
            let count = countAlive(x: column, y: row, states: lastStates)
            if lastStates[row][column] == 1 && (count == 2 || count == 3) {
                states[row][column] = 1
            } else if lastStates[row][column] == 0 && count == 3 {
                states[row][column] = 1
            } else {
                states[row][column] = 0
            }
        }
    }
}

func countAlive(x: Int, y: Int, states: [[Int]]) -> Int {
    var count = 0
    for row in (y-1)...(y+1) {
        for column in (x-1)...(x+1) {
            if (row >= 0 && row < rowCount) &&
                (column >= 0 && column < columnCount) &&
                !(row == y && column == x) &&
                states[row][column] == 1
            {
                count += 1
            }
        }
    }

    return count
}

func updateScreen(_ states: [[Int]]) {
    for row in 0..<rowCount {
        for column in 0..<columnCount {
            let color: UInt16 = states[row][column] == 1 ? 0xFFFF : 0

            for y in row * gridSize..<(row + 1) * gridSize {
                for x in column * gridSize..<(column + 1) * gridSize {
                    screenBuffer[y * screen.width + x] = color
                }
            }
        }
    }

    screenBuffer.withUnsafeBytes {
        screen.writeScreen($0)
    }
}