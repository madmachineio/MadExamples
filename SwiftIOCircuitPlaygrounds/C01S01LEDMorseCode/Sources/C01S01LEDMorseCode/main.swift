import SwiftIO
import SwiftIOFeather

let led = DigitalOut(Id.D19)

let sSingal = [false, false, false]
let oSingal = [true, true ,true]


func send(_ values: [Bool], to light: DigitalOut) {
    let long = 1000
    let short = 500

    for value in values {
        light.high()
        if value {
            sleep(ms: long)
        } else {
            sleep(ms: short)
        }

        light.low()
        sleep(ms: short)
    }
}

while true {
    send(sSingal, to: led)
    send(oSingal, to: led)
    send(sSingal, to: led)
    sleep(ms: 1000)
}