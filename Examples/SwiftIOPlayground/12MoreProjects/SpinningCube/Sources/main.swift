import SwiftIO
import MadBoard
import ST7789
import MadGraphics
import RealModule

// Initialize the SPI pin and the digital pins for the LCD.
let bl = DigitalOut(Id.D2)
let rst = DigitalOut(Id.D12)
let dc = DigitalOut(Id.D13)
let cs = DigitalOut(Id.D5)
let spi = SPI(Id.SPI0, speed: 30_000_000)

// Initialize the LCD using the pins above. Rotate the screen to keep the original at the upper left.
let screen = ST7789(spi: spi, cs: cs, dc: dc, rst: rst, bl: bl, rotation: .angle90)

let colors: [Color] = [.red, .orange, .yellow, .lime, .blue, Color(0x4B0082), .purple]

let canvas = Canvas(width: screen.width, height: screen.height)
var frameBuffer = [UInt16](repeating: 0, count: 240 * 240)

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
var projectedPoints: [Point] = Array(repeating: Point(x: 0, y: 0), count: points.count)
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

    // Clear the cube from its last position
    for i in 0..<4 {
        drawLine(
            from: lastProjectedPoints[i], 
            to: lastProjectedPoints[(i + 1) % 4], 
            offset: offset, color: Color.black
        )
        drawLine(
            from: lastProjectedPoints[i + 4], 
            to: lastProjectedPoints[(i + 1) % 4 + 4], 
            offset: offset, color: Color.black
        )
        drawLine(
            from: lastProjectedPoints[i], 
            to: lastProjectedPoints[i + 4], 
            offset: offset, color: Color.black
        )
    }
    
    // Draw the cube in its current position.
    for i in 0..<4 {
        drawLine(
            from: projectedPoints[i], 
            to: projectedPoints[(i + 1) % 4], 
            offset: offset, color: colors[(3 * i) % colors.count]
        )
        drawLine(
            from: projectedPoints[i + 4], 
            to: projectedPoints[(i + 1) % 4 + 4], 
            offset: offset, color: colors[(3 * i + 1) % colors.count]
        )
        drawLine(
            from: projectedPoints[i], 
            to: projectedPoints[i + 4], 
            offset: offset, color: colors[(3 * i + 2) % colors.count]
        )
    }
    
    updateDisplay(canvas: canvas, frameBuffer: &frameBuffer, screen: screen)
    
    lastProjectedPoints = projectedPoints
    angle += 0.02

    sleep(ms: 10)
}

func drawLine(from p0: Point, to p1: Point, offset: Point, color: Color) {
    canvas.drawLine(
        from: Point(x: p0.x + offset.x, y: p0.y + offset.y), 
        to: Point(x: p1.x + offset.x, y: p1.y + offset.y), 
        color: color
    )
}

// Calculate the projection of a point onto a 2D plane using perspective projection. 
// `distance` refers to the distance from the viewer. 
func project(distance: Float, point: [[Float]]) -> [[Float]] {
    let z = 1 / (distance - point[2][0])
    let projectionMatrix: [[Float]] = [
        [z, 0, 0], 
        [0, z, 0]
    ]

    return matrixMultiply(projectionMatrix, point)
}

// Rotate a point around the x, y, and z axes by a given angle.
func rotate(_ point: [[Float]], angle: Float) -> [[Float]] {
    var rotated = matrixMultiply(rotateX(angle), point)
    rotated = matrixMultiply(rotateY(angle), rotated)
    rotated = matrixMultiply(rotateZ(angle), rotated)
    return rotated
}

// Rotate around x-axis.
func rotateX(_ angle: Float) -> [[Float]] {
    return [[1, 0, 0],
    [0, Float.cos(angle), -Float.sin(angle)],
    [0, Float.sin(angle), Float.cos(angle)]]
}

// Rotate around y-axis.
func rotateY(_ angle: Float) -> [[Float]] {
    return [[Float.cos(angle), 0, Float.sin(angle)],
    [0, 1, 0],
    [-Float.sin(angle), 0, Float.cos(angle)]]
}

// Rotate around z-axis.
func rotateZ(_ angle: Float) -> [[Float]] {
    return [[Float.cos(angle), -Float.sin(angle), 0],
    [Float.sin(angle), Float.cos(angle), 0],
    [0, 0, 1]]
}

func matrixMultiply(_ matrix1: [[Float]], _ matrix2: [[Float]]) -> [[Float]] {
    // Check if matrices are compatible for multiplication
    guard matrix1[0].count == matrix2.count else {
        return [[]]
    }

    // Initialize result matrix with zeros
    var result = Array(repeating: Array(repeating: Float(0), count: matrix2[0].count), count: matrix1.count)

    // Perform matrix multiplication
    for i in 0..<matrix1.count {
        for j in 0..<matrix2[0].count {
            for k in 0..<matrix2.count {
                result[i][j] += matrix1[i][k] * matrix2[k][j]
            }
        }
    }

    return result
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