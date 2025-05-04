import MadGraphics
import SwiftIO
import ST7789

enum Eyes: Int, CaseIterable {
    case close
    case normal
    case blink
    case happy
    case sad
    case upset
    case angry
    case wonder
    case move
    case saccade
}

class EyesAnimation {
    let screen: ST7789
    var screenBuffer: [UInt16]
    let canvas: Canvas
    let eyeColor: Pixel
    let backgroundColor: Pixel

    init(screen: ST7789) {
        self.screen = screen
        canvas = Canvas(width: screen.width, height: screen.height)
        screenBuffer = [UInt16](repeating: 0, count: screen.width * screen.height)
        backgroundColor = Pixel.black
        eyeColor = Pixel.aqua
    }

    func draw(eyes: Eyes) {
        switch eyes {
        case .close: 
            close()
            updateDisplay(canvas: canvas, screenBuffer: &screenBuffer, screen: screen)
        case .normal: 
            normal()
            updateDisplay(canvas: canvas, screenBuffer: &screenBuffer, screen: screen)
        case .blink: 
            blink()
        case .happy:
            happy()
        case .sad: 
            sad()
        case .upset:
            upset()
        case .angry: 
            angry()
        case .wonder:
            wonder()
        case .move:
            move(right: false)
            sleep(ms: 200)
            move(right: true)
        case .saccade:
            saccade(right: 0, up: 1)
            sleep(ms: 200)
            saccade(right: -1, up: 0)
            sleep(ms: 200)
            saccade(right: 0, up: -1)
            sleep(ms: 200)
            saccade(right: 1, up: 0)
            sleep(ms: 200)
        }
    }

    func close() {
        _ = canvas.fillRectangle(at: Point.zero, width: canvas.width, height: canvas.height, data: backgroundColor)
        _ = canvas.fillRoundedRectangle(at: Point(10, 105), width: 100, height: 30, radius: 10, data: eyeColor)
        _ = canvas.fillRoundedRectangle(at: Point(130, 105), width: 100, height: 30, radius: 10, data: eyeColor) 
    }

    func normal() {
        _ = canvas.fillRectangle(at: Point.zero, width: canvas.width, height: canvas.height, data: backgroundColor)
        _ = canvas.fillRoundedRectangle(at: Point(20, 85), width: 80, height: 70, radius: 24, data: eyeColor)
        _ = canvas.fillRoundedRectangle(at: Point(140, 85), width: 80, height: 70, radius: 24, data: eyeColor) 
    }

    func blink() {
        normal()
        updateDisplay(canvas: canvas, screenBuffer: &screenBuffer, screen: screen)
        sleep(ms: 500)

        close()
        updateDisplay(canvas: canvas, screenBuffer: &screenBuffer, screen: screen)
        sleep(ms: 100)

        normal()
        updateDisplay(canvas: canvas, screenBuffer: &screenBuffer, screen: screen)
    }

    func happy() {
        for i in 0...5 {
            normal()
            _ = canvas.fillCircle(at: Point(60, 200 - i * 5), radius: 60, data: backgroundColor) 
            _ = canvas.fillCircle(at: Point(180, 200 - i * 5), radius: 60, data: backgroundColor) 
            updateDisplay(canvas: canvas, screenBuffer: &screenBuffer, screen: screen)
            sleep(ms: 50)
        }
    }

    func sad() {
        for i in 0...5 {
            normal()
            _ = canvas.fillTriangle(Point(15, 85), Point(120, 85), Point(15, 90 + i * 6), data: backgroundColor)
            _ = canvas.fillTriangle(Point(120, 85), Point(225, 85), Point(225, 90 + i * 6), data: backgroundColor)
            updateDisplay(canvas: canvas, screenBuffer: &screenBuffer, screen: screen)
            sleep(ms: 50)
        }
    }

    func upset() {
        for i in 0...5 {
            normal()
            _ = canvas.fillRectangle(at: Point(20, 85), width: 85, height: 10 + i * 5, data: backgroundColor)
            _ = canvas.fillRectangle(at: Point(140, 85), width: 85, height: 10 + i * 5, data: backgroundColor)
            updateDisplay(canvas: canvas, screenBuffer: &screenBuffer, screen: screen)
            sleep(ms: 50)
        }
    }

