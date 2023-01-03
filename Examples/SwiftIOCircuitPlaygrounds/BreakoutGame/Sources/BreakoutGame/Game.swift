import ST7789
import SwiftIO
import MadGraphics

struct Breakout {
    var bricks: Bricks
    let screen: ST7789

    let rootTile: Tile<UInt16>
    let ballTile: Tile<UInt16>
    let paddleTile: Tile<UInt16>

    var brickTiles: [Tile<UInt16>] = []
    var liveTiles: [Tile<UInt16>] = []
    let liveTileSize = 10

    var screenBuffer: [UInt16]
    var lineBuffer: [UInt16]

    var game: Game
    let canvas: Canvas

    let brickColors: [UInt16] = [Color.getRGB565LE(Color.red), Color.getRGB565LE(Color.white)]

    init(pot: AnalogIn, screen: ST7789) {
        self.screen = screen

        // Buffers for screen data.
        screenBuffer = [UInt16](repeating: 0, count: screen.width * screen.height)
        lineBuffer = [UInt16](repeating: 0, count: screen.width * screen.height)

        canvas = Canvas(pos: (0, liveTileSize * 2), width: screen.width, height: screen.height - liveTileSize * 2)
        bricks = Bricks(row: 8, column: 8, on: canvas)
        game = Game(pot: pot, on: canvas)

        // The root tile to organize all subtiles.
        rootTile = Tile(width: screen.width, height: screen.height, primaryColor: 0, isRoot: true)

        // Create a canvas.
        let canvasBitmap = Bitmap<UInt16>(width: canvas.width, height: canvas.height)
        let strokeColor = Color.getRGB565LE(Color.white)

        for x in 0..<canvas.width {
            canvasBitmap.setPixel(at: (x, 0), strokeColor)
            canvasBitmap.setPixel(at: (x, canvas.height - 1), strokeColor)
        }
        for y in 0..<canvas.height {
            canvasBitmap.setPixel(at: (0, y), strokeColor)
            canvasBitmap.setPixel(at: (canvas.width - 1, y), strokeColor)
        }

        let canvasTile = Tile<UInt16>(at: canvas.pos, bitmap: canvasBitmap)
        rootTile.append(canvasTile)

        // Draw a ball and a paddle on the canvas.
        ballTile = Tile(at: game.ball.pos, width: game.ball.size, height: game.ball.size, primaryColor: Color.getRGB565LE(Color.orange))
        paddleTile = Tile(at: game.paddle.pos, width: game.paddle.width, height: game.paddle.height, primaryColor: Color.getRGB565LE(Color.yellow))
        canvasTile.append(ballTile)
        canvasTile.append(paddleTile)

        // Create a brick wall with specified rows and columns on the canvas.
        for y in 0..<bricks.row {
            for x in 0..<bricks.column {
                let brickTile = Tile<UInt16>(
                    at: bricks.getBrickXY(at: (x, y)),
                    width: bricks.brickWidth, height: bricks.brickHeight,
                    primaryColor: brickColors[y % brickColors.count])
                canvasTile.append(brickTile)
                brickTiles.append(brickTile)
            }
        }

        // Create an indicator for lives left.
        for i in 0..<game.paddle.lives {
            let x = screen.width - 1 - (i + 1) * liveTileSize
            let tile = Tile<UInt16>(
                at: (x, 0), width: liveTileSize, height: liveTileSize,
                primaryColor: Color.getRGB565LE(Color.lime))
            liveTiles.append(tile)
            rootTile.append(tile)
        }

        updateDisplay()
    }

    mutating func play() {
        // If all bricks are destroyed, go to the next level.
        // The ball will move faster.
        if brickTiles.allSatisfy({ $0.getHidden()} ) {
            game.startNextLevel()

            liveTiles.forEach { $0.fillBitmap(Color.getRGB565LE(Color.lime)) }
            brickTiles.forEach { $0.setHidden(false) }
            updateDisplay()
        }

        let lastLives = game.paddle.lives

        // Update the game states, including the position of the ball and paddle.
        // Check if a collision has happened.
        game.play(bricks: bricks, brickTiles)

        // Update the position of ball and paddle on the screen.
        ballTile.move(to: game.ball.pos)
        paddleTile.move(to: game.paddle.pos)
        updateDisplay()

        // Update the display after losing a life.
        if lastLives != game.paddle.lives {
            liveTiles[game.paddle.lives].fillBitmap(Color.getRGB565LE(Color.gray))
            updateDisplay()
        }
    }

