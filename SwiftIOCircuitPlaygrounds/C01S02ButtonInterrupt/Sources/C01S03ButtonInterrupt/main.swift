import SwiftIO
import SwiftIOFeather

let button = DigitalIn(Id.D1)
let led = DigitalOut(Id.D19)

button.setInterrupt(.rising) {
    led.toggle()
}

while true {
    sleep(ms: 9999)
}