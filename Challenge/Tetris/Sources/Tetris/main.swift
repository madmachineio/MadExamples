import SwiftIO

let spi = SPI(Id.SPI0, speed: 40000000)
let dc = DigitalOut(Id.D0)
let rst = DigitalOut(Id.D1)
let colorLCD = ILI9341(spi: spi, dc: dc, rst: rst, direction: .vertical)

let spi1 = SPI(Id.SPI1, speed: 10000000)
let dc1 = DigitalOut(Id.D18)
let rst1 = DigitalOut(Id.D19)
let oled = SSD1315(spi: spi1, dc: dc1, rst: rst1)

let keypad = Keypad(left: Id.D40, right: Id.D41, down: Id.D39, rotate: Id.D38, select: Id.D42)


var playground = Playground()
var block = Block()
var nextBlock = Block()
var gameData = GameData()

let colorView = ColorView(lcd: colorLCD)
let monoView = MonoView(lcd: oled)

var viewDelegate: TetrisView
viewDelegate = colorView
viewDelegate.displayInit()
viewDelegate.updateNextImage(nextBlock)
viewDelegate.updatePlayground(playground)
viewDelegate.updateData(gameData)

var currentTime = getPowerUpMilliseconds()
var previousTime = currentTime
var duration: Int64 = 0

while true {
    currentTime = getPowerUpMilliseconds()
    duration += (currentTime - previousTime)

    let keyValue = keypad.getKeyState()

    if keyValue == .select {
        if viewDelegate is ColorView {
            viewDelegate = monoView
        } else {
            viewDelegate = colorView
        }
        viewDelegate.displayInit()
        viewDelegate.updatePlayground(playground)
        viewDelegate.updateBlock(block)
        viewDelegate.updateNextImage(nextBlock)
        viewDelegate.updateData(gameData)
    }

    if keyValue == .rotate {
        if playground.tryRotate(&block) {
            viewDelegate.updateBlock(block)
        }
    }
        
    if keyValue == .left {
        if playground.tryMove(&block, to: .left) {
            viewDelegate.updateBlock(block)
        }
    }
        
    if keyValue == .right {
       if playground.tryMove(&block, to: .right) {
            viewDelegate.updateBlock(block)
        }
    }
        
    if duration > gameData.timerDuration || keyValue == .down {
        duration = 0
        if playground.tryMove(&block, to: .down) {
            viewDelegate.updateBlock(block)
        } else if playground.isGameOver(block) {
            viewDelegate.gameOver()
        } else {
            playground.merge(block)
            let fullLines = playground.checkFullLines()
            if fullLines.count != 0 {
                gameData.update(fullLines)
                playground.clearLine(at: fullLines)
                viewDelegate.updateData(gameData)
            }
            block = nextBlock
            nextBlock = Block()
            viewDelegate.updatePlayground(playground)
            viewDelegate.updateNextImage(nextBlock)
        }
    }

    previousTime = currentTime
}