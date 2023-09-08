import ST7789
import SwiftIO

typealias Point = (x: Int, y: Int)

struct PongGame {
    var leftPlayer: Paddle
    var rightPlayer: Paddle

    let leftPot: AnalogIn
    let rightPot: AnalogIn

    let speaker: I2S

    var ball: Ball

    let screen: ST7789

    let window: Window

    var hitBallSound: [UInt8] = []
    var hitWallSound: [UInt8] = []
    var scoreSound: [UInt8] = []

    var startTime: UInt = 0

    let padding: Int

    init(leftPot: AnalogIn, rightPot: AnalogIn, screen: ST7789, speaker: I2S) {
        self.leftPot = leftPot
        self.rightPot = rightPot
        self.screen = screen
        self.speaker = speaker

        padding = (screen.width - Constants.windowWidth) / 2

        window = Window(
            x: padding,
            y: screen.height - Constants.windowHeight - padding,
            width: Constants.windowWidth,
            height: Constants.windowHeight,
            screen: screen
        )

        ball = Ball(
            x: window.centerX, y: window.centerY,
            size: Constants.ballSize,
            color: Constants.ballColor,
            screen: screen
        )

        leftPlayer = Paddle(
            x: window.x, y: 0, left: true,
            height: Constants.paddleHeight,
            width: Constants.paddleWidth,
            color: Constants.leftPaddleColor,
            screen: screen
        )

        rightPlayer = Paddle(
            x: window.x1 - Constants.paddleWidth,
            y: 0, left: false,
            height: Constants.paddleHeight,
            width: Constants.paddleWidth,
            color: Constants.rightPaddleColor,
            screen: screen
        )

        hitBallSound = readSoundData(from: "/SD:/Resources/Sounds/hitball.wav")
        hitWallSound = readSoundData(from: "/SD:/Resources/Sounds/hitwall.wav")
        scoreSound = readSoundData(from: "/SD:/Resources/Sounds/score.wav")

        leftPlayer.y = getPaddleY(leftPot)
        rightPlayer.y = getPaddleY(rightPot)

        reset()
        startTime = getClockCycle()
    }

    // Get the paddle's position within the window based on the value
    // from the potentiometer.
    func getPaddleY(_ pot: AnalogIn) -> Int {
        var sum = 0
        for _ in 0..<15 {
            sum += pot.readRawValue()
        }

        return sum / 15 * (window.height - Constants.paddleHeight) / pot.maxRawValue + window.y
    }


    mutating func play() {
        if leftPlayer.score < Constants.targetScore &&
            rightPlayer.score < Constants.targetScore
        {
            // Move the paddles to the position changed by the potentiometers.
            rightPlayer.update(newY: getPaddleY(rightPot), bgColor: Constants.bgColor)
            leftPlayer.update(newY: getPaddleY(leftPot), bgColor: Constants.bgColor)

            // The ball takes one step when time is up.
            let stop = getClockCycle()
            if cyclesToNanoseconds(start: startTime, stop: stop) / 1000_000 > ball.movePeriod {
                startTime = stop

                // Store the ball's previous position to wipe it from the screen.
                let lastPos = (ball.x, ball.y)

                // Update the position of the ball.
                ball.nextPos()
                if ball.hitWall(window: window) {
                    ball.updateAfterHitWall(window: window)
                    speaker.write(hitWallSound)
                }
                print(ball.x, ball.y)

                // If the ball hits left/right paddle, change the ball's
                // direction to bounce it in an opposite direction.
                // The speed of the ball will then increase a bit.
                if leftPlayer.hit(ball) {
                    ball.bounce(leftPlayer)
                    speaker.write(hitBallSound)
                } else if rightPlayer.hit(ball) {
                    ball.bounce(rightPlayer)
                    speaker.write(hitBallSound)
                }

                // If the ball hits the wall which means the paddle misses the ball,
                // 1. add point to opposite one's score,
                // 2. move the ball to starting point,
                // 3. set ball's direction to the opposite.
                if leftPlayer.miss(ball, window: window) {
                    // Add point to opposite one's score.
                    rightPlayer.score += 1
                    updateScoreBoard(left: false)
                    startTime = getClockCycle()
                    speaker.write(scoreSound)

                    // Ensure the target score isn't reached.
                    if rightPlayer.score < Constants.targetScore {
                        // Start next game after a specified time interval.
                        while cyclesToNanoseconds(start: startTime, stop: getClockCycle()) / 1000_000 < Constants.interval {
                            sleep(ms: 1)
                        }
                        // Clear the ball at the previous position.
                        ball.draw(at: lastPos, Constants.bgColor)
                        // Draw the ball at starting point.
                        ball.reset(in: window)
                        startTime = getClockCycle()
                    }  else if rightPlayer.score == Constants.targetScore {
                        updateDefeatedScoreBoard(left: true)
                    }
                } else if rightPlayer.miss(ball, window: window) {
                    leftPlayer.score += 1
                    updateScoreBoard(left: true)
                    startTime = getClockCycle()
                    speaker.write(scoreSound)

                    if leftPlayer.score < Constants.targetScore {
                        while cyclesToNanoseconds(start: startTime, stop: getClockCycle()) / 1000_000 < Constants.interval {
                            sleep(ms: 1)
                        }

                        ball.draw(at: lastPos, Constants.bgColor)
                        ball.reset(in: window)
                        startTime = getClockCycle()
                    } else if leftPlayer.score == Constants.targetScore {
                        updateDefeatedScoreBoard(left: false)
                    }
                } else {
                    // Update ball's position on the screen.
                    ball.update(lastPos: lastPos, bgColor: Constants.bgColor)
                }
            }
        }
    }

