import SwiftIO
//import TinyCanvas


protocol TetrisView {
    func displayInit()
    func updatePlayground(_ playground: Playground)
    func updateBlock(_ block: Block)
    func updateNextImage(_ block: Block)
    func updateData(_ data: GameData)
    func gameOver()
}




final class MonoView: TetrisView {

    private var canvas: TinyCanvas
    private let lcd: SSD1315
    private let unitSize = 5
    private let screenX0 = 1, screenY0 = 4

    private var nextBlock = Block()
    private var previousBlock: Block?

    init(lcd: SSD1315) {
        self.lcd = lcd
        canvas = TinyCanvas(width: lcd.width, height: lcd.height, color: Color.black, colorMode: .MONO)
    }


    func draw(_ x: Int, _ y: Int, color: UInt32) {
        if x < 0 || x >= 10 || y < 0 || y >= 20 {
            return
        }
        let x = 9 - x

        canvas.fillRect( x: screenX0 + y * unitSize + y,
                        y: screenY0 + x * unitSize + x,
                        width: unitSize,
                        height: unitSize,
                        color: color)
    }

    func displayInit() {
        canvas.clear(color: Color.black)

        canvas.drawLine(x1: screenX0 - 1, y1: screenY0 - 1, x2: screenX0 + 119, y2: screenY0 - 1)
        canvas.drawLine(x1: screenX0 - 1, y1: screenY0 - 1, x2: screenX0 - 1, y2: screenY0 + 59)
        canvas.drawLine(x1: screenX0 + 119, y1: screenY0 - 1, x2: screenX0 + 119, y2: screenY0 + 59)
        canvas.drawLine(x1: screenX0 - 1, y1: screenY0 + 59, x2: screenX0 + 119, y2: screenY0 + 59)
        display()
    }

    func updateData(_ data: GameData) {

    }

    func updateNextImage(_ block: Block) {
        nextBlock = block
        let image = block.getImage()

        canvas.fillRect(x: 0, y: 0, width: 8, height: 8, color: Color.black)
        for y in 0..<image.count {
            for x in 0..<image[0].count {
                if image[y][x] {
                    let dx = image[0].count - 1 - x
                    canvas.drawRect(x: y * 2,
                                    y: dx * 2,
                                    width: 2,
                                    height: 2,
                                    color: Color.white)
                }
            }
        }
        display()
    }


    func clearBlock(_ block: Block) {
        let x = block.x
        let y = block.y
        let image = block.getImage()


        for j in 0..<image.count {
            for i in 0..<image[0].count {
                if image[j][i] {
                    draw(x + i, y + j, color: Color.black)
                }
            }
        }
    }

    func updateBlock(_ block: Block) {

        if let pBlock = previousBlock {
            clearBlock(pBlock)
        }

        let x = block.x
        let y = block.y
        let image = block.getImage()


        for j in 0..<image.count {
            for i in 0..<image[0].count {
                if image[j][i] {
                    draw(x + i, y + j, color: Color.white)
                }
            }
        }

        previousBlock = block
        display()
    }

    func updatePlayground(_ playground: Playground) {
        canvas.fillRect( x: screenX0,
                        y: screenY0,
                        width: 20 * unitSize + 20 - 1,
                        height: 10 * unitSize + 10 - 1,
                        color: Color.black)

        for y in 0..<20 {
            for x in 0..<10 {
                if playground.screen[y][x] > 0 {
                    draw(x, y, color: Color.white)
                }
            }
        }

        updateNextImage(nextBlock)

        previousBlock = nil

        display()
    }

    func gameOver() {
    }

    func display() {
        lcd.writeScreen(canvas.data)
    }

}




final class ColorView: TetrisView {
    private let blockColor: [UInt32] = [
        0x000000,
        0x1B75BB, //J
        0xF6921E, //L
        0xEC1C24, //Z
        0x8BC53F, //S
        0x652D90, //T
        0x00ADEE, //I
        0xFFF100  //O
    ]