    // Update the display if there's any changes.
    mutating func updateDisplay() {
        var dirtyRegions: [Region] = []
        // Get the area that has been changed on the rootTile.
        rootTile.getRefreshRegions(into: &dirtyRegions)

        for dirtyRegion in dirtyRegions {
            // Update the screen buffer with the new pixel info.
            rootTile.update(region: dirtyRegion, into: &screenBuffer)

            // Get the changed pixel data from the screenBuffer which stores
            // data for the entire tile.
            var count = 0
            for y in dirtyRegion.y..<(dirtyRegion.y + dirtyRegion.height) {
                for x in dirtyRegion.x..<(dirtyRegion.x + dirtyRegion.width) {
                    lineBuffer[count] = screenBuffer[y * screen.width + x]
                    count += 1
                }
            }

            // Send the data to the screen using SPI to update the specified area.
            lineBuffer.withUnsafeMutableBytes {
                screen.writeBitmap(
                    x: dirtyRegion.x, y: dirtyRegion.y,
                    width: dirtyRegion.width, height: dirtyRegion.height,
                    data: UnsafeRawBufferPointer($0)
                )
            }
        }
        // Reset all states of rootTile.
        rootTile.finishRefresh()
    }
}

// Update 
struct Game {
    var paddle: Paddle
    var ball: Ball
    let canvas: Canvas

    // Store the last time that the ball moves.
    var lastTime: UInt
    // The duration in millisecond.
    let moveDuration = 30
    // Keep track of the total score.
    var score: Int = 0

    // Initialize the states of ball and paddle.
    init(pot: AnalogIn, on canvas: Canvas) {
        self.canvas = canvas
        paddle = Paddle(pot: pot, on: canvas)
        ball = Ball(paddle: paddle, on: canvas)
        lastTime = getClockCycle()
    }

    mutating func play(bricks: Bricks, _ brickTiles: [Tile<UInt16>]) {
        // If no lives left, end the game.
        guard paddle.lives > 0 else { return }

        // Move the paddle on the canvas according to the potentiometer's position.
        paddle.move()

        // Check if it's time to move the ball.
        let current = getClockCycle()
        if cyclesToNanoseconds(start: lastTime, stop: current) >= moveDuration * 1000_000 {
            // Move the ball based on x and y speed.
            ball.move()

            // Check if the ball hits any bricks.
            // If so, destroy the brick(s) and bounce the ball.
            checkHitBrick(bricks: bricks, brickTiles)

            // Check if the ball hits the wall.
            // If so, bounce the ball off.
            ball.checkHitWall()

            // If the paddle hits the ball, bounce the ball and update ball's speed.
            // If it loses the, decrease a life.
            if paddle.hit(ball) {
                ball.bounceAfterHit(paddle)
            } else if paddle.miss(ball) {
                ball.resetAfterMiss(paddle)
                print("Score: \(score), rest lives: \(paddle.lives)")
            }

            lastTime = current
        }
    }

    // Reset all states and increase ball's speed for next level.
    mutating func startNextLevel() {
        ball.increaseSpeed()
        ball.reset(on: paddle)
        paddle.reset()
    }

    // Check if the ball hits any bricks.
    // Destroy those bricks, add scores and change ball's direction.
    mutating func checkHitBrick(bricks: Bricks, _ brickTiles: [Tile<UInt16>]) {
        var xChanged = false
        var yChanged = false

        for y in 0..<bricks.row {
            for x in 0..<bricks.column {
                let index = y * bricks.column + x
                if ball.hitBrick(at: (x, y), bricks: bricks) &&
                    !brickTiles[index].getHidden()
                {
                    brickTiles[index].setHidden(true)
                    score += 1
                    print(score)

                    // Check from which direction the ball is moving and change direction.
                    let lastBallX = ball.pos.x - ball.xSpeed
                    if lastBallX + ball.size <= brickTiles[index].x ||
                        lastBallX >= brickTiles[index].x + bricks.brickWidth
                    {
                        xChanged = true
                    } else {
                        yChanged = true
                    }
                }
            }
        }

        // Change ball's direction in x and y axis.
        ball.bounce(x: xChanged, y: yChanged)
    }
}

// The area where ball and paddle moves.
struct Canvas {
    let pos: Point
    let width: Int
    let height: Int
}

// Create a brick field.
struct Bricks {
    let row: Int
    let column: Int
    let canvas: Canvas

    let brickHeight: Int
    let brickWidth: Int
    let brickGap = 4

