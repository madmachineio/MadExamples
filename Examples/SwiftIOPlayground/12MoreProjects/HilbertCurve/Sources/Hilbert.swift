import MadGraphics

struct Hilbert {
    // The order of the Hilbert curve.
    let order: Int
    // The points of the Hilbert curve.
    var points = [Point]()

    let size: Int
    let total: Int

    // The four corners of a unit square.
    let unitSquarePoints = [Point(0, 0), Point(0, 1), Point(1, 1), Point(1, 0)]

    // Generate a Hilbert curve with a specified order.
    init(order: Int, canvas: Canvas) {
        self.order = order

        // Total number of points in the curve.
        size = Int(Float.pow(2, order))
        total = size * size
        for i in 0..<total {
            points.append(hilbert(i))
        }
    }

    // Generate the points of the Hilbert curve with the given index.
    func hilbert(_ i: Int) -> Point {
        var i = i
        // One of the four corners of the unit square, which serves as the initial point.
        var point = unitSquarePoints[i % 4]
        
        // Update the point iteratively.
        for j in 1..<order {
            let lastPoint = point
            let offset = Int(Float.pow(2, j))
            i /= 4
            
            // Update the point based on its corresponding quadrant.
            switch i % 4 {
            case 0:
                point.x = lastPoint.y
                point.y = lastPoint.x
            case 1:
                point.y += offset
            case 2: 
                point.x += offset
                point.y += offset
            case 3:
                point.x = offset - 1 - lastPoint.y
                point.y = offset - 1 - lastPoint.x
                point.x += offset
            default: break
            }
        }
        
        return point
    }
}