    let blockImage: [[UInt32]] = [
        [0xbdd7eb, 0xc4dbed, 0xb2d0e8, 0xa4c8e4, 0xa4c8e4, 0xa4c8e4, 0xa4c8e4, 0xa4c8e4, 0xa4c8e4, 0xa4c8e4, 0xa4c8e4, 0xa4c8e4, 0x92bdde, 0x5f9ecf, 0x1a70b3, 0x95bfe0, 0xb9d5ea, 0xb5d2e9, 0x9ec5e2, 0x9ec5e2, 0x9ec5e2, 0x9ec5e2, 0x9ec5e2, 0x9ec5e2, 0x9ec5e2, 0x9ec5e2, 0x9ec5e2, 0x7aaed7, 0x1b74ba, 0x114a76, 0x63a0d0, 0x80b2d9, 0x82b3da, 0x63a1d1, 0x63a1d1, 0x63a1d1, 0x63a1d1, 0x63a1d1, 0x63a1d1, 0x63a1d1, 0x63a1d1, 0x63a1d1, 0x2c7fc0, 0x124c7a, 0xb2f4b, 0x4790c8, 0x5296cb, 0x418cc6, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x165f97, 0xc3656, 0xb2f4b, 0x4790c8, 0x5296cb, 0x418cc6, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x165f97, 0xc3656, 0xb2f4b, 0x4790c8, 0x5296cb, 0x418cc6, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x165f97, 0xc3656, 0xb2f4b, 0x4790c8, 0x5296cb, 0x418cc6, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x165f97, 0xc3656, 0xb2f4b, 0x4790c8, 0x5296cb, 0x418cc6, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x165f97, 0xc3656, 0xb2f4b, 0x4790c8, 0x5296cb, 0x418cc6, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x165f97, 0xc3656, 0xb2f4b, 0x4790c8, 0x5296cb, 0x418cc6, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x165f97, 0xc3656, 0xb2f4b, 0x4790c8, 0x5296cb, 0x418cc6, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x165f97, 0xc3656, 0xb2f4b, 0x4790c8, 0x5296cb, 0x418cc6, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x1b75bb, 0x165f97, 0xc3656, 0xb2f4b, 0x297ebf, 0x1b75ba, 0x17629c, 0x135080, 0x135080, 0x135080, 0x135080, 0x135080, 0x135080, 0x135080, 0x135080, 0x135080, 0xe3e64, 0xb2f4b, 0xb2f4b, 0x165f99, 0x10436c, 0xb2f4b, 0xb2f4b, 0xb2f4b, 0xb2f4b, 0xb2f4b, 0xb2f4b, 0xb2f4b, 0xb2f4b, 0xb2f4b, 0xb2f4b, 0xb2f4b, 0xb2f4b, 0xb2f4b, 0xe3c60, 0xb2f4b, 0xb2f4b, 0xb2f4b, 0xb2f4b, 0xb2f4b, 0xb2f4b, 0xb2f4b, 0xb2f4b, 0xb2f4b, 0xb2f4b, 0xb2f4b, 0xb2f4b, 0xb2f4b, 0xb2f4b],
        [0xfcdfbe, 0xfde3c5, 0xfcdab3, 0xfbd3a5, 0xfbd3a5, 0xfbd3a5, 0xfbd3a5, 0xfbd3a5, 0xfbd3a5, 0xfbd3a5, 0xfbd3a5, 0xfbd3a5, 0xfbcb93, 0xf9b261, 0xeb8c1d, 0xfbcd97, 0xfcdeba, 0xfcdcb6, 0xfbd1a0, 0xfbd1a0, 0xfbd1a0, 0xfbd1a0, 0xfbd1a0, 0xfbd1a0, 0xfbd1a0, 0xfbd1a0, 0xfbd1a0, 0xfabf7c, 0xf4911e, 0x9b5c13, 0xf9b465, 0xfac282, 0xfac383, 0xf9b565, 0xf9b565, 0xf9b565, 0xf9b565, 0xf9b565, 0xf9b565, 0xf9b565, 0xf9b565, 0xf9b565, 0xf79a2f, 0xa05f14, 0x623a0c, 0xf8a749, 0xf8ac54, 0xf8a444, 0xf6921e, 0xf6921e, 0xf6921e, 0xf6921e, 0xf6921e, 0xf6921e, 0xf6921e, 0xf6921e, 0xf6921e, 0xc77618, 0x71430e, 0x623a0c, 0xf8a749, 0xf8ac54, 0xf8a444, 0xf6921e, 0xf6921e, 0xf6921e, 0xf6921e, 0xf6921e, 0xf6921e, 0xf6921e, 0xf6921e, 0xf6921e, 0xc77618, 0x71430e, 0x623a0c, 0xf8a749, 0xf8ac54, 0xf8a444, 0xf6921e, 0xf6921e, 0xf6921e, 0xf6921e, 0xf6921e, 0xf6921e, 0xf6921e, 0xf6921e, 0xf6921e, 0xc77618, 0x71430e, 0x623a0c, 0xf8a749, 0xf8ac54, 0xf8a444, 0xf6921e, 0xf6921e, 0xf6921e, 0xf6921e, 0xf6921e, 0xf6921e, 0xf6921e, 0xf6921e, 0xf6921e, 0xc77618, 0x71430e, 0x623a0c, 0xf8a749, 0xf8ac54, 0xf8a444, 0xf6921e, 0xf6921e, 0xf6921e, 0xf6921e, 0xf6921e, 0xf6921e, 0xf6921e, 0xf6921e, 0xf6921e, 0xc77618, 0x71430e, 0x623a0c, 0xf8a749, 0xf8ac54, 0xf8a444, 0xf6921e, 0xf6921e, 0xf6921e, 0xf6921e, 0xf6921e, 0xf6921e, 0xf6921e, 0xf6921e, 0xf6921e, 0xc77618, 0x71430e, 0x623a0c, 0xf8a749, 0xf8ac54, 0xf8a444, 0xf6921e, 0xf6921e, 0xf6921e, 0xf6921e, 0xf6921e, 0xf6921e, 0xf6921e, 0xf6921e, 0xf6921e, 0xc77618, 0x71430e, 0x623a0c, 0xf8a749, 0xf8ac54, 0xf8a444, 0xf6921e, 0xf6921e, 0xf6921e, 0xf6921e, 0xf6921e, 0xf6921e, 0xf6921e, 0xf6921e, 0xf6921e, 0xc77618, 0x71430e, 0x623a0c, 0xf8a749, 0xf8ac54, 0xf8a444, 0xf6921e, 0xf6921e, 0xf6921e, 0xf6921e, 0xf6921e, 0xf6921e, 0xf6921e, 0xf6921e, 0xf6921e, 0xc77618, 0x71430e, 0x623a0c, 0xf7992c, 0xf5911e, 0xcd7a19, 0xa96415, 0xa96415, 0xa96415, 0xa96415, 0xa96415, 0xa96415, 0xa96415, 0xa96415, 0xa96415, 0x834e10, 0x623a0c, 0x623a0c, 0xc97718, 0x8e5411, 0x623a0c, 0x623a0c, 0x623a0c, 0x623a0c, 0x623a0c, 0x623a0c, 0x623a0c, 0x623a0c, 0x623a0c, 0x623a0c, 0x623a0c, 0x623a0c, 0x623a0c, 0x7e4b0f, 0x623a0c, 0x623a0c, 0x623a0c, 0x623a0c, 0x623a0c, 0x623a0c, 0x623a0c, 0x623a0c, 0x623a0c, 0x623a0c, 0x623a0c, 0x623a0c, 0x623a0c, 0x623a0c],
        [0xf9bdbf, 0xfac4c6, 0xf9b2b5, 0xf7a4a7, 0xf7a4a7, 0xf7a4a7, 0xf7a4a7, 0xf7a4a7, 0xf7a4a7, 0xf7a4a7, 0xf7a4a7, 0xf7a4a7, 0xf69296, 0xf26065, 0xe21b22, 0xf6969a, 0xf9babc, 0xf9b5b8, 0xf79fa2, 0xf79fa2, 0xf79fa2, 0xf79fa2, 0xf79fa2, 0xf79fa2, 0xf79fa2, 0xf79fa2, 0xf79fa2, 0xf47a7f, 0xea1c24, 0x951217, 0xf26369, 0xf48185, 0xf58287, 0xf2646a, 0xf2646a, 0xf2646a, 0xf2646a, 0xf2646a, 0xf2646a, 0xf2646a, 0xf2646a, 0xf2646a, 0xed2d34, 0x9a1217, 0x5e0b0e, 0xf0484e, 0xf15258, 0xef4249, 0xec1c24, 0xec1c24, 0xec1c24, 0xec1c24, 0xec1c24, 0xec1c24, 0xec1c24, 0xec1c24, 0xec1c24, 0xbf171d, 0x6c0d11, 0x5e0b0e, 0xf0484e, 0xf15258, 0xef4249, 0xec1c24, 0xec1c24, 0xec1c24, 0xec1c24, 0xec1c24, 0xec1c24, 0xec1c24, 0xec1c24, 0xec1c24, 0xbf171d, 0x6c0d11, 0x5e0b0e, 0xf0484e, 0xf15258, 0xef4249, 0xec1c24, 0xec1c24, 0xec1c24, 0xec1c24, 0xec1c24, 0xec1c24, 0xec1c24, 0xec1c24, 0xec1c24, 0xbf171d, 0x6c0d11, 0x5e0b0e, 0xf0484e, 0xf15258, 0xef4249, 0xec1c24, 0xec1c24, 0xec1c24, 0xec1c24, 0xec1c24, 0xec1c24, 0xec1c24, 0xec1c24, 0xec1c24, 0xbf171d, 0x6c0d11, 0x5e0b0e, 0xf0484e, 0xf15258, 0xef4249, 0xec1c24, 0xec1c24, 0xec1c24, 0xec1c24, 0xec1c24, 0xec1c24, 0xec1c24, 0xec1c24, 0xec1c24, 0xbf171d, 0x6c0d11, 0x5e0b0e, 0xf0484e, 0xf15258, 0xef4249, 0xec1c24, 0xec1c24, 0xec1c24, 0xec1c24, 0xec1c24, 0xec1c24, 0xec1c24, 0xec1c24, 0xec1c24, 0xbf171d, 0x6c0d11, 0x5e0b0e, 0xf0484e, 0xf15258, 0xef4249, 0xec1c24, 0xec1c24, 0xec1c24, 0xec1c24, 0xec1c24, 0xec1c24, 0xec1c24, 0xec1c24, 0xec1c24, 0xbf171d, 0x6c0d11, 0x5e0b0e, 0xf0484e, 0xf15258, 0xef4249, 0xec1c24, 0xec1c24, 0xec1c24, 0xec1c24, 0xec1c24, 0xec1c24, 0xec1c24, 0xec1c24, 0xec1c24, 0xbf171d, 0x6c0d11, 0x5e0b0e, 0xf0484e, 0xf15258, 0xef4249, 0xec1c24, 0xec1c24, 0xec1c24, 0xec1c24, 0xec1c24, 0xec1c24, 0xec1c24, 0xec1c24, 0xec1c24, 0xbf171d, 0x6c0d11, 0x5e0b0e, 0xed2a32, 0xeb1c24, 0xc5171e, 0xa21319, 0xa21319, 0xa21319, 0xa21319, 0xa21319, 0xa21319, 0xa21319, 0xa21319, 0xa21319, 0x7e0f13, 0x5e0b0e, 0x5e0b0e, 0xc1171d, 0x881015, 0x5e0b0e, 0x5e0b0e, 0x5e0b0e, 0x5e0b0e, 0x5e0b0e, 0x5e0b0e, 0x5e0b0e, 0x5e0b0e, 0x5e0b0e, 0x5e0b0e, 0x5e0b0e, 0x5e0b0e, 0x5e0b0e, 0x790e12, 0x5e0b0e, 0x5e0b0e, 0x5e0b0e, 0x5e0b0e, 0x5e0b0e, 0x5e0b0e, 0x5e0b0e, 0x5e0b0e, 0x5e0b0e, 0x5e0b0e, 0x5e0b0e, 0x5e0b0e, 0x5e0b0e, 0x5e0b0e],
        [0xddeec7, 0xe1f0cd, 0xd8ebbe, 0xd1e8b2, 0xd1e8b2, 0xd1e8b2, 0xd1e8b2, 0xd1e8b2, 0xd1e8b2, 0xd1e8b2, 0xd1e8b2, 0xd1e8b2, 0xc8e3a3, 0xaed678, 0x85bd3c, 0xc9e4a6, 0xdcedc4, 0xd9ecc1, 0xcee6ae, 0xcee6ae, 0xcee6ae, 0xcee6ae, 0xcee6ae, 0xcee6ae, 0xcee6ae, 0xcee6ae, 0xcee6ae, 0xbbdd8f, 0x8ac33f, 0x587c28, 0xafd77b, 0xbedf94, 0xbfdf96, 0xb0d77c, 0xb0d77c, 0xb0d77c, 0xb0d77c, 0xb0d77c, 0xb0d77c, 0xb0d77c, 0xb0d77c, 0xb0d77c, 0x94c94d, 0x5a8029, 0x384f19, 0xa1d064, 0xa7d36d, 0x9fcf5f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x709f33, 0x405a1d, 0x384f19, 0xa1d064, 0xa7d36d, 0x9fcf5f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x709f33, 0x405a1d, 0x384f19, 0xa1d064, 0xa7d36d, 0x9fcf5f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x709f33, 0x405a1d, 0x384f19, 0xa1d064, 0xa7d36d, 0x9fcf5f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x709f33, 0x405a1d, 0x384f19, 0xa1d064, 0xa7d36d, 0x9fcf5f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x709f33, 0x405a1d, 0x384f19, 0xa1d064, 0xa7d36d, 0x9fcf5f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x709f33, 0x405a1d, 0x384f19, 0xa1d064, 0xa7d36d, 0x9fcf5f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x709f33, 0x405a1d, 0x384f19, 0xa1d064, 0xa7d36d, 0x9fcf5f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x709f33, 0x405a1d, 0x384f19, 0xa1d064, 0xa7d36d, 0x9fcf5f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x8bc53f, 0x709f33, 0x405a1d, 0x384f19, 0x92c94b, 0x8ac43f, 0x74a535, 0x5f872b, 0x5f872b, 0x5f872b, 0x5f872b, 0x5f872b, 0x5f872b, 0x5f872b, 0x5f872b, 0x5f872b, 0x4a6922, 0x384f19, 0x384f19, 0x71a133, 0x507224, 0x384f19, 0x384f19, 0x384f19, 0x384f19, 0x384f19, 0x384f19, 0x384f19, 0x384f19, 0x384f19, 0x384f19, 0x384f19, 0x384f19, 0x384f19, 0x476520, 0x384f19, 0x384f19, 0x384f19, 0x384f19, 0x384f19, 0x384f19, 0x384f19, 0x384f19, 0x384f19, 0x384f19, 0x384f19, 0x384f19, 0x384f19, 0x384f19],
        [0xd2c2df, 0xd7c9e2, 0xcbb8da, 0xc1abd3, 0xc1abd3, 0xc1abd3, 0xc1abd3, 0xc1abd3, 0xc1abd3, 0xc1abd3, 0xc1abd3, 0xc1abd3, 0xb59bca, 0x936cb1, 0x612b8a, 0xb89ecc, 0xd0bfdd, 0xcdbbdb, 0xbea6d0, 0xbea6d0, 0xbea6d0, 0xbea6d0, 0xbea6d0, 0xbea6d0, 0xbea6d0, 0xbea6d0, 0xbea6d0, 0xa584be, 0x642d8f, 0x401c5b, 0x956fb3, 0xa98ac1, 0xaa8cc2, 0x9670b3, 0x9670b3, 0x9670b3, 0x9670b3, 0x9670b3, 0x9670b3, 0x9670b3, 0x9670b3, 0x9670b3, 0x703d98, 0x421d5e, 0x28123a, 0x8355a5, 0x8a5fab, 0x7f50a3, 0x652d90, 0x652d90, 0x652d90, 0x652d90, 0x652d90, 0x652d90, 0x652d90, 0x652d90, 0x652d90, 0x522474, 0x2e1542, 0x28123a, 0x8355a5, 0x8a5fab, 0x7f50a3, 0x652d90, 0x652d90, 0x652d90, 0x652d90, 0x652d90, 0x652d90, 0x652d90, 0x652d90, 0x652d90, 0x522474, 0x2e1542, 0x28123a, 0x8355a5, 0x8a5fab, 0x7f50a3, 0x652d90, 0x652d90, 0x652d90, 0x652d90, 0x652d90, 0x652d90, 0x652d90, 0x652d90, 0x652d90, 0x522474, 0x2e1542, 0x28123a, 0x8355a5, 0x8a5fab, 0x7f50a3, 0x652d90, 0x652d90, 0x652d90, 0x652d90, 0x652d90, 0x652d90, 0x652d90, 0x652d90, 0x652d90, 0x522474, 0x2e1542, 0x28123a, 0x8355a5, 0x8a5fab, 0x7f50a3, 0x652d90, 0x652d90, 0x652d90, 0x652d90, 0x652d90, 0x652d90, 0x652d90, 0x652d90, 0x652d90, 0x522474, 0x2e1542, 0x28123a, 0x8355a5, 0x8a5fab, 0x7f50a3, 0x652d90, 0x652d90, 0x652d90, 0x652d90, 0x652d90, 0x652d90, 0x652d90, 0x652d90, 0x652d90, 0x522474, 0x2e1542, 0x28123a, 0x8355a5, 0x8a5fab, 0x7f50a3, 0x652d90, 0x652d90, 0x652d90, 0x652d90, 0x652d90, 0x652d90, 0x652d90, 0x652d90, 0x652d90, 0x522474, 0x2e1542, 0x28123a, 0x8355a5, 0x8a5fab, 0x7f50a3, 0x652d90, 0x652d90, 0x652d90, 0x652d90, 0x652d90, 0x652d90, 0x652d90, 0x652d90, 0x652d90, 0x522474, 0x2e1542, 0x28123a, 0x8355a5, 0x8a5fab, 0x7f50a3, 0x652d90, 0x652d90, 0x652d90, 0x652d90, 0x652d90, 0x652d90, 0x652d90, 0x652d90, 0x652d90, 0x522474, 0x2e1542, 0x28123a, 0x6f3a97, 0x652d8f, 0x542678, 0x451f63, 0x451f63, 0x451f63, 0x451f63, 0x451f63, 0x451f63, 0x451f63, 0x451f63, 0x451f63, 0x36184d, 0x28123a, 0x28123a, 0x522575, 0x3a1a53, 0x28123a, 0x28123a, 0x28123a, 0x28123a, 0x28123a, 0x28123a, 0x28123a, 0x28123a, 0x28123a, 0x28123a, 0x28123a, 0x28123a, 0x28123a, 0x34174a, 0x28123a, 0x28123a, 0x28123a, 0x28123a, 0x28123a, 0x28123a, 0x28123a, 0x28123a, 0x28123a, 0x28123a, 0x28123a, 0x28123a, 0x28123a, 0x28123a],
        [0xb5e7fa, 0xbdeafb, 0xa9e3f9, 0x99def8, 0x99def8, 0x99def8, 0x99def8, 0x99def8, 0x99def8, 0x99def8, 0x99def8, 0x99def8, 0x85d8f7, 0x4cc5f3, 0xa6e4, 0x89d9f7, 0xb1e6fa, 0xace4f9, 0x93dcf8, 0x93dcf8, 0x93dcf8, 0x93dcf8, 0x93dcf8, 0x93dcf8, 0x93dcf8, 0x93dcf8, 0x93dcf8, 0x6acff5, 0xacec, 0x6d96, 0x50c7f3, 0x71d1f6, 0x73d2f6, 0x51c7f3, 0x51c7f3, 0x51c7f3, 0x51c7f3, 0x51c7f3, 0x51c7f3, 0x51c7f3, 0x51c7f3, 0x51c7f3, 0x13b3ef, 0x719b, 0x455f, 0x31bdf1, 0x3dc1f2, 0x2bbbf1, 0xadee, 0xadee, 0xadee, 0xadee, 0xadee, 0xadee, 0xadee, 0xadee, 0xadee, 0x8cc0, 0x4f6d, 0x455f, 0x31bdf1, 0x3dc1f2, 0x2bbbf1, 0xadee, 0xadee, 0xadee, 0xadee, 0xadee, 0xadee, 0xadee, 0xadee, 0xadee, 0x8cc0, 0x4f6d, 0x455f, 0x31bdf1, 0x3dc1f2, 0x2bbbf1, 0xadee, 0xadee, 0xadee, 0xadee, 0xadee, 0xadee, 0xadee, 0xadee, 0xadee, 0x8cc0, 0x4f6d, 0x455f, 0x31bdf1, 0x3dc1f2, 0x2bbbf1, 0xadee, 0xadee, 0xadee, 0xadee, 0xadee, 0xadee, 0xadee, 0xadee, 0xadee, 0x8cc0, 0x4f6d, 0x455f, 0x31bdf1, 0x3dc1f2, 0x2bbbf1, 0xadee, 0xadee, 0xadee, 0xadee, 0xadee, 0xadee, 0xadee, 0xadee, 0xadee, 0x8cc0, 0x4f6d, 0x455f, 0x31bdf1, 0x3dc1f2, 0x2bbbf1, 0xadee, 0xadee, 0xadee, 0xadee, 0xadee, 0xadee, 0xadee, 0xadee, 0xadee, 0x8cc0, 0x4f6d, 0x455f, 0x31bdf1, 0x3dc1f2, 0x2bbbf1, 0xadee, 0xadee, 0xadee, 0xadee, 0xadee, 0xadee, 0xadee, 0xadee, 0xadee, 0x8cc0, 0x4f6d, 0x455f, 0x31bdf1, 0x3dc1f2, 0x2bbbf1, 0xadee, 0xadee, 0xadee, 0xadee, 0xadee, 0xadee, 0xadee, 0xadee, 0xadee, 0x8cc0, 0x4f6d, 0x455f, 0x31bdf1, 0x3dc1f2, 0x2bbbf1, 0xadee, 0xadee, 0xadee, 0xadee, 0xadee, 0xadee, 0xadee, 0xadee, 0xadee, 0x8cc0, 0x4f6d, 0x455f, 0x10b2ef, 0xaced, 0x91c7, 0x77a3, 0x77a3, 0x77a3, 0x77a3, 0x77a3, 0x77a3, 0x77a3, 0x77a3, 0x77a3, 0x5c7f, 0x455f, 0x455f, 0x8dc2, 0x6489, 0x455f, 0x455f, 0x455f, 0x455f, 0x455f, 0x455f, 0x455f, 0x455f, 0x455f, 0x455f, 0x455f, 0x455f, 0x455f, 0x597a, 0x455f, 0x455f, 0x455f, 0x455f, 0x455f, 0x455f, 0x455f, 0x455f, 0x455f, 0x455f, 0x455f, 0x455f, 0x455f, 0x455f],
        [0xfffbb5, 0xfffbbd, 0xfffaa9, 0xfff999, 0xfff999, 0xfff999, 0xfff999, 0xfff999, 0xfff999, 0xfff999, 0xfff999, 0xfff999, 0xfff885, 0xfff54c, 0xf4e700, 0xfff989, 0xfffbb1, 0xfffaac, 0xfff993, 0xfff993, 0xfff993, 0xfff993, 0xfff993, 0xfff993, 0xfff993, 0xfff993, 0xfff993, 0xfff76a, 0xfdef00, 0xa19800, 0xfff550, 0xfff771, 0xfff773, 0xfff551, 0xfff551, 0xfff551, 0xfff551, 0xfff551, 0xfff551, 0xfff551, 0xfff551, 0xfff551, 0xfff213, 0xa69d00, 0x666000, 0xfff431, 0xfff43d, 0xfff32b, 0xfff100, 0xfff100, 0xfff100, 0xfff100, 0xfff100, 0xfff100, 0xfff100, 0xfff100, 0xfff100, 0xcec300, 0x756f00, 0x666000, 0xfff431, 0xfff43d, 0xfff32b, 0xfff100, 0xfff100, 0xfff100, 0xfff100, 0xfff100, 0xfff100, 0xfff100, 0xfff100, 0xfff100, 0xcec300, 0x756f00, 0x666000, 0xfff431, 0xfff43d, 0xfff32b, 0xfff100, 0xfff100, 0xfff100, 0xfff100, 0xfff100, 0xfff100, 0xfff100, 0xfff100, 0xfff100, 0xcec300, 0x756f00, 0x666000, 0xfff431, 0xfff43d, 0xfff32b, 0xfff100, 0xfff100, 0xfff100, 0xfff100, 0xfff100, 0xfff100, 0xfff100, 0xfff100, 0xfff100, 0xcec300, 0x756f00, 0x666000, 0xfff431, 0xfff43d, 0xfff32b, 0xfff100, 0xfff100, 0xfff100, 0xfff100, 0xfff100, 0xfff100, 0xfff100, 0xfff100, 0xfff100, 0xcec300, 0x756f00, 0x666000, 0xfff431, 0xfff43d, 0xfff32b, 0xfff100, 0xfff100, 0xfff100, 0xfff100, 0xfff100, 0xfff100, 0xfff100, 0xfff100, 0xfff100, 0xcec300, 0x756f00, 0x666000, 0xfff431, 0xfff43d, 0xfff32b, 0xfff100, 0xfff100, 0xfff100, 0xfff100, 0xfff100, 0xfff100, 0xfff100, 0xfff100, 0xfff100, 0xcec300, 0x756f00, 0x666000, 0xfff431, 0xfff43d, 0xfff32b, 0xfff100, 0xfff100, 0xfff100, 0xfff100, 0xfff100, 0xfff100, 0xfff100, 0xfff100, 0xfff100, 0xcec300, 0x756f00, 0x666000, 0xfff431, 0xfff43d, 0xfff32b, 0xfff100, 0xfff100, 0xfff100, 0xfff100, 0xfff100, 0xfff100, 0xfff100, 0xfff100, 0xfff100, 0xcec300, 0x756f00, 0x666000, 0xfff210, 0xfef000, 0xd5c900, 0xafa500, 0xafa500, 0xafa500, 0xafa500, 0xafa500, 0xafa500, 0xafa500, 0xafa500, 0xafa500, 0x888100, 0x666000, 0x666000, 0xd0c500, 0x938b00, 0x666000, 0x666000, 0x666000, 0x666000, 0x666000, 0x666000, 0x666000, 0x666000, 0x666000, 0x666000, 0x666000, 0x666000, 0x666000, 0x837c00, 0x666000, 0x666000, 0x666000, 0x666000, 0x666000, 0x666000, 0x666000, 0x666000, 0x666000, 0x666000, 0x666000, 0x666000, 0x666000, 0x666000],
    ]
    private var canvas: TinyCanvas
    private let lcd: ILI9341
    private let unitSize = 15
    private let screenX0 = 10, screenY0 = 10