    func readSoundData(from path: String) -> [UInt8] {
        let headerSize = 0x2C

        let file = FileDescriptor.open(path)
        defer { file.close() }

        file.seek(offset: 0, from: FileDescriptor.SeekOrigin.end)
        let size = file.tell() - headerSize

        var buffer = [UInt8](repeating: 0, count: size)
        buffer.withUnsafeMutableBytes { rawBuffer in 
            _ = file.read(fromAbsoluteOffest: headerSize, into: rawBuffer, count: size)
        }

        return buffer
    }

    // Update the score board after gaining a point.
    func updateScoreBoard(left: Bool) {
        var x: Int
        var color: UInt16

        if left {
            x = Constants.scoreSize * (leftPlayer.score - 1) + padding
            color = leftPlayer.color
        } else {
            x = screen.width - Constants.scoreSize * rightPlayer.score - padding
            color = rightPlayer.color
        }

        screen.drawRect(at: (x, padding), width: Constants.scoreSize, height: Constants.scoreSize, color: color)
    }

    // Turn the score board of the defeated player into gray one.
    func updateDefeatedScoreBoard(left: Bool) {
        let gray: UInt16 = 0x1084
        let totalWidth = Constants.targetScore * Constants.scoreSize

        if left {
            screen.drawEmptyRect(
            at: (padding, padding),
            width: totalWidth,
            height: Constants.scoreSize,
            stroke: 1, color: gray)

            screen.drawRect(
                at: (padding, padding),
                width: Constants.scoreSize * leftPlayer.score,
                height: Constants.scoreSize,
                color: gray
            )
        } else {
            screen.drawEmptyRect(
            at: (screen.width - padding - totalWidth, padding),
            width: totalWidth,
            height: Constants.scoreSize,
            stroke: 1, color: gray)

            let width = rightPlayer.score * Constants.scoreSize
            screen.drawRect(
                at: (screen.width - padding - width, padding),
                width: width,
                height: Constants.scoreSize,
                color: gray
            )
        }
    }

    // Reset the game.
    mutating func reset() {
        screen.clearScreen(Constants.bgColor)

        window.draw()

        // Draw score board for two players.
        let width = Constants.targetScore * Constants.scoreSize
        screen.drawEmptyRect(
            at: (padding, padding),
            width: width, height: Constants.scoreSize,
            stroke: 1, color: Constants.leftPaddleColor)
        screen.drawEmptyRect(
            at: (screen.width - padding - width, padding),
            width: width, height: Constants.scoreSize,
            stroke: 1, color: Constants.rightPaddleColor)

        leftPlayer.draw()
        rightPlayer.draw()
        leftPlayer.score = 0
        rightPlayer.score = 0

        ball.reset(in: window)
    }
}



// Store constants used in the game and you only need to change them in one place.
struct Constants {
    static let bgColor: UInt16 = 0xFFFF

    static let paddleWidth = 8
    static let paddleHeight = 30
    static let leftPaddleColor: UInt16 = 0x20FD
    static let rightPaddleColor: UInt16 = 0x1FF8

    static let targetScore = 5
    static let scoreSize = 10

    static let ballSize = 8
    static let ballColor: UInt16 = 0xE007
    static let ballInitialMovingPeriod = 30

    static let windowWidth = 230
    static let windowHeight = 200
    static let windowStroke = 1
    static let windowOutline: UInt16 = 0

    // Interval in ms before next game starts.
    static let interval = 500
}

// The window where ball and paddles will move around.
struct Window {
    let x: Int
    let y: Int

    let width: Int
    let height: Int

    let stroke: Int

    let screen: ST7789

    var x1: Int { x + width }
    var y1: Int { y + height }
    var centerX: Int { x + width / 2 }
    var centerY: Int { y + height / 2 }

