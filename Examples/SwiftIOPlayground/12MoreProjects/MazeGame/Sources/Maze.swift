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
    let canvas: Canvas

    var current = Point(0, 0)
    var grids: [Grid] = []
    var stack: [Point] = []

    init(width: Int, canvas: Canvas) {
        self.canvas = canvas
        self.width = width
        column = canvas.width / width
        row = canvas.height / width
        reset() 
    }

    // Reset all walls to their default state.
    mutating func reset() {
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
        canvas.fillRectangle(at: Point(0, 0), width: canvas.width, height: canvas.height, color: bgColor)

        // Draw all walls.
        for y in 0..<row {
            canvas.drawLine(from: Point(0, y * width), to: Point(canvas.width - 1, y * width), color: wallColor)
        }

        for x in 0..<column {
            canvas.drawLine(from: Point(x * width, 0), to: Point(x * width, canvas.height - 1), color: wallColor)
        }

        canvas.drawLine(from: Point(0, canvas.height - 1), to: Point(canvas.width - 1, canvas.height - 1), color: wallColor)
        canvas.drawLine(from: Point(canvas.width - 1, 0), to: Point(canvas.width - 1, canvas.height - 1), color: wallColor)
    }

    // Generate maze.
    mutating func generate() {
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

        drawGrids()
    }

    // Remove walls that have been eliminated during generation.
    mutating func drawGrids() {
        for grid in grids {
            if !grid.walls.top {
                canvas.drawLine(from: Point(grid.x * width + 1, grid.y * width), to: Point((grid.x + 1) * width - 1, grid.y * width), color: bgColor)
            }

            if !grid.walls.right {
                canvas.drawLine(from: Point((grid.x + 1) * width, grid.y * width + 1), to: Point((grid.x + 1) * width, (grid.y + 1) * width - 1), color: bgColor)
            }

            if !grid.walls.bottom {
                canvas.drawLine(from: Point(grid.x * width + 1, (grid.y + 1) * width), to: Point((grid.x + 1) * width - 1, (grid.y + 1) * width), color: bgColor)
            }

            if !grid.walls.left {
                canvas.drawLine(from: Point(grid.x * width, grid.y * width + 1), to: Point(grid.x * width, (grid.y + 1) * width - 1), color: bgColor)
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