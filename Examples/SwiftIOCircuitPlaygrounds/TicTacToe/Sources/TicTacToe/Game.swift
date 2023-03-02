import SwiftIO
import ST7789

typealias Point = (x: Int, y: Int)

// Play the tic tac toe game.
struct TicTacToeGame {
    var player1: Player
    var player2: Player
    let screen: ST7789

    var game: Game
    var view: TicTacToeView

    var lastPos: Point?
    let rowCount: Int

    // Draw the background for the game and start the game.
    init(player1: Player, player2: Player, rowCount: Int = 3, screen: ST7789) {
        self.player1 = player1
        self.player2 = player2
        self.screen = screen
        self.rowCount = rowCount

        game = Game(rowCount: rowCount)
        view = TicTacToeView(rowCount: rowCount, screen: screen)

        lastPos = game.getGridXY(index: player1.getIndex(max: game.maxIndex))
        view.moveGrid(to: lastPos!, playerColor: player1.color)
    }

    // Two players play the game in turn.
    mutating func play() {
        if game.currentPlayer == 1 {
            waitPlayer(player1)
        } else if game.currentPlayer == 2 {
            waitPlayer(player2)
        }
    }

    mutating func waitPlayer(_ player: Player) {
        // The current player moves among the empty grid by turning the potentiometer.
        let newPos = game.getGridXY(index: player.getIndex(max: game.maxIndex))
        // If the position changes, update the display.
        if lastPos == nil || (newPos.x != lastPos!.x || newPos.y != lastPos!.y) {
            view.moveGrid(from: lastPos, to: newPos, playerColor: player.color)
            lastPos = newPos
        }

        // Press the button to confirm the selection.
        // Check if the player wins or the game is a tie.
        // If not, the next player gets ready to play.
        if player.pressed() {
            game.update(at: newPos)

            if game.win(newPos) {
                game.currentPlayer = 0
                screen.clearScreen(player.color)
            } else if game.tie() {
                game.currentPlayer = 0
                screen.clearScreen(view.background)
            } else {
                view.chooseGrid(at: newPos, playerColor: player.color)
                game.nextPlayer()
                lastPos = nil
            }
        }
    }
}

// For each player,
// turn a potentiometer to move among the available grid.
// press a button to confirm the selection.
struct Player {
    let pot: AnalogIn
    let button: DigitalIn
    let color: UInt16

    // Map the analog value into the available grid index range (0-max).
    // The value from the potentiometer is an average of several readings to reduce the noise.
    func getIndex(max: Int) -> Int {
        var sum = 0
        for _ in 0..<30 {
            sum += pot.readRawValue()
        }
        return Int((Float(sum * max) / 30.0 / Float(pot.maxRawValue)).rounded(.toNearestOrAwayFromZero))
    }

    // Check if the button is pressed.
    func pressed() -> Bool {
        return button.read()
    }
}

// Store the current game state:
// the grids may be empty or occupied by either of the player.
// Besides, check if someone wins the game or the game ends in a tie.
struct Game {
    let rowCount: Int
    var gridStates: [[Int]]
    var currentPlayer: Int
    var maxIndex: Int

    init(rowCount: Int) {
        self.rowCount = rowCount
        gridStates = [[Int]](repeating: ([Int](repeating: 0, count: rowCount)), count: rowCount)
        currentPlayer = 1
        maxIndex = rowCount * rowCount - 1
    }

    // If a player confirms the selection, update the grid state and change to the next player.
    mutating func update(at pos: Point) {
        gridStates[pos.y][pos.x] = currentPlayer
        maxIndex -= 1
    }

    mutating func nextPlayer() {
        currentPlayer = currentPlayer == 1 ? 2 : 1
    }

    // Get the available grid coordinate using the index from a potentiometer.
    func getGridXY(index: Int) -> Point {
        var index = index
        var gridX = 0
        var gridY = 0

        while index >= 0 {
            if gridStates[gridY][gridX] == 0 {
                index -= 1
            }

            if index < 0 {
                return (gridX, gridY)
            }

            gridX += 1
            if gridX == rowCount {
                gridX = 0
                gridY += 1
            }
        }
        return (gridX, gridY)
    }

    // Check if the current player marks the grids on the same row/column/diagonal.
    func win(_ pos: Point) -> Bool {
        // Horizontal.
        // The grids in the array gridStates[pos.y] should all be selected by the current player.
        if gridStates[pos.y].allSatisfy({ $0 == currentPlayer }) {
            return true
        }

        // Vertical.
        // The grids (gridStates[0][pos.x], gridStates[1][pos.x]...gridStates[rowCount-1][pos.x])
        // should all be selected by the current player.
        if allEqual({_ in pos.x}) { return true }

        // Principle diagonal.
        // The grids (gridStates[0][0], gridStates[1][1]...gridStates[rowCount-1][rowCount-1])
        // should all be selected by the current player.
        if pos.x == pos.y {
            return allEqual({ $0 })
        }

        // Secondary diagonal.
        // The grids (gridStates[0][rowCount-1], gridStates[1][rowCount-2]...gridStates[rowCount-1][0])
        // should all be selected by the current player.
        if pos.x + pos.y + 1 == rowCount {
            return allEqual({ rowCount - $0 - 1})
        }

        return false
    }

    // Check if all grids on the specifed row/column/diagonal are selected by the current player.
    func allEqual(_ calculateX: (Int) -> Int) -> Bool {
        var y = 0
        while y < rowCount && gridStates[y][calculateX(y)] == currentPlayer {
            y += 1
            if y == rowCount { return true }
        }

        return false
    }

    // Check if grids on each row/column/diagonal have been selected by two player.
    // If so, no grids on these lines can be same even if not all grids are marked,
    // thus the game ends in a tie.

