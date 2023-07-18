// This code is downloaded to board connected to a button.
// Detect if the button is pressed/released and send message to another board via UART bus.
// Connect UART0 (RX/TX) of this board to the UART0 (TX/RX) of the other board.

import SwiftIO
import MadBoard

@main
public struct Button {
    public static func main() {
        let uart = UART(Id.UART0)
        let button = DigitalIn(Id.D1)

        var lastState = false

        while true {
            let currentState = button.read()

            // If button is pressed, send message to turn on LED connected to another board.
            if currentState && !lastState {
                uart.write("on")
                lastState = true
            }

            // If button is released, send message to turn off LED connected to another board.
            if lastState && !currentState {
                uart.write("off")
                lastState = false
            }

            sleep(ms: 5)
        }
    }
}
