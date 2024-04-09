import MadGraphics
import ST7789
import SwiftIO

// Place a ball at the upper left corner of the maze and move it based on acceleration.
// If the ball reaches the destination (bottom right), the game ends.
// Press the D1 button to restart the game.
struct Game {
    var maze: Maze
    var ball: Ball
    let ballColor = Color(UInt32(0xEFE891))

    let width = 20
    var speed = 2

    let screen: ST7789
    let canvas: Canvas
    var frameBuffer: [UInt16]

    init(screen: ST7789, canvas: Canvas) {
        ball = Ball(at: Point(x: 1, y: 1), size: 7)
        maze = Maze(width: width, canvas: canvas)
        frameBuffer = [UInt16](repeating: 0, count: canvas.width * canvas.height)
        self.screen = screen
        self.canvas = canvas

        maze.generate()

        canvas.fillRectangle(at: Point(ball.x1, ball.y1), width: ball.size, height: ball.size, color: ballColor)
        updateDisplay(canvas: canvas, frameBuffer: &frameBuffer, screen: screen)
    }

    // Create a new maze and place the ball at the starting point.
    mutating func reset() {
        maze.reset()
        maze.generate()

        canvas.fillRectangle(at: Point(ball.x1, ball.y1), width: ball.size, height: ball.size, color: maze.bgColor)
        ball = Ball(at: Point(x: 1, y: 1), size: 7)
        canvas.fillRectangle(at: Point(ball.x1, ball.y1), width: ball.size, height: ball.size, color: ballColor)
        
        updateDisplay(canvas: canvas, frameBuffer: &frameBuffer, screen: screen)
    }

    // Update the display to show that the game has finished.
    mutating func finishGame() {
        canvas.fillRectangle(at: Point(0, 0), width: canvas.width, height: canvas.height, color: Color.red)

        var fileLength = 0
        if let fontDataBuffer = openFile(path: "/lfs/Resources/Fonts/Roboto-Regular.ttf", length: &fileLength) {
            let largeFont = Font(from: fontDataBuffer, length: fileLength, pointSize: 10, dpi: 220)
            let largeText = largeFont.getMask("Good job!")
            canvas.blend(from: largeText, foreground: Color.white, to: Point(x: (canvas.width - largeText.width) / 2, y: 60))

            let font = Font(from: fontDataBuffer, length: fileLength, pointSize: 6, dpi: 220)
            let text = font.getMask("Press D1 to continue")
            canvas.blend(from: text, foreground: Color.white, to: Point(x: (canvas.width - text.width) / 2, y: 140))
        }
        
        updateDisplay(canvas: canvas, frameBuffer: &frameBuffer, screen: screen)
    }

    // Verify if the ball has reached the bottom right corner of the maze.
    func finished() -> Bool {
        return ball.x1 / width == maze.column - 1 && ball.y1 / width == maze.row - 1
    }

    // Update the ball's position based on the acceleration.
    mutating func update(_ acceleration: (x: Float, y: Float, z: Float)) {
        guard !finished() else {
            finishGame()
            return
        }

        let lastBallPos = Point(ball.x1, ball.y1)

        // Move to the left.
        if acceleration.x > 0.25 {
            ball.x1 -= speed

            let gridXmin = max(ball.x1 / width, 0)
            let gridXmax = min(ball.x2 / width, maze.column - 1)
            let gridYmin = max(ball.y1 / width, 0)
            let gridYmax = min(ball.y2 / width, maze.row - 1)

            // Check if the ball collides with any walls. 
            // If it does, reposition it close to the wall.
            for y in gridYmin...gridYmax {
                for x in gridXmin...gridXmax {
                    let result = checkGridWalls(ballPos: Point(ball.x1, ball.y1), gridPos: Point(x, y))

                    if result.top || result.bottom || result.right {
                        ball.x1 = (x + 1) * width + 1
                    }

                    if result.left {
                        ball.x1 = x * width + 1
                    }
                }
            }
        } 
        
        // Move to the right
        if acceleration.x < -0.25 {            
            ball.x1 += speed

            let gridXmin = max(ball.x1 / width, 0)
            let gridXmax = min(ball.x2 / width, maze.column - 1)
            let gridYmin = max(ball.y1 / width, 0)
            let gridYmax = min(ball.y2 / width, maze.row - 1)

            for y in gridYmin...gridYmax {
                for x in gridXmin...gridXmax {
                    let result = checkGridWalls(ballPos: Point(ball.x1, ball.y1), gridPos: Point(x, y))

                    if result.top || result.bottom || result.left {
                        ball.x1 = x * width - ball.size - 1
                    }

                    if result.right {
                        ball.x1 = (x + 1) * width - ball.size - 1
                    }
                }
            }
        }

        // Move downwards.
        if acceleration.y > 0.25 {
            ball.y1 += speed

            let gridXmin = max(ball.x1 / width, 0)
            let gridXmax = min(ball.x2 / width, maze.column - 1)
            let gridYmin = max(ball.y1 / width, 0)
            let gridYmax = min(ball.y2 / width, maze.row - 1)

            for y in gridYmin...gridYmax {
                for x in gridXmin...gridXmax {
                    let result = checkGridWalls(ballPos: Point(ball.x1, ball.y1), gridPos: Point(x, y))

                    if result.bottom {
                        ball.y1 = (y + 1) * width - 1 - ball.size
                    }

                    if result.top || result.right || result.left {
                        ball.y1 = y * width - 1 - ball.size
                    }
                }
            }
        }

        // Move upwards.
        if acceleration.y < -0.25 {
            ball.y1 -= speed
            
            let gridXmin = max(ball.x1 / width, 0)
            let gridXmax = min(ball.x2 / width, maze.column - 1)
            let gridYmin = max(ball.y1 / width, 0)
            let gridYmax = min(ball.y2 / width, maze.row - 1)

            for y in gridYmin...gridYmax {
                for x in gridXmin...gridXmax {
                    let result = checkGridWalls(ballPos: Point(ball.x1, ball.y1), gridPos: Point(x, y))

                    if result.top {
                        ball.y1 = y * width + 1
                    }

                    if result.bottom || result.right || result.left {
                        ball.y1 = (y + 1) * width + 1
                    }
                }
            }
        }
        
        // If the ball's position has changed, update the display.
        if lastBallPos.x != ball.x1 || lastBallPos.y != ball.y1 {
            canvas.fillRectangle(at: lastBallPos, width: ball.size, height: ball.size, color: maze.bgColor)
            canvas.fillRectangle(at: Point(ball.x1, ball.y1), width: ball.size, height: ball.size, color: ballColor)
            updateDisplay(canvas: canvas, frameBuffer: &frameBuffer, screen: screen)
        }
    }

