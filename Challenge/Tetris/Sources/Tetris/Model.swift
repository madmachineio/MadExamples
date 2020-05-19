struct GameData {
    var lines = 0
    var score = 0
    var level = 1
    var timerDuration = 500

    private func addScore(_ clearLineCount: Int) -> Int {
        var count = 1

        switch clearLineCount {
            case 2:
                count = 3 * level
            case 3:
                count = 6 * level
            case 4:
                count = 10 * level
            default:
                count = level
        }
        return count
    }

    private func calcLevel(_ lines: Int) -> Int {
        var value = lines / 8 + 1
        value = value > 9 ? 9 : value
        return value
    }

    private func calcTimerDuration(_ level: Int) -> Int {
        return 560 - 60 * level
    }

    mutating func update(_ clearedLines: [Int]) {
        let count = clearedLines.count

        if count > 0 {
            lines += count
            score += addScore(count)
            level = calcLevel(lines)
            timerDuration = calcTimerDuration(level)
        }
    }
}

struct Playground {

    static let RotateTable: [[(x: Int, y: Int)]] = [
        [(0, 0), (-1, 0), (-1, -1), (0, 2), (-1, 2)],
        [(0, 0), (1, 0), (1, 1), ( 0, -2), (1, -2)],
        [(0, 0), (1, 0), (1, -1), (0, 2), (1, 2)],
        [(0, 0), (1, 0), (1, 1), (0, -2), (1, -2)]
    ]

    static let IRotateTable: [[(x: Int, y: Int)]] = [
        [(0, 0), (-2, 0), (1, 0), (-2, 1), (1, -2)],
        [(0, 0), (-1, 0), (2, 0), (-1, -2), (2, 1)],
        [(0, 0), (2, 0), (-1, 0), (2, -1), (-1, 2)],
        [(0, 0), (1, 0), (-2, 0), (1, 2), (-2, -1)]
    ]

    let width = 10, height = 20

    mutating func mark(_ x: Int, _ y: Int, _ value: Int) {
        guard x >= 0 && y >= 0 && x < width && y < height else { return }
        screen[y][x] = value
    }

    func testMove(_ block: Block, to dir: MoveDirection) -> Bool {
        let image = block.getImage()
        let imageHeight = block.imageHeight
        let imageWidth = block.imageWidth

        var imageX = block.x
        var imageY = block.y

        switch dir {
            case .down:
                imageY += 1
            case .left:
                imageX -= 1
            case .right:
                imageX += 1
        }

        var scanX = 0, scanY = 0
        for x in 0..<imageWidth {
            for y in 0..<imageHeight {
                scanX = imageX + x
                scanY = imageY + y
                if image[y][x] == false || scanY < 0 {
                    continue
                } 
                if scanX < 0 || scanX >= width || scanY >= height {
                    return false
                }
                if screen[scanY][scanX] > 0 {
                    return false
                }
            }
        }

        return true
    }
    enum MoveDirection {
        case left, right, down
    }

    var screen = [[Int]](repeating: [Int](repeating: 0x00, count: 10), count: 20)

    func getScreen() -> [[Int]] {
        return screen
    }

    mutating func tryMove(_ block: inout Block, to dir: MoveDirection) -> Bool {
        let ret = testMove(block, to: dir)
        if ret {
            switch dir {
                case .left:
                block.stepLeft()
                case .right:
                block.stepRight()
                case .down:
                block.stepDown()
            }
        }
        return ret
    }

    mutating func tryRotate(_ block: inout Block) -> Bool {
        let rotateTable: [[(x: Int, y: Int)]]

        switch block.name {
            case .O:
            return true
            case .I:
            rotateTable = Playground.IRotateTable
            default:
            rotateTable = Playground.RotateTable
        }

        let image = block.getRotateImage()
        let imageHeight = block.imageHeight
        let imageWidth = block.imageWidth
        let imageDir = block.currentDirection

        let imageX = block.x
        let imageY = block.y

        var tempX = 0, tempY = 0

        var result: Bool = true
        var scanX = 0, scanY = 0
        for i in 0..<rotateTable[imageDir].count {
            result = true
            tempX = imageX + rotateTable[imageDir][i].x
            tempY = imageY + rotateTable[imageDir][i].y
            for x in 0..<imageWidth {
                for y in 0..<imageHeight {
                    scanX = tempX + x
                    scanY = tempY + y
                    if image[y][x] == false || scanY < 0 {
                        continue
                    } 
                    if scanX < 0 || scanX >= width || scanY >= height {
                        result = false
                        break
                    }
                    if screen[scanY][scanX] > 0 {
                        result = false
                        break
                    }
                }
            }
            if result {
                block.x = tempX
                block.y = tempY
                block.rotate()
                break
            }
        }

        return result
    }

    func isGameOver(_ block: Block) -> Bool {
        if !testMove(block, to: .down) && block.y <= -2 {
            return true
        }
        return false
    }

    mutating func merge(_ block: Block) {
        let image = block.getImage()
        let imageHeight = block.imageHeight
        let imageWidth = block.imageWidth

        let imageX = block.x
        let imageY = block.y

        var posX, posY: Int

        for x in 0..<imageWidth {
            for y in 0..<imageHeight {
                if image[y][x] {
                    posX = imageX + x
                    posY = imageY + y
                    mark(posX, posY, block.name.rawValue)
                }
            }
        }
    }