    private var previousBlock: Block?
    private var nextBlock = Block()

    init(lcd: ILI9341) {
        self.lcd = lcd
        canvas = TinyCanvas(width: lcd.width, height: lcd.height, color: Color.black, colorMode: .RGB565)
    }

    func draw(_ x: Int, _ y: Int, blockName: Int) {
        if x < 0 || x >= 10 || y < 0 || y >= 20 {
            return
        }

        if blockName > 0 {
            canvas.drawBitmap( x: screenX0 + x * unitSize,
                               y: screenY0 + y * unitSize,
                               width: unitSize,
                               height: unitSize,
                               data: blockImage[blockName - 1])
        }

/*
        if blockName > 0 {
            canvas.fillRect( x: screenX0 + x * unitSize,
                            y: screenY0 + y * unitSize,
                            width: unitSize,
                            height: unitSize,
                            color: blockColor[blockName])
            canvas.drawRect( x: screenX0 + x * unitSize,
                            y: screenY0 + y * unitSize,
                            width: unitSize,
                            height: unitSize,
                            color: Color.black)
        }
*/
        if blockName == 0 {
            canvas.fillRect( x: screenX0 + x * unitSize,
                            y: screenY0 + y * unitSize,
                            width: unitSize,
                            height: unitSize,
                            color: Color.black)
        }
    }