    // Check if the ball collides with a wall.
    func checkCollision(ballPos: Point, wallP1: Point, wallP2: Point) -> Bool {
        return ball.x1 <= wallP2.x && ball.x2 >= wallP1.x && ball.y1 <= wallP2.y && ball.y2 >= wallP1.y
    }

    // Check if the ball collides with any wall of a cell in the maze grid. 
    func checkGridWalls(ballPos: Point, gridPos: Point) -> Wall {
        let walls = maze.grids[maze.getIndex(gridPos)].walls
        var result = Wall(top: false, right: false, bottom: false, left: false)

        if walls.top &&
            checkCollision(ballPos: ballPos, wallP1: Point(gridPos.x * width, gridPos.y * width), wallP2: Point((gridPos.x + 1) * width, gridPos.y * width)) {
                result.top = true
        }                

        if walls.right &&
            checkCollision(ballPos: ballPos, wallP1: Point((gridPos.x + 1) * width, gridPos.y * width), wallP2: Point((gridPos.x + 1) * width, (gridPos.y + 1) * width)) {
                result.right = true
            
        }

        if walls.bottom &&
            checkCollision(ballPos: ballPos, wallP1: Point(gridPos.x * width, (gridPos.y + 1) * width), wallP2: Point((gridPos.x + 1) * width, (gridPos.y + 1) * width)) {
               result.bottom = true
        }

        if walls.left &&
            checkCollision(ballPos: ballPos, wallP1: Point(gridPos.x * width, gridPos.y * width), wallP2: Point(gridPos.x * width, (gridPos.y + 1) * width)) {
                result.left = true
        }

        return result
    }

    // Open a font file.
    func openFile(path: String, length: inout Int) -> UnsafeMutableRawBufferPointer? {
        var fontDataBuffer: UnsafeMutableRawBufferPointer? = nil

        print("open file:")
        do {
            let file = try FileDescriptor.open(path, .readOnly)

            try file.seek(offset: 0, from: FileDescriptor.SeekOrigin.end)
            let bytes = try file.tell()
            fontDataBuffer = UnsafeMutableRawBufferPointer.allocate(byteCount: bytes, alignment: 8)
            length = bytes

            try file.seek(offset: 0, from: FileDescriptor.SeekOrigin.start)
            try file.read(into: fontDataBuffer!, count: bytes)
            try file.close()
        } catch {
            print("Error, file handle error")
            if let buffer = fontDataBuffer {
                buffer.deallocate()
            }
            return nil
        }

        print("open file success")
        return fontDataBuffer
    }

    // Get the region that needs to be updated and send data to the screen.
    func updateDisplay(canvas: Canvas, frameBuffer: inout [UInt16], screen: ST7789) {
        guard let dirty = canvas.getDirtyRect() else {
            return
        }

        var index = 0
        let stride = canvas.width
        let canvasBuffer = canvas.buffer
        for y in dirty.y0..<dirty.y1 {
            for x in dirty.x0..<dirty.x1 {
                frameBuffer[index] = Color.getRGB565LE(canvasBuffer[y * stride + x])
                index += 1
            }
        }
        frameBuffer.withUnsafeBytes { ptr in
            screen.writeBitmap(x: dirty.x, y: dirty.y, width: dirty.width, height: dirty.height, data: ptr)
        }

        canvas.finishRefresh()
    }
}