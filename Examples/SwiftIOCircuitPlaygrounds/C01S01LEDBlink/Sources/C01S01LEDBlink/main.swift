import SwiftIO
import MadBoard

let led = DigitalOut(Id.D19)

while true {
    led.write(true)
    sleep(ms: 1000)
    led.write(false)
    sleep(ms: 1000)
}