    func angry() {
        for i in 0...5 {
            normal()
            _ = canvas.fillTriangle(Point(15, 85), Point(225, 85), Point(120, 90 + i * 6), data: backgroundColor)
            updateDisplay(canvas: canvas, screenBuffer: &screenBuffer, screen: screen)
            sleep(ms: 50)
        }   
    }

    func wonder() {
        for i in 0...5 {
            _ = canvas.fillRectangle(at: Point.zero, width: canvas.width, height: canvas.height, data: backgroundColor)
            let change = i * 4
            _ = canvas.fillRoundedRectangle(at: Point(20, 105 - change), width: 80, height: 50 + change, radius: 20, data: eyeColor)
            _ = canvas.fillRoundedRectangle(at: Point(140, 85 + change), width: 80, height: 70 - change, radius: 20, data: eyeColor) 
            updateDisplay(canvas: canvas, screenBuffer: &screenBuffer, screen: screen)
            sleep(ms: 50)
        }

        for i in 0...5 {
            _ = canvas.fillRectangle(at: Point.zero, width: canvas.width, height: canvas.height, data: backgroundColor)
            let change = i * 4
            _ = canvas.fillRoundedRectangle(at: Point(20, 85 + change), width: 80, height: 70 - change, radius: 20, data: eyeColor)
            _ = canvas.fillRoundedRectangle(at: Point(140, 85), width: 80, height: 70, radius: 20, data: eyeColor) 
            updateDisplay(canvas: canvas, screenBuffer: &screenBuffer, screen: screen)
            sleep(ms: 50)
        }
    }

    func move(right: Bool) {
        let direction = right ? 1 : -1

        var leftEyePos = Point(20, 85)
        var leftEyeSize = Size(width: 80, height: 70)
        var rightEyePos = Point(140, 85)
        var rightEyeSize = Size(width: 80, height: 70)

        // Move the eyes to the left or right and simulate the action of closing the eyes.
        for _ in 0..<3 {
            leftEyePos.x += 2 * direction
            rightEyePos.x += 2 * direction
            leftEyeSize.height -= 6
            rightEyeSize.height -= 6

            if right {
                rightEyeSize.width += 1
                rightEyeSize.height += 3
            } else {
                leftEyeSize.width += 1
                leftEyeSize.height += 3
            }

            leftEyePos.y = (canvas.height - leftEyeSize.height) / 2
            rightEyePos.y = (canvas.height - rightEyeSize.height) / 2

            _ = canvas.fillRectangle(at: Point.zero, width: canvas.width, height: canvas.height, data: backgroundColor)
            drawEyes(leftEyePos: leftEyePos, leftEyeSize: leftEyeSize, rightEyePos: rightEyePos, rightEyeSize: rightEyeSize)
            sleep(ms: 100)
        }
        
        // Move the eyes to the left or right and simulate the action of opening the eyes.
        for _ in 0..<3 {
            leftEyePos.x += 2 * direction
            rightEyePos.x += 2 * direction
            leftEyeSize.height += 6
            rightEyeSize.height += 6

            if right {
                rightEyeSize.width += 1
                rightEyeSize.height += 3
            } else {
                leftEyeSize.width += 1
                leftEyeSize.height += 3
            }

            leftEyePos.y = (canvas.height - leftEyeSize.height) / 2
            rightEyePos.y = (canvas.height - rightEyeSize.height) / 2
            drawEyes(leftEyePos: leftEyePos, leftEyeSize: leftEyeSize, rightEyePos: rightEyePos, rightEyeSize: rightEyeSize)
            sleep(ms: 100)
        }

        // Move the eyes back to their original position and and simulate the action of closing the eyes.
        for _ in 0..<3 {
            leftEyePos.x -= 2 * direction
            rightEyePos.x -= 2 * direction
            leftEyeSize.height -= 6
            rightEyeSize.height -= 6

            if right {
                rightEyeSize.width -= 1
                rightEyeSize.height -= 3
            } else {
                leftEyeSize.width -= 1
                leftEyeSize.height -= 3
            }

            leftEyePos.y = (canvas.height - leftEyeSize.height) / 2
            rightEyePos.y = (canvas.height - rightEyeSize.height) / 2
            drawEyes(leftEyePos: leftEyePos, leftEyeSize: leftEyeSize, rightEyePos: rightEyePos, rightEyeSize: rightEyeSize)
            sleep(ms: 100)
        }

        // Move the eyes back to their original position and and simulate the action of opening the eyes.
        for _ in 0..<3 {
            leftEyePos.x -= 2 * direction
            rightEyePos.x -= 2 * direction
            leftEyeSize.height += 6
            rightEyeSize.height += 6

            if right {
                rightEyeSize.width -= 1
                rightEyeSize.height -= 3
            } else {
                leftEyeSize.width -= 1
                leftEyeSize.height -= 3
            }

            leftEyePos.y = (canvas.height - leftEyeSize.height) / 2
            rightEyePos.y = (canvas.height - rightEyeSize.height) / 2
            drawEyes(leftEyePos: leftEyePos, leftEyeSize: leftEyeSize, rightEyePos: rightEyePos, rightEyeSize: rightEyeSize)
            sleep(ms: 100)
        }
    }

