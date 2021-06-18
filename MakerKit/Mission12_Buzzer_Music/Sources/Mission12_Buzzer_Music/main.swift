import SwiftIO
import SwiftIOBoard
import PWMTone

var halfStep = 0
var bpm = 60
let player = PWMTone(PWMOut(Id.PWM2B), bpm: bpm)

while true {
    player.play(track: Music.twinkle)

    bpm += 40
    player.setBPM(bpm)

    halfStep += 12
    player.setFixedHalfStep(halfStep)

    sleep(ms: 1000)
}