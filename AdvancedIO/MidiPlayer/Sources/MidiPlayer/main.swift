import SwiftIO

let pwm1 = PWMOut(Id.PWM0)
let pwm2 = PWMOut(Id.PWM1)
let pwm3 = PWMOut(Id.PWM2)
let pwm4 = PWMOut(Id.PWM4)

var midiPlayer = MidiPlayer(track1Notes, track2Notes, track3Notes, track4Notes)
midiPlayer.setChannls(pwm1, pwm2, pwm3, pwm4)
midiPlayer.playBackground()

while true {
}