    func displayInit() {
        canvas.clear(color: Color.black)

        canvas.fillRect(x: 0,
                        y: 0,
                        width: lcd.width,
                        height: lcd.height,
                        color: 0xD2D2D2)
        canvas.fillRect(x: screenX0,
                        y: screenY0,
                        width: unitSize * 10,
                        height: unitSize * 10,
                        color: Color.black)

        canvas.drawString(x: 165, y: canvas.font.advanceY * 2, "Next:", color: Color.orange)

        canvas.drawString(x: 165, y: canvas.font.advanceY * 8, "Score:", color: Color.orange)
        canvas.drawString(x: 165, y: canvas.font.advanceY * 9 + 5, "0", color: Color.orange)

        canvas.drawString(x: 165, y: canvas.font.advanceY * 11, "Level:", color: Color.orange)
        canvas.drawString(x: 165, y: canvas.font.advanceY * 12 + 5, "1", color: Color.orange)

        canvas.drawString(x: 165, y: canvas.font.advanceY * 14, "Lines:", color: Color.orange)
        canvas.drawString(x: 165, y: canvas.font.advanceY * 15 + 5, "0", color: Color.orange)
    }

    func updateData(_ data: GameData) {

        canvas.fillRect(x: 165, y: canvas.font.advanceY * 8, width: 75, height: canvas.font.advanceY * 9, color: 0xD2D2D2)

        canvas.drawString(x: 165, y: canvas.font.advanceY * 8, "Score:", color: Color.orange)
        canvas.drawString(x: 165, y: canvas.font.advanceY * 9 + 5, String(data.score), color: Color.orange)

        canvas.drawString(x: 165, y: canvas.font.advanceY * 11, "Level:", color: Color.orange)
        canvas.drawString(x: 165, y: canvas.font.advanceY * 12 + 5, String(data.level), color: Color.orange)

        canvas.drawString(x: 165, y: canvas.font.advanceY * 14, "Lines:", color: Color.orange)
        canvas.drawString(x: 165, y: canvas.font.advanceY * 15 + 5, String(data.lines), color: Color.orange)

        display()
    }


