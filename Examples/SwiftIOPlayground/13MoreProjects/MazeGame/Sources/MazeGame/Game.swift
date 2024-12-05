import MadGraphics
import ST7789
import SwiftIO

// Place a ball at the upper left corner of the maze and move it based on acceleration.
// If the ball reaches the destination (bottom right), the game ends.
// Press the D1 button to restart the game.
class Game {
    var maze: Maze
    var ball: Ball
    let ballColor = Color(UInt32(0xEFE891))

    let width = 20
    var speed = 2

    let screen: ST7789
    let layer: Layer
    var frameBuffer: [UInt32]
    var screenBuffer: [UInt16]

    init(screen: ST7789, layer: Layer) {
        ball = Ball(at: Point(x: 1, y: 1), size: 7)
        maze = Maze(width: width, layer: layer)
        frameBuffer = [UInt32](repeating: 0, count: layer.bounds.width * layer.bounds.height)
        screenBuffer = [UInt16](repeating: 0, count: layer.bounds.width * layer.bounds.height)
        self.screen = screen
        self.layer = layer

        maze.generate(layer)

        layer.draw() { canvas in
            canvas.fillRectangle(at: Point(ball.x1, ball.y1), width: ball.size, height: ball.size, data: ballColor.rawValue)
        }

        layer.render(into: &frameBuffer, output: &screenBuffer, transform: Color.getRGB565LE) { dirty, data in
            screen.writeBitmap(x: dirty.x, y: dirty.y, width: dirty.width, height: dirty.height, data: data)
        }
    }

    // Create a new maze and place the ball at the starting point.
    func reset() {
        maze.reset(layer)
        maze.generate(layer)

        layer.draw() { canvas in
            canvas.fillRectangle(at: Point(ball.x1, ball.y1), width: ball.size, height: ball.size, data: maze.bgColor.rawValue)
        }
        ball = Ball(at: Point(x: 1, y: 1), size: 7)

        layer.draw() { canvas in
            canvas.fillRectangle(at: Point(ball.x1, ball.y1), width: ball.size, height: ball.size, data: ballColor.rawValue)
        }

        layer.render(into: &frameBuffer, output: &screenBuffer, transform: Color.getRGB565LE) { dirty, data in
            screen.writeBitmap(x: dirty.x, y: dirty.y, width: dirty.width, height: dirty.height, data: data)
        }
    }

    // Update the display to show that the game has finished.
    func finishGame() {
        layer.draw() { canvas in
            canvas.fillRectangle(at: Point(0, 0), width: canvas.width, height: canvas.height, data: Color.red.rawValue)
        }

        let font = Font(path: "/lfs/Resources/Fonts/Roboto-Regular.ttf", pointSize: 10, dpi: 220)

        let text1 = TextLayer(at: Point(x: layer.bounds.size.halfWidth, y: 60), anchorPoint: UnitPoint.center, string: "Good Job!", font: font, foregroundColor: Color.white)

        font.setSize(pointSize: 6)
        let text2 = TextLayer(at: Point(x: layer.bounds.size.halfWidth, y: 140), anchorPoint: UnitPoint.center, string: "Press D1 to continue", font: font, foregroundColor: Color.white)
        
        layer.append(text1)
        layer.append(text2)

        layer.render(into: &frameBuffer, output: &screenBuffer, transform: Color.getRGB565LE) { dirty, data in
            screen.writeBitmap(x: dirty.x, y: dirty.y, width: dirty.width, height: dirty.height, data: data)
        }

        layer.removeAll()
    }

    // Verify if the ball has reached the bottom right corner of the maze.
    func finished() -> Bool {
        return ball.x1 / width == maze.column - 1 && ball.y1 / width == maze.row - 1
    }

    // Update the ball's position based on the acceleration.
    func update(_ acceleration: (x: Float, y: Float, z: Float)) {
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
            layer.draw() { canvas in
                canvas.fillRectangle(at: lastBallPos, width: ball.size, height: ball.size, data: maze.bgColor.rawValue)
            }
            layer.draw() { canvas in
                canvas.fillRectangle(at: Point(ball.x1, ball.y1), width: ball.size, height: ball.size, data: ballColor.rawValue)
            }
            layer.render(into: &frameBuffer, output: &screenBuffer, transform: Color.getRGB565LE) { dirty, data in
                screen.writeBitmap(x: dirty.x, y: dirty.y, width: dirty.width, height: dirty.height, data: data)
            }
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
}