    func drawEyes(leftEyePos: Point, leftEyeSize: Size, rightEyePos: Point, rightEyeSize: Size) {
        _ = canvas.fillRectangle(at: Point.zero, width: canvas.width, height: canvas.height, data: backgroundColor)
        _ = canvas.fillRoundedRectangle(at: leftEyePos, width: leftEyeSize.width, height: leftEyeSize.height, radius: 24, data: eyeColor)
        _ = canvas.fillRoundedRectangle(at: rightEyePos, width: rightEyeSize.width, height: rightEyeSize.height, radius: 24, data: eyeColor)
        updateDisplay(canvas: canvas, screenBuffer: &screenBuffer, screen: screen)
    }

    func saccade(right: Int, up: Int) {
        var leftEyePos = Point(20, 85)
        var leftEyeSize = Size(width: 80, height: 70)
        var rightEyePos = Point(140, 85)
        var rightEyeSize = Size(width: 80, height: 70)

        var directionX: Int
        var directionY: Int

        if right >= 1 {
            directionX = 1
        } else if right == 0 {
            directionX = 0
        } else {
            directionX = -1
        }

        if up >= 1 {
            directionY = -1
        } else if up == 0 {
            directionY = 0
        } else {
            directionY = 1
        }

        for _ in 0..<2 {
            leftEyePos.x += 6 * directionX
            leftEyePos.y += 10 * directionY
            rightEyePos.x += 6 * directionX
            rightEyePos.y += 10 * directionY

            rightEyeSize.height -= 8
            leftEyeSize.height -= 8

            drawEyes(leftEyePos: leftEyePos, leftEyeSize: leftEyeSize, rightEyePos: rightEyePos, rightEyeSize: rightEyeSize)
            sleep(ms: 100)

            leftEyePos.x += 6 * directionX
            leftEyePos.y += 10 * directionY
            rightEyePos.x += 6 * directionX
            rightEyePos.y += 10 * directionY

            rightEyeSize.height += 8
            leftEyeSize.height += 8

            drawEyes(leftEyePos: leftEyePos, leftEyeSize: leftEyeSize, rightEyePos: rightEyePos, rightEyeSize: rightEyeSize)
            sleep(ms: 100)

            directionX = -directionX
            directionY = -directionY
        }
    }

    func updateDisplay(canvas: Canvas, screenBuffer: inout [UInt16], screen: ST7789) {
        let dirty = Rect(Point.zero, width: canvas.width, height: canvas.height)
        var index = 0
        let stride = canvas.width
        let canvasBuffer = canvas.buffer

        for y in dirty.minY..<dirty.maxY {
            for x in dirty.minX..<dirty.maxX {
                screenBuffer[index] = Pixel.toRGB565LE(canvasBuffer[y * stride + x])
                index += 1
            }
        }
        
        screen.writeBitmap(x: dirty.x, y: dirty.y, width: dirty.width, height: dirty.height, data: screenBuffer)
    }
}