    init(row: Int, column: Int, on canvas: Canvas) {
        self.row = row
        self.column = column
        self.canvas = canvas

        brickWidth = canvas.width / column - brickGap
        brickHeight = canvas.height / 2 / row - brickGap
    }

    // The coordinate of the brick according the given row and column.
    func getBrickXY(at pos: Point) -> Point {
        return (pos.x * (brickWidth + brickGap) + brickGap / 2,
                pos.y * (brickHeight + brickGap) + brickGap / 2)
    }
}

struct Ball {
    var pos: Point = (0, 0)
    var speed = 3

    var xSpeed: Int = 0
    var ySpeed: Int = 0

    let size = 8
    let canvas: Canvas

    init(paddle: Paddle, on canvas: Canvas) {
        self.canvas = canvas
        reset(on: paddle)
    }

    mutating func increaseSpeed() {
        speed += 1
    }

    // Move the ball from middle of the paddle.
    mutating func reset(on paddle: Paddle) {
        pos = (paddle.pos.x + paddle.width / 2, paddle.pos.y - size)
        xSpeed = speed * [1, -1].randomElement()!
        ySpeed = -speed
    }

    // Move the ball on x, y-axis.
    mutating func move() {
        pos.x += xSpeed
        pos.y += ySpeed
    }

    // Check if the ball hits the specified brick.
    func hitBrick(at index: Point, bricks: Bricks) -> Bool {
        let brickPos = bricks.getBrickXY(at: index)

        return pos.x + size > brickPos.x &&
            pos.x < brickPos.x + bricks.brickWidth &&
            pos.y + size > brickPos.y &&
            pos.y < brickPos.y + bricks.brickHeight
    }

    // Reset the ball after the paddle misses it
    mutating func resetAfterMiss(_ paddle: Paddle) {
        if paddle.lives > 0 {
            reset(on: paddle)
        } else {
            pos.y = canvas.height - 1 - size
        }
    }

    // Bounce the ball if it collides with the wall.
    mutating func checkHitWall() {
        if pos.x + size >= canvas.width - 1 {
            xSpeed.negate()
            pos.x = canvas.width - size - 1
        } else if pos.x <= 0 {
            xSpeed.negate()
            pos.x = 0
        }

        if pos.y <= 0 {
            ySpeed.negate()
            pos.y = 0
        }
    }

    // Change the ball's direction after it hits the paddle.
    mutating func bounceAfterHit(_ paddle: Paddle) {
        // The distance of the bounce position on the paddle from one of its edge.
        var distance: Int
        if pos.x + size / 2 <= paddle.pos.x + paddle.width / 2 {
            distance = pos.x - paddle.pos.x + size
        } else {
            distance = paddle.pos.x + paddle.width - pos.x
        }

        // Change the speed on x-axis according to the distance of the bounce position on the paddle.
        let ratio = Float(distance) / (Float(paddle.width + size) / 2)
        xSpeed = Int((ratio * Float(speed - 1) + 1).rounded(.toNearestOrAwayFromZero)) * xSpeed.signum()
        ySpeed.negate()
        pos.y = canvas.height - 1 - paddle.height - size
    }

    // Change the direction on x, y-axis.
    mutating func bounce(x: Bool, y: Bool) {
        if x { xSpeed.negate() }
        if y { ySpeed.negate() }
    }
}

struct Paddle {
    let pot: AnalogIn
    let canvas: Canvas
    let width = 32
    let height = 8

    var pos: Point
    var lives = 0

    // Initialize its position on the bottom of the canvas.
    init(pot: AnalogIn, on canvas: Canvas) {
        self.pot = pot
        self.canvas = canvas

        pos = (0, canvas.height - height - 1)
        reset()
    }

    // Reset the paddle's states.
    mutating func reset() {
        lives = 5
        move()
    }

    // Update the paddle's position on x-axis using the readings from the potentiometer.
    mutating func move() {
        var sum = 0
        for _ in 0..<15 {
            sum += pot.readRawValue()
        }

        pos.x = sum * (canvas.width - width - 1) / pot.maxRawValue / 15
    }

    // Check if it hits the ball.
    func hit(_ ball: Ball) -> Bool {
        return (ball.pos.y + ball.size >= pos.y) && (ball.pos.x + ball.size >= pos.x) && (ball.pos.x <= pos.x + width)
    }

    // Check if it misses the ball.
    mutating func miss(_ ball: Ball) -> Bool {
        if ball.pos.y + ball.size >= canvas.height - 1 {
            lives -= 1
            return true
        }
        return false
    }
}
