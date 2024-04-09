import MadGraphics

struct Ball {
    var x1: Int
    var y1: Int
    let size: Int

    var x2: Int {
        x1 + size
    }
    var y2: Int {
        y1 + size
    }

    init(at point: Point, size: Int) {
        x1 = point.x
        y1 = point.y
        self.size = size
    }
}