    init(
        x: Int, y: Int,
        width: Int, height: Int,
        stroke: Int = Constants.windowStroke,
        screen: ST7789
    ) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.stroke = stroke
        self.screen = screen
    }

    func draw() {
        screen.drawEmptyRect(
            at: (x - stroke, y - stroke),
            width: width + stroke * 2,
            height: height + stroke * 2,
            stroke: Constants.windowStroke,
            color: Constants.windowOutline)
    }
}


struct Ball {
    var x: Int
    var y: Int
    let size: Int

    var xSpeed: Int
    var ySpeed: Int

    // ms
    var movePeriod: Int = Constants.ballInitialMovingPeriod

    let color: UInt16
    let screen: ST7789

    let ySpeedOptions = [-3, -2, -1, 1, 2, 3]

    init(x: Int, y: Int, size: Int, color: UInt16, screen: ST7789) {
        self.x = x
        self.y = y
        self.size = size

        self.screen = screen
        self.color = color

        xSpeed = 3
        ySpeed = ySpeedOptions.randomElement()!
    }

    // Reset the ball's position and speed. Then redraw it.
    mutating func reset(in window: Window) {
        x = window.centerX
        y = Int.random(in: window.centerY-30...window.centerY+30)

        movePeriod = Constants.ballInitialMovingPeriod

        xSpeed.negate()
        ySpeed = ySpeedOptions.randomElement()!

        draw(at: (x,y), color)
    }

    // Update ball's position.
    mutating func nextPos() {
        x += xSpeed
        y += ySpeed
    }

    func hitWall(window: Window) -> Bool {
        return y < window.y || y > window.y1 - size
    }

    mutating func updateAfterHitWall(window: Window) {
        ySpeed.negate()
        y = y < window.y ? window.y : window.y1 - size
    }

    // After the ball hits the paddle, update its moving direction to bounce it.
    // Besides, speed up ball's movement.
    mutating func bounce(_ paddle: Paddle) {
        x = paddle.left ? paddle.x + paddle.width : paddle.x - size
        xSpeed.negate()

        if movePeriod > 10 {
            movePeriod -= 1
        }
    }

    // Draw the ball.
    func draw(at pos: Point, _ color: UInt16) {
        screen.drawRect(at: pos, width: size, height: size, color: color)
    }

    // Clear the ball from its previous position and draw it at new position.
    func update(lastPos: Point, bgColor: UInt16) {
        screen.update(width: size, height: size, from: lastPos, bgColor: bgColor, to: (x,y), color: color)
    }
}


struct Paddle {
    let x: Int
    var y: Int

    let left: Bool

    let height: Int
    let width: Int

    let color: UInt16
    let screen: ST7789

    var score: Int = 0

    func draw() {
        screen.drawRect(at: (x,y), width: width, height: height, color: color)
    }

    // Update paddle's position by wiping it from previous position and redraw
    // on its new position.
    // The paddle moves vertically, so x coordinate isn't considered.
    mutating func update(newY: Int, bgColor: UInt16) {
        if newY != y {
            screen.update(width: width, height: height, from: (x,y), bgColor: bgColor, to: (x, newY), color: color)
            y = newY
        }
    }

    // Check if the paddle hits the ball.
    func hit(_ ball: Ball) -> Bool {
        return (ball.y >= y - ball.size && ball.y <= y + height) &&
        (((ball.x > x - ball.size) && !left) || ((ball.x < x + width) && left))
    }

    // Check if the paddle misses the ball, that is, the ball hits left/right wall.
    func miss(_ ball: Ball, window: Window) -> Bool {
        return (left && (ball.x < window.x)) || (!left && (ball.x > window.x1 - width))
    }
}


extension ST7789 {
    func drawRect(at point: Point, width: Int, height: Int, color: UInt16) {
        for py in point.y..<(point.y + height) {
            for px in point.x..<(point.x + width) {
                writePixel(x: px, y: py, color: color)
            }
        }
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

    func update(
        width: Int, height: Int,
        from lastPos: Point, bgColor: UInt16,
        to newPos: Point, color: UInt16)
    {
        var x0 = 0
        var x1 = 0
        if lastPos.x < newPos.x {
            x0 = lastPos.x
            x1 = newPos.x + width
        } else {
            x0 = newPos.x
            x1 = lastPos.x + width
        }

        var y0 = 0
        var y1 = 0
        if lastPos.y < newPos.y {
            y0 = lastPos.y
            y1 = newPos.y + height
        } else {
            y0 = newPos.y
            y1 = lastPos.y + height
        }

        var buffer = [UInt16](repeating: bgColor, count: (x1 - x0) * (y1 - y0))

        for py in newPos.y..<newPos.y + height {
            for px in newPos.x..<newPos.x + width {
                buffer[(py - y0) * (x1 - x0) + (px - x0)] = color
            }
        }

        buffer.withUnsafeBytes { ptr in
            writeBitmap(x: x0, y: y0, width: x1 - x0, height: y1 - y0, data: ptr)
        }
    }
}
