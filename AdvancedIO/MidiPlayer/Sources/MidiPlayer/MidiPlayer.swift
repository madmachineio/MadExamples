import SwiftIO

final class MidiPlayer {
	var lists = [MidiEventList]()
	var listAvaiable = 0
    var timer = Timer()

	init(_ lists: [MidiEvent]...) {
		lists.forEach {list in
			self.lists.append(MidiEventList(list))
		}
	}

	func setChannls(_ pwms: PWMOut...) {
		listAvaiable = min(lists.count, pwms.count)
		for i in 0..<listAvaiable {
			lists[i].setPwm(pwms[i])
		}
	}

	func playNotes(_ duration: Int) {
		for i in 0..<listAvaiable {
			lists[i].playNote(duration)
		}
	}

    func playBackground() {
        timer.setInterrupt(ms: 1) {
            self.playNotes(1)
        }
    }
}