    // Note: it won't predict the result and only checks after one selects a grid.
    // i.e. in this case, after the player 2 selects a grid, the game will end in a tie.
    // | 0 | 0 | 1 |
    // | 1 | 2 | 2 |
    // | 2 | 1 | 1 |
    func tie() -> Bool {
        // If no grids are empty and no one wins, it's a tie.
        if maxIndex < 0 { return true }

        // Check grids on each row.
        for y in gridStates.indices {
            if !bothSelect(gridStates[y]) { return false }
        }

        // Check grids on each column.
        var gridArray: [Int]
        for x in gridStates.indices {
            gridArray = []
            gridStates.forEach { gridArray.append($0[x]) }
            if !bothSelect(gridArray) { return false }
        }

        // Check for the principle diagonals.
        gridArray = []
        for y in gridStates.indices {
            gridArray.append(gridStates[y][y])
        }
        if !bothSelect(gridArray) { return false }

        // Check for the secondary diagonals.
        gridArray = []
        for y in gridStates.indices {
            gridArray.append(gridStates[y][rowCount - y - 1])
        }
        if !bothSelect(gridArray) { return false }

        return true
    }

    // Check if the grids in the given row/column/diagonal are selected by two player.
    func bothSelect(_ line: [Int]) -> Bool {
        var player1 = false
        var player2 = false

        line.forEach {
            if $0 == 1 {
                player1 = true
            } else if $0 == 2 {
                player2 = true
            }
        }

        return player1 && player2
    }
}

// Update the display while playing the game.
struct TicTacToeView {
    let rowCount: Int
    let screen: ST7789

    let gridWidth: Int
    let gridHeight: Int

    let gridInternalWidth: Int
    let gridInternalHeight: Int
    let gridStroke = 2

    var gridBuffer: [UInt16]

    let player1Color = Color.orange
    let player2Color = Color.lime
    let background = Color.white

    // Draw the background when starting the game.
    init(rowCount: Int, screen: ST7789) {
        self.rowCount = rowCount
        self.screen = screen

        gridWidth = screen.width / rowCount
        gridHeight = screen.height / rowCount

        gridInternalWidth = gridWidth - gridStroke * 2
        gridInternalHeight = gridHeight - gridStroke * 2

        gridBuffer = [UInt16](repeating: background, count: gridInternalWidth * gridInternalHeight)

        drawBackground()
    }

    // Fill the grid that the current player has selected.
    mutating func chooseGrid(at pos: Point, playerColor: UInt16) {
        drawGrid(at: pos, color: playerColor, buffer: &gridBuffer)
    }

    // Show player's current position.
    mutating func moveGrid(from lastPos: Point? = nil, to newPos: Point, playerColor: UInt16) {
        if let lastPos {
            drawGrid(at: lastPos, color: background, buffer: &gridBuffer)
        }

        for i in gridBuffer.indices {
            gridBuffer[i] = background
        }

        drawEmptyGrid(at: newPos, outline: playerColor, stroke: 6, buffer: &gridBuffer)
    }

    // Draw a rectangle at a specified position.
    private func drawGrid(at pos: Point, color: UInt16, buffer: inout [UInt16]) {
        for py in 0..<gridInternalHeight {
            for px in 0..<gridInternalWidth {
                buffer[px + py * gridInternalWidth] = color
            }
        }

        buffer.withUnsafeBytes {
            screen.writeBitmap(
                x: pos.x * gridWidth + gridStroke,
                y: pos.y * gridHeight + gridStroke,
                width: gridInternalWidth,
                height: gridInternalHeight,
                data: $0)
        }
    }

    // Draw an empty rectangle at a specified position.
    private func drawEmptyGrid(at pos: Point, outline: UInt16, stroke: Int, buffer: inout [UInt16]) {
        for y in 0..<stroke {
            for x in 0..<gridInternalWidth {
                buffer[x + gridInternalWidth * y] = outline
                buffer[x + gridInternalWidth * (y + gridInternalHeight - stroke)] = outline
            }
        }

        for y in stroke..<(gridInternalHeight-stroke) {
            for x in 0..<stroke {
                buffer[x + gridInternalWidth * y] = outline
                buffer[(x + gridInternalWidth - stroke) + gridInternalWidth * y] = outline
            }
        }

        buffer.withUnsafeBytes {
            screen.writeBitmap(
                x: pos.x * gridWidth + gridStroke,
                y: pos.y * gridHeight + gridStroke,
                width: gridInternalWidth,
                height: gridInternalHeight,
                data: $0)
        }
    }

    private func drawBackground() {
        var screenBuffer = [UInt16](repeating: background, count: screen.width * screen.height)

        for row in 0..<rowCount {
            for column in 0..<rowCount {
                let startX = column * gridWidth
                let startY = row * gridHeight

                for y in 0..<gridStroke {
                    for x in 0..<gridWidth {
                        screenBuffer[(startX + x) + screen.width * (startY + y)] = Color.black
                        screenBuffer[(startX + x) + screen.width * (startY + y + gridHeight - gridStroke)] = Color.black
                    }
                }

                for y in gridStroke..<(gridHeight-gridStroke) {
                    for x in 0..<gridStroke {
                        screenBuffer[(startX + x) + screen.width * (startY + y)] = Color.black
                        screenBuffer[(startX + x + gridWidth - gridStroke) + screen.width * (startY + y)] = Color.black
                    }
                }
            }
        }

        screenBuffer.withUnsafeBytes { screen.writeScreen($0) }
    }
}

struct Color {
    static let black: UInt16 = 0x0000
    static let white: UInt16 = 0xFFFF
    static let lime: UInt16 = 0xE007
    static let orange: UInt16 = 0x20FD
}