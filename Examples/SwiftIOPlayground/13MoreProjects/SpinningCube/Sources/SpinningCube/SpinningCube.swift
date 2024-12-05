import SwiftIO
import MadBoard
import ST7789
import MadGraphics


@main
public struct SpinningCube {
    public static func main() {
        // Initialize the SPI pin and the digital pins for the LCD.
        let bl = DigitalOut(Id.D2)
        let rst = DigitalOut(Id.D12)
        let dc = DigitalOut(Id.D13)
        let cs = DigitalOut(Id.D5)
        let spi = SPI(Id.SPI0, speed: 30_000_000)

        // Initialize the LCD using the pins above. Rotate the screen to keep the original at the upper left.
        let screen = ST7789(spi: spi, cs: cs, dc: dc, rst: rst, bl: bl, rotation: .angle90)
        var screenBuffer = [UInt16](repeating: 0, count: screen.width * screen.height)

        let layer = Layer(at: Point.zero, anchorPoint: UnitPoint.zero, width: screen.width, height: screen.height)
        var frameBuffer = [UInt32](repeating: 0, count: screen.width * screen.height)

        let colors: [Color] = [.red, .orange, .yellow, .lime, .blue, Color(0x4B0082), .purple]

        // The vertices of the cube in 3D space.
        let points: [[Float]] = [
            [-0.5, -0.5, -0.5],
            [0.5, -0.5, -0.5],
            [0.5, 0.5, -0.5],
            [-0.5, 0.5, -0.5],
            
            [-0.5, -0.5, 0.5],
            [0.5, -0.5, 0.5],
            [0.5, 0.5, 0.5],
            [-0.5, 0.5, 0.5]
        ]

        // The coordinates on 2D plan of cube vertices.
        var projectedPoints = [Point](repeating: Point.zero, count: points.count)
        var lastProjectedPoints = projectedPoints

        var angle: Float = 0
        let width: Float = 200
        let offset = Point(x: 120, y: 120)

        while true {
            // Rotate vertices of the cube and project them onto a 2D plane using perspective projection.
            for i in points.indices {
                let rotated = rotate([[points[i][0]], [points[i][1]], [points[i][2]]], angle: angle)
                let projected = project(distance: 2, point: rotated)
                projectedPoints[i] = Point(x: Int(projected[0][0] * width), y: Int(projected[1][0] * width))
            }

            // Draw the cube in its current position.
            for i in 0..<4 {
                layer.draw() { canvas in
                    canvas.drawLine(from: lastProjectedPoints[i] + offset,
                                    to: lastProjectedPoints[(i + 1) % 4] + offset,
                                    data: colors[(3 * i) % colors.count].rawValue)

                    canvas.drawLine(from: lastProjectedPoints[i + 4] + offset,
                                    to: lastProjectedPoints[(i + 1) % 4 + 4] + offset,
                                    data: colors[(3 * i + 1) % colors.count].rawValue)

                    canvas.drawLine(from: lastProjectedPoints[i] + offset,
                                    to: lastProjectedPoints[i + 4] + offset,
                                    data: colors[(3 * i + 2) % colors.count].rawValue)
                }
            }
            
            layer.render(into: &frameBuffer, output: &screenBuffer, transform: Color.getRGB565LE) { dirty, data in
                screen.writeBitmap(x: dirty.x, y: dirty.y, width: dirty.width, height: dirty.height, data: data)
            }
            
            sleep(ms: 10) 

            // Clear the cube from its last position
            for i in 0..<4 {
                layer.draw() { canvas in
                    canvas.drawLine(from: lastProjectedPoints[i] + offset,
                                    to: lastProjectedPoints[(i + 1) % 4] + offset,
                                    data: Color.black.rawValue)

                    canvas.drawLine(from: lastProjectedPoints[i + 4] + offset,
                                    to: lastProjectedPoints[(i + 1) % 4 + 4] + offset,
                                    data: Color.black.rawValue)

                    canvas.drawLine(from: lastProjectedPoints[i] + offset,
                                    to: lastProjectedPoints[i + 4] + offset,
                                    data: Color.black.rawValue)
                }
            }

            lastProjectedPoints = projectedPoints
            angle += 0.02
        }
    }
}