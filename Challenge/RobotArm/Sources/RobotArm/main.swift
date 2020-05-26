import SwiftIO


let keys = [
    DigitalIn(Id.D0),
    DigitalIn(Id.D1),
    DigitalIn(Id.D2),
    DigitalIn(Id.D3),
    DigitalIn(Id.D4),
    DigitalIn(Id.D5),
    DigitalIn(Id.D6),
    DigitalIn(Id.D7)
]

let pwms = [
    PWMOut(Id.PWM2),
    PWMOut(Id.PWM3),
    PWMOut(Id.PWM4),
    PWMOut(Id.PWM5)
]

let knob = AnalogIn(Id.A0)

let timer = Timer()

var step0 = 0, step1 = 0, step2 = 0, step3 = 0, stepValue = 10
var pos0 = 1500, pos1 = 1500, pos2 = 1500, pos3 = 1500

enum KeyValue: Int {
    case forward = 0
    case backward = 1
    case turnLeft = 2
    case turnRight = 3
    case up = 4
    case down = 5
    case grab = 6
    case unGrab = 7
    case none = 8
}

var previousKeyValue = KeyValue.none.rawValue
func getKeyValue() -> KeyValue {
    var value = KeyValue.none.rawValue

    for i in 0..<keys.count {
        if keys[i].read() {
            value = i
            break
        }
    }

    if value == previousKeyValue {
        return KeyValue(rawValue: value)!
    } else {
        previousKeyValue = value
        return KeyValue.none
    }
}

func handlKey(_ action: KeyValue) {
    switch action {
        case .forward:
        step0 = -stepValue
        case .backward:
        step0 = stepValue
        case .turnLeft:
        step1 = -stepValue
        case .turnRight:
        step1 = stepValue
        case .up:
        step2 = -stepValue
        case .down:
        step2 = stepValue
        case .grab:
        step3 = stepValue
        case .unGrab:
        step3 = -stepValue
        case .none:
        step0 = 0
        step1 = 0
        step2 = 0
        step3 = 0
    }
}

func setServoPulse(_ channel: Int, _ pulse: Int) {
    if pulse < 500 || pulse > 2500 || channel < 0 || channel > 3 {
        return
    }

    pwms[channel].set(period: 20_000, pulse: pulse)
}

func timerHandler() {
    if step0 != 0 {
        pos0 += step0
        pos0 = min(2500, pos0)
        pos0 = max(500, pos0)
        setServoPulse(0, pos0)
    }

    if step1 != 0 {
        pos1 += step1
        pos1 = min(2500, pos1)
        pos1 = max(500, pos1)
        setServoPulse(1, pos1)
    }

    if step2 != 0 {
        pos2 += step2
        pos2 = min(2500, pos2)
        pos2 = max(500, pos2)
        setServoPulse(2, pos2)
    }

    if step3 != 0 {
        pos3 += step3
        pos3 = min(2500, pos3)
        pos3 = max(500, pos3)
        setServoPulse(3, pos3)
    }
}
timer.setInterrupt(ms: 20, timerHandler)


for channel in 0..<pwms.count {
    pwms[channel].set(period: 20_000, pulse: 1500)
}

while true {
    stepValue = Int(100 * knob.readPercent())
    let key = getKeyValue()
    handlKey(key)
    sleep(ms: 5)
}