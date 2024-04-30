import SwiftIO
import MadBoard
import ST7789
import MadGraphics
import RealModule

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

        // Canvas used to draw the Hilbert curve.
        let canvas = Canvas(width: 128, height: 128)
        var frameBuffer = [UInt16](repeating: 0, count: canvas.width * canvas.height)

        var colorIndex = 0
        let colors: [Color] = [
            .red, .orange, .yellow, .lime, .blue, 
            Color(UInt32(0x4B0082)), Color(UInt32(0x9400D3))
        ]

        let minOrder = 1
        let maxOrder = 6
        var order = minOrder
        var increaseOrder = true

        var hilbert = Hilbert(order: order, canvas: canvas)
        // Scale and position each point to fit the canvas.
        var length: Int { canvas.width / hilbert.size }

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

                hilbert = Hilbert(order: order, canvas: canvas)
                // Clear the canvas.
                canvas.fillRectangle(at: Point(0, 0), width: canvas.width, height: canvas.height, color: Color.black)
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
        
            updateDisplay(canvas: canvas, frameBuffer: &frameBuffer, screen: screen)
        }

        // Connect the given point with its preceding point on the curve.
        func drawLine(_ index: Int) {
            let x1 = hilbert.points[index - 1].x * length + length / 2
            let y1 = hilbert.points[index - 1].y * length + length / 2
            let x2 = hilbert.points[index].x * length + length / 2
            let y2 = hilbert.points[index].y * length + length / 2
            
            canvas.drawLine(from: Point(x1, y1), to: Point(x2, y2), color: colors[colorIndex])
        }

        // Outline the canvas with a border.
        func drawBorder() {
            canvas.drawLine(from: Point(0, 0), to: Point(canvas.width - 1, 0), color: Color.silver)
            canvas.drawLine(from: Point(0, canvas.height - 1), to: Point(canvas.width - 1, canvas.height - 1), color: Color.silver)
            canvas.drawLine(from: Point(0, 0), to: Point(0, canvas.height - 1), color: Color.silver)
            canvas.drawLine(from: Point(canvas.width - 1, 0), to: Point(canvas.width - 1, canvas.height - 1), color: Color.silver)
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
}