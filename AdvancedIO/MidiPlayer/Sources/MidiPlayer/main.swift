import SwiftIO

let pwm1 = PWMOut(Id.PWM0A)
let pwm2 = PWMOut(Id.PWM1A)
let pwm3 = PWMOut(Id.PWM2B)
let pwm4 = PWMOut(Id.PWM3B)

var midiPlayer = MidiPlayer(midiList1, midiList2, midiList3, midiList4)
midiPlayer.setChannls(pwm1, pwm2, pwm3, pwm4)
midiPlayer.playBackground()


while true {

}