    func gameOver() {
        canvas.setFontSize(3)
        canvas.drawString(x: 0, y: canvas.font.advanceY * 3 * 3, "Game Over!", color: Color.red)
        display()
    }

    func updateNextImage(_ block: Block) {
        nextBlock = block


        canvas.fillRect(x: 165, y: canvas.font.advanceY * 3 + 5, width: unitSize * 4, height: unitSize * 4, color: 0xD2D2D2)
        let image = block.getImage()
        for j in 0..<image.count {
            for i in 0..<image[0].count {
                if image[j][i] {
                    /*
                    canvas.fillRect( x: 165 + i * unitSize,
                                    y: canvas.font.advanceY * 3 + 5 + j * unitSize,
                                    width: unitSize,
                                    height: unitSize,
                                    color: blockColor[block.name.rawValue])

                    canvas.drawRect( x: 165 + i * unitSize,
                                    y: canvas.font.advanceY * 3 + 5 + j * unitSize,
                                    width: unitSize,
                                    height: unitSize,
                                    color: Color.black)
                    */
                    canvas.drawBitmap( x: 165 + i * unitSize,
                                    y: canvas.font.advanceY * 3 + 5 + j * unitSize,
                                    width: unitSize,
                                    height: unitSize,
                                    data: blockImage[block.name.rawValue - 1])
                
                }
            }
        }

        display()
    }

