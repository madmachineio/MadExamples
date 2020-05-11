import SwiftIO

struct MidiEvent {
	enum MidiEventStatus: UInt8 {
	    case noteOn = 0x90
	    case noteOff = 0x80
	}

    let deltaTime: Int
    let status: MidiEventStatus
    let key: Note
    let velocity: UInt8
	var period: Int? {
		NotePeriodTable.getPeriod(self.key)
	}

    init(_ deltaTime: Int, _ status: UInt8, _ key: UInt8, _ velocity: UInt8) {
        self.deltaTime = deltaTime
        if let s = MidiEventStatus(rawValue: status & 0x90) {
            self.status = s
        } else {
            self.status = .noteOff
        }
        if let k = Note(rawValue: key) {
            self.key = k
        } else {
            self.key = .NONE
        }
        self.velocity = velocity
    }
}

struct MidiEventList {
	let list: [MidiEvent]
	let noteCount: Int

	var pwm: PWMOut?
	var index: Int = 0
	var timer: Int = 0

	init(_ list: [MidiEvent], _ pwm: PWMOut? = nil) {
		self.list = list
		self.pwm = pwm
		noteCount = list.count
	}

	mutating func setPwm(_ pwm: PWMOut) {
		self.pwm = pwm
	}

	func noteOn(_ noteEvent: MidiEvent) {
		if let pwm = self.pwm {
			if let period = noteEvent.period {
				if noteEvent.velocity > 10 {
					pwm.set(period: period, pulse: period / 2)
				} else {
					pwm.set(period: period, pulse: 0)
				}
			}
		}
	}

	func noteOff() {
		if let pwm = pwm {
			pwm.set(period: 1000, pulse: 0)
		}
	}

	mutating func playNote(_ duration: Int) {
		timer += duration
		if index < noteCount {
			let noteEvent = list[index]
			if timer >= noteEvent.deltaTime {
				switch noteEvent.status {
					case .noteOn:
						noteOn(noteEvent)
					case .noteOff:
						noteOff()
				}
				timer = 0
				index += 1
			}
		} else {
			noteOff()
		}
	}
}

