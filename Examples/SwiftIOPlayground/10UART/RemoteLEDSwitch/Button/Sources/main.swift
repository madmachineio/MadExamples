// This code is downloaded to board connected to a button.
// Detect if the button is pressed/released and send message to another board via UART bus.
// Connect UART0 (RX/TX) of this board to the UART0 (TX/RX) of the other board.

import SwiftIO
import MadBoard


let uart = UART(Id.UART0)

#if SWIFTIOMICRO
let button = DigitalIn(Id.DL)
#else
let button = DigitalIn(Id.D0)
#endif

var buttonPressed = false

while true {
    let pressingButton = button.read()

    // If button is pressed, send message to turn on LED connected to another board.
    if pressingButton && !buttonPressed {
        uart.write("on")
        buttonPressed = true
    }

    // If button is released, send message to turn off LED connected to another board.
    if buttonPressed && !pressingButton {
        uart.write("off")
        buttonPressed = false
    }

    sleep(ms: 5)
}
