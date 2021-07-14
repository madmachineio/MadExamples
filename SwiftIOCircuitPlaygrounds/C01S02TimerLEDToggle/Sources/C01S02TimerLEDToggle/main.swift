import SwiftIO
import SwiftIOFeather

let led = DigitalOut(Id.D19)
let timer = Timer()

timer.setInterrupt(ms: 1000) {
    led.toggle()
}

while true {
    sleep(ms: 9999)
}