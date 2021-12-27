import SwiftIO
import MadBoard

let led = DigitalOut(Id.D19)
let timer = Timer(period: 1000)

timer.setInterrupt() {
    led.toggle()
}

while true {
    sleep(ms: 9999)
}