    func checkFullLines() -> [Int] {
        var fullLines = [Int]()
        
            for y in 0..<height {
                for x in 0..<width {
                    if screen[y][x] == 0 {
                        break
                    } else if x == width - 1 {
                        fullLines.append(y)
                    }
                }
            }

        return fullLines
    }

    mutating func clearLine(at lines: [Int]) {
        let newLine = [Int](repeating: 0x00, count: width)

        for line in lines {
            screen.remove(at: line)
            screen.insert(newLine, at: 0)
        }
    }
}






struct Block {
    enum Name: Int {
        case J = 1, L, Z, S, T, I, O
    }

    let name: Name
    let imageWidth = 4, imageHeight = 4
    var x = 3, y = -2
    var currentDirection = 0
    var currentBlock = [[[Bool]]]()

    init() {
        name = Name(rawValue: Int.random(in: 1...7))!
        switch name {
            case .J:
            currentBlock = Block.JBlock
            case .L:
            currentBlock = Block.LBlock
            case .Z:
            currentBlock = Block.ZBlock
            case .S:
            currentBlock = Block.SBlock
            case .T:
            currentBlock = Block.TBlock
            case .I:
            currentBlock = Block.IBlock
            case .O:
            currentBlock = Block.OBlock
        }
    }

    func getImage() -> [[Bool]] {
        return currentBlock[currentDirection]
    }

    func getRotateImage() -> [[Bool]] {
        let maxDirections = currentBlock.count

        var dir = currentDirection + 1
        if dir == maxDirections {
            dir = 0
        }

        return currentBlock[dir]
    }
    
    mutating func rotate() {
        let maxDirections = currentBlock.count
        currentDirection += 1
        if currentDirection == maxDirections {
            currentDirection = 0
        }
    }

    mutating func stepDown() {
        y += 1
    }

    mutating func stepLeft() {
        x -= 1
    }

    mutating func stepRight() {
        x += 1
    }
}


extension Block {
    static let SBlock: [[[Bool]]] = [
        [
            [false, true, true, false],
            [true, true, false, false],
            [false, false, false, false],
            [false, false, false, false]
        ],
        [
            [false, true, false, false],
            [false, true, true, false],
            [false, false, true, false],
            [false, false, false, false]
        ],
        [
            [false, false, false, false],
            [false, true, true, false],
            [true, true, false, false],
            [false, false, false, false]
        ],
        [
            [true, false, false, false],
            [true, true, false, false],
            [false, true, false, false],
            [false, false, false, false]
        ]
    ]

    static let ZBlock: [[[Bool]]] = [
        [
            [true, true, false, false],
            [false, true, true, false],
            [false, false, false, false],
            [false, false, false, false]
        ],
        [
            [false, false, true, false],
            [false, true, true, false],
            [false, true, false, false],
            [false, false, false, false]
        ],
        [
            [false, false, false, false],
            [true, true, false, false],
            [false, true, true, false],
            [false, false, false, false]
        ],
        [
            [false, true, false, false],
            [true, true, false, false],
            [true, false, false, false],
            [false, false, false, false]
        ]
    ]

    static let LBlock: [[[Bool]]] = [
        [
            [false, false, true, false],
            [true, true, true, false],
            [false, false, false, false],
            [false, false, false, false]
        ],
        [
            [false, true, false, false],
            [false, true, false, false],
            [false, true, true, false],
            [false, false, false, false]
        ],
        [
            [false, false, false, false],
            [true, true, true, false],
            [true, false, false, false],
            [false, false, false, false]
        ],
        [
            [true, true, false, false],
            [false, true, false, false],
            [false, true, false, false],
            [false, false, false, false]
        ]
    ]

    static let JBlock: [[[Bool]]] = [
        [
            [true, false, false, false],
            [true, true, true, false],
            [false, false, false, false],
            [false, false, false, false]
        ],
        [
            [false, true, true, false],
            [false, true, false, false],
            [false, true, false, false],
            [false, false, false, false]
        ],
        [
            [false, false, false, false],
            [true, true, true, false],
            [false, false, true, false],
            [false, false, false, false]
        ],
        [
            [false, true, false, false],
            [false, true, false, false],
            [true, true, false, false],
            [false, false, false, false]
        ]
    ]

    static let TBlock: [[[Bool]]] = [
        [
            [false, true, false, false],
            [true, true, true, false],
            [false, false, false, false],
            [false, false, false, false]
        ],
        [
            [false, true, false, false],
            [false, true, true, false],
            [false, true, false, false],
            [false, false, false, false]
        ],
        [
            [false, false, false, false],
            [true, true, true, false],
            [false, true, false, false],
            [false, false, false, false]
        ],
        [
            [false, true, false, false],
            [true, true, false, false],
            [false, true, false, false],
            [false, false, false, false]
        ]
    ]

    static let IBlock: [[[Bool]]] = [
        [
            [false, false, false, false],
            [true, true, true, true],
            [false, false, false, false],
            [false, false, false, false]
        ],
        [
            [false, false, true, false],
            [false, false, true, false],
            [false, false, true, false],
            [false, false, true, false]
        ],
        [
            [false, false, false, false],
            [false, false, false, false],
            [true, true, true, true],
            [false, false, false, false]
        ],
        [
            [false, true, false, false],
            [false, true, false, false],
            [false, true, false, false],
            [false, true, false, false]
        ]
    ]

    static let OBlock: [[[Bool]]] = [
        [
            [false, true, true, false],
            [false, true, true, false],
            [false, false, false, false],
            [false, false, false, false]
        ]
    ]
}



