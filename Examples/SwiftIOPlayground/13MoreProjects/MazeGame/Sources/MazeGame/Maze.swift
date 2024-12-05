import MadGraphics
import ST7789
import SwiftIO

// Generate a random maze.
struct Maze {
    let width: Int
    let column: Int
    let row: Int

    let bgColor = Color(UInt32(0x3F52E3))
    let wallColor = Color.white
    let canvasSize: Size

    var current = Point(0, 0)
    var grids: [Grid] = []
    var stack: [Point] = []

    init(width: Int, layer: Layer) {
        self.canvasSize = layer.bounds.size
        self.width = width
        column = canvasSize.width / width
        row = canvasSize.height / width
        reset(layer) 
    }

    // Reset all walls to their default state.
    mutating func reset(_ layer: Layer) {
        grids = []
        stack = []
        current = Point(0, 0)

        // Initially, all walls are present.
        for y in 0..<row {
            for x in 0..<column {
                grids.append(Grid(x: x, y: y))
            }
        }

        // Draw background.
        layer.draw() { canvas in
            canvas.fillRectangle(at: Point(0, 0), width: canvasSize.width, height: canvasSize.height, data: bgColor.rawValue)
        }

        // Draw all walls.
        for y in 0..<row {
            layer.draw() { canvas in
                canvas.drawLine(from: Point(0, y * width), to: Point(canvasSize.width - 1, y * width), data: wallColor.rawValue)
            }
        }

        for x in 0..<column {
            layer.draw() { canvas in
                canvas.drawLine(from: Point(x * width, 0), to: Point(x * width, canvasSize.height - 1), data: wallColor.rawValue)
            }
        }

        layer.draw() { canvas in
            canvas.drawLine(from: Point(0, canvasSize.height - 1), to: Point(canvasSize.width - 1, canvasSize.height - 1), data: wallColor.rawValue)
        }
        layer.draw() { canvas in
            canvas.drawLine(from: Point(canvasSize.width - 1, 0), to: Point(canvasSize.width - 1, canvasSize.height - 1), data: wallColor.rawValue)
        }
    }

    // Generate maze.
    mutating func generate(_ layer: Layer) {
        while !finishGenerate() {
            // Update the state of current cell.
            grids[getIndex(current)].visited = true

            // If there are unvisited cells nearby, choose one randomly.
            // If not, backtrack to the previous cell to search for available unvisited cells afterward.
            if let next = getNext() {
                grids[getIndex(next)].visited = true
                stack.append(current)
                removeWall(current, next)
                current = next
            } else {
                if let last = stack.popLast() {
                    current = last
                }
            }
        }

        drawGrids(layer)
    }

    // Remove walls that have been eliminated during generation.
    func drawGrids(_ layer: Layer) {
        for grid in grids {
            if !grid.walls.top {
                layer.draw() { canvas in
                    canvas.drawLine(from: Point(grid.x * width + 1, grid.y * width), to: Point((grid.x + 1) * width - 1, grid.y * width), data: bgColor.rawValue)
                }
            }

            if !grid.walls.right {
                layer.draw() { canvas in
                    canvas.drawLine(from: Point((grid.x + 1) * width, grid.y * width + 1), to: Point((grid.x + 1) * width, (grid.y + 1) * width - 1), data: bgColor.rawValue)
                }
            }

            if !grid.walls.bottom {
                layer.draw() { canvas in
                    canvas.drawLine(from: Point(grid.x * width + 1, (grid.y + 1) * width), to: Point((grid.x + 1) * width - 1, (grid.y + 1) * width), data: bgColor.rawValue)
                }
            }

            if !grid.walls.left {
                layer.draw() { canvas in
                    canvas.drawLine(from: Point(grid.x * width, grid.y * width + 1), to: Point(grid.x * width, (grid.y + 1) * width - 1), data: bgColor.rawValue)
                }
            }
        }
    }

    // Verify if the maze is completed by ensuring that all cells have been visited.
    func finishGenerate() -> Bool {
        return grids.filter { !$0.visited }.count == 0
    }

    // Calculate the index of a cell in the array.
    func getIndex(_ point: Point) -> Int {
        return point.x + point.y * column
    }

    // Remove the wall between two cells.
    mutating func removeWall(_ current: Point, _ next: Point) {
        let x = current.x - next.x

        if x == 1 {
            grids[getIndex(current)].walls.left = false
            grids[getIndex(next)].walls.right = false
        } else if x == -1 {
            grids[getIndex(current)].walls.right = false
            grids[getIndex(next)].walls.left = false
        }

        let y = current.y - next.y

        if y == 1 {
            grids[getIndex(current)].walls.top = false
            grids[getIndex(next)].walls.bottom = false
        } else if y == -1 {
            grids[getIndex(current)].walls.bottom = false
            grids[getIndex(next)].walls.top = false
        }
    }

    // Find nearby cells that haven't been visited yet, and select one randomly.
    func getNext() -> Point? {
        var neighbors: [Point] = []

        if current.y > 0 {
            let top = Point(current.x, current.y - 1)
            
            if !grids[getIndex(top)].visited {
                neighbors.append(top)
            }
        }
        if current.x < column - 1 {
            let right = Point(current.x + 1, current.y)
            
            if !grids[getIndex(right)].visited {
                neighbors.append(right)
            }
        }
        
        if current.y < row - 1 {
            let bottom = Point(current.x, current.y + 1)
            if !grids[getIndex(bottom)].visited {
                neighbors.append(bottom)
            }
        }
        
        if current.x > 0 {
            let left = Point(current.x - 1, current.y)
            if !grids[getIndex(left)].visited {
                neighbors.append(left)
            }
        }

        return neighbors.randomElement()
    }
}