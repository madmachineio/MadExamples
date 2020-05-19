import SwiftIO

final class Keypad {
    enum KeyType {
        case none, left, right, down, rotate, select
    }
    var keyState: KeyType = .none

    private let timer = Timer()
    private var leftCounter, rightCounter, downCounter, rotateCounter, selectCounter: Int
    private let left, right, down, rotate, select: DigitalIn
    private func timerHandler() {
        if left.read() {
            leftCounter += 1
        } else {
            leftCounter = 1
        }

        if right.read() {
            rightCounter += 1
        } else {
            rightCounter = 1
        }

        if down.read() {
            downCounter += 1
        } else {
            downCounter = 1
        }

        if rotate.read() {
            rotateCounter += 1
        } else {
            rotateCounter = 1
        }

        if select.read() {
            selectCounter += 1
        } else {
            selectCounter = 1
        }

        if leftCounter == 3 || (leftCounter >= 30 && leftCounter % 3 == 0) {
            keyState = .left
            return
        }
        if rightCounter == 3 || (rightCounter >= 30 && rightCounter % 3 == 0) {
            keyState = .right
            return
        }
        if downCounter % 3 == 0 {
            keyState = .down
            return
        }
        if rotateCounter == 3 {
            keyState = .rotate
            return
        }
        if selectCounter == 3 {
            keyState = .select
            return
        }

        keyState = .none
    }

    init(left: IdName, right: IdName, down: IdName, rotate: IdName, select: IdName) {
        self.left = DigitalIn(left)
        self.right = DigitalIn(right)
        self.down = DigitalIn(down)
        self.rotate = DigitalIn(rotate)
        self.select = DigitalIn(select)
        leftCounter = 1
        rightCounter = 1
        downCounter = 1
        rotateCounter = 1
        selectCounter = 1

        timer.setInterrupt(ms: 10, timerHandler)
    }

    func getKeyState() -> KeyType {
        let result = keyState
        keyState = .none

        return result
    }

}