    func clearBlock(_ block: Block) {
        let x = block.x
        let y = block.y
        let image = block.getImage()


        for j in 0..<image.count {
            for i in 0..<image[0].count {
                if image[j][i] {
                    draw(x + i, y + j, blockName: 0)
                }
            }
        }
    }

    func updateBlock(_ block: Block) {
        if let pBlock = previousBlock {
            clearBlock(pBlock)
        }

        let x = block.x
        let y = block.y
        let image = block.getImage()


        for j in 0..<image.count {
            for i in 0..<image[0].count {
                if image[j][i] {
                    draw(x + i, y + j, blockName: block.name.rawValue)
                }
            }
        }

        previousBlock = block
        display()
    }

    func updatePlayground(_ playground: Playground) {
        canvas.fillRect( x: screenX0,
                        y: screenY0,
                        width: 10 * unitSize,
                        height: 20 * unitSize,
                        color: Color.black)

        for y in 0..<20 {
            for x in 0..<10 {
                if playground.screen[y][x] > 0 {
                    draw(x, y, blockName: playground.screen[y][x])
                }
            }
        }

        previousBlock = nil
        display()
    }

    func display() {
        lcd.writeBitmap(x: 0, y: 0, width: lcd.width, height: lcd.height, data: canvas.data)
    }

}
