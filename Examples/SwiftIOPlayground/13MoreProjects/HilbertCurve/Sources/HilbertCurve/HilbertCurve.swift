import SwiftIO
import MadBoard
import ST7789
import MadGraphics

@main
public struct HilbertCurve {
    public static func main() {
        // Initialize the SPI pin and the digital pins for the LCD.
        let bl = DigitalOut(Id.D2)
        let rst = DigitalOut(Id.D12)
        let dc = DigitalOut(Id.D13)
        let cs = DigitalOut(Id.D5)
        let spi = SPI(Id.SPI0, speed: 30_000_000)

        // Initialize the LCD using the pins above. Rotate the screen to keep the original at the upper left.
        let screen = ST7789(spi: spi, cs: cs, dc: dc, rst: rst, bl: bl, rotation: .angle90)

        let width = 240
        let height = 240

        var screenBuffer = [UInt16](repeating: 0, count: width * height)

        // layer used to draw the Hilbert curve.
        let layer = Layer(at: Point.zero, anchorPoint: UnitPoint.zero, width: width, height: height)
        var frameBuffer = [UInt32](repeating: 0, count: width * height)

        var colorIndex = 0
        let colors: [Color] = [
            .red, .orange, .yellow, .lime, .blue, 
            Color(UInt32(0x4B0082)), Color(UInt32(0x9400D3))
        ]

        let minOrder = 1
        let maxOrder = 6
        var order = minOrder
        var increaseOrder = true

        var hilbert = Hilbert(order: order)
        // Scale and position each point to fit the layer.
        var length: Int { width / hilbert.size }

        var pointIndex = 1

        drawBorder()

        while true {
            if pointIndex == hilbert.total {
                // Generate a new Hilbert curve.
                order = increaseOrder ? order + 1 : order - 1

                if order == maxOrder {
                    increaseOrder = false
                } else if order == minOrder {
                    increaseOrder = true
                } 

                hilbert = Hilbert(order: order)
                // Clear the canvas.
                layer.draw() { canvas in
                    canvas.fill(Color.black.rawValue)
                }
                drawBorder()

                colorIndex = 0
                pointIndex = 1
                
                sleep(ms: 500)
            } else {
                // Draw a single line each time.
                drawLine(pointIndex)

                colorIndex = (pointIndex / 4) % colors.count
                pointIndex += 1
                
                sleep(ms: 2)
            }
        
            layer.render(into: &frameBuffer, output: &screenBuffer, transform: Color.getRGB565LE) { dirty, data in
                screen.writeBitmap(x: dirty.x, y: dirty.y, width: dirty.width, height: dirty.height, data: data)
            }
        }

        // Connect the given point with its preceding point on the curve.
        func drawLine(_ index: Int) {
            let x1 = hilbert.points[index - 1].x * length + length / 2
            let y1 = hilbert.points[index - 1].y * length + length / 2
            let x2 = hilbert.points[index].x * length + length / 2
            let y2 = hilbert.points[index].y * length + length / 2

            layer.draw() { canvas in 
                canvas.drawLine(from: Point(x1, y1), to: Point(x2, y2), data: colors[colorIndex].rawValue)
            }
        }

        // Outline the canvas with a border.
        func drawBorder() {
            layer.draw() { canvas in
                canvas.drawLine(from: Point(0, 0), to: Point(width - 1, 0), data: Color.silver.rawValue)
            }
            layer.draw() { canvas in
                canvas.drawLine(from: Point(0, height - 1), to: Point(width - 1, height - 1), data: Color.silver.rawValue)
            }
            layer.draw() { canvas in
                canvas.drawLine(from: Point(0, 0), to: Point(0, height - 1), data: Color.silver.rawValue)
            }
            layer.draw() { canvas in
                canvas.drawLine(from: Point(width - 1, 0), to: Point(width - 1, height - 1), data: Color.silver.rawValue)
            }
        }
    }
}