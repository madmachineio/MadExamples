import SwiftIO

let pwm1 = PWMOut(Id.PWM0)
let pwm2 = PWMOut(Id.PWM1)
let pwm3 = PWMOut(Id.PWM2)
let pwm4 = PWMOut(Id.PWM4)

var midiPlayer = MidiPlayer(midiList1, midiList2, midiList3, midiList4)
midiPlayer.setChannls(pwm1, pwm2, pwm3, pwm4)
midiPlayer.playBackground()


while true {

}

