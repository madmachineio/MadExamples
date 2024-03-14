import ST7789
import SwiftIO

typealias Point = (x: Int, y: Int)

struct Food {
    var pos: Point
    let size = 10
    let color = UInt16(0xF81F).byteSwapped
    let strokeColor = UInt16(0xC618)

    // Generate food at a random position, ensuring it does not overlap with the snake.
    init(screen: ST7789, snakeBody: [Point]) {
        pos = (0, 0)
        createNew(snakeBody: snakeBody)
    }

    // Check if the snake eats the food.
    mutating func isEaten(at pos: Point) -> Bool {
        return pos.x == self.pos.x && pos.y == self.pos.y
    }

    mutating func createNew(snakeBody: [Point]) { 
        repeat {
            pos.x = Array(1..<screen.width / size).shuffled().randomElement()! * size
            pos.y = Array(1..<screen.height / size).shuffled().randomElement()! * size
        } while snakeBody.contains (where: { $0.x == pos.x && $0.y == pos.y })

        screen.drawSquare(at: pos, width: size, color: color, strokeColor: strokeColor)        
    }
}

struct Snake {
    let size = 10
    let color = UInt16(0x07FF).byteSwapped
    let strokeColor = UInt16(0xC618)
    var xSpeed: Int
    var ySpeed: Int
    
    var food: Food
    var body: [Point] = []

    let screen: ST7789
    var lastUpdateTime: Int64
    var end = false
    
    // Initialize the snake in the middle of the screen.
    init(screen: ST7789) {
        xSpeed = 1
        ySpeed = 0
        self.screen = screen

        let pos = (screen.width / 2, screen.height / 2)
        body.append(pos)
        
        food = Food(screen: screen, snakeBody: body)

        screen.drawSquare(at: pos, width: size, color: color, strokeColor: strokeColor)
        lastUpdateTime = getSystemUptimeInMilliseconds()
    }

    // Update direction.
    mutating func setSpeed(clockwise: Bool) {
        let direction = clockwise ? 1 : -1

        switch (xSpeed, ySpeed) {
        case (-1, 0):
            xSpeed = 0
            ySpeed = -direction
        case (0, -1):
            xSpeed = direction
            ySpeed = 0
        case (1, 0): 
            xSpeed = 0
            ySpeed = direction
        case (0, 1): 
            xSpeed = -direction
            ySpeed = 0
        default: break
        }
    }

    // Check if the snake collides with the wall or itself.
    mutating func gameOver() -> Bool {
        // Check if the snake's head collides with its own body.
        for i in 1..<body.count {
            if body[i].x == body[0].x && body[i].y == body[0].y { 
                return true
            }
        }

        // Check if the snake's head collides with the boundaries.
        return body[0].x > screen.width - size || body[0].x < 0 || body[0].y > screen.height - size || body[0].y < 0
    }

    // Move the snake in the specified direction.
    mutating func update() {
        for i in (1..<body.count).reversed() {
            body[i] = body[i-1]
        }

        body[0].x += xSpeed * size
        body[0].y += ySpeed * size
    }
    
    mutating func play() {
        let current = getSystemUptimeInMilliseconds()
        if current - lastUpdateTime >= 300 {
            let lastBody = body

            // Update snake's position.
            update()

            if gameOver() {
                end = true
                screen.clearScreen(UInt16(0xF800).byteSwapped)
            } else {
                screen.drawSquare(at: lastBody.last!, width: size, color: 0)
                screen.drawSquare(at: body[0], width: size, color: color, strokeColor: strokeColor)
                
                if food.isEaten(at: body[0]) {
                    food.createNew(snakeBody: body)

                    if let last = lastBody.last {
                        body.append(last)
                        screen.drawSquare(at: last, width: size, color: color, strokeColor: strokeColor)
                    }
                }
            }
        
            lastUpdateTime = current
        }
    }
}

extension ST7789 {
    func drawSquare(at point: Point, width: Int, color: UInt16, strokeColor: UInt16) {
        for py in (point.y + 1)..<(point.y + width - 1) {
            for px in (point.x + 1)..<(point.x + width - 1) {
                writePixel(x: px, y: py, color: color)
            }
        }

        for w in 0..<width {
            for line in 0..<1 {
                writePixel(x: point.x + w, y: point.y + line, color: strokeColor)
                writePixel(x: point.x + w, y: point.y + width - 1 + line, color: strokeColor)
            }
        }

        for h in 1..<(width - 1) {
            for line in 0..<1 {
                writePixel(x: point.x + line, y: point.y + h, color: 0)
                writePixel(x: point.x + width - 1 + line, y: point.y + h, color: strokeColor)
            }
        }
    }

    func drawSquare(at point: Point, width: Int, color: UInt16) {
        for py in point.y..<(point.y + width) {
            for px in point.x..<(point.x + width) {
                writePixel(x: px, y: py, color: color)
            }
        }
    }
}