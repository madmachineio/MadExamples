// Connect the USB-Serial converter module to your computer 
// and choose the port in serial monitor.
// Send message (1/0) from computer to turn on/off the LED.

import SwiftIO
import MadBoard


let uart = UART(Id.UART0)
let led = DigitalOut(Id.D18)

while true {
    // Check if there is any message from computer.
    let count = uart.checkBufferReceived()
    
    if count > 0 {
        // Read data from UART buffer.
        var buffer = [UInt8](repeating: 0, count: count)
        uart.read(into: &buffer)
        
        // Decode the data since the text from computer is sent in UTF8 format.
        let command = String(decoding: buffer, as: UTF8.self)
        // Connect the port on your micro board in serial monitor to see printed message
        print(command)
        
        // Set digital output according to the command from computer.
        switch command  {
        case "0": led.low()
        case "1": led.high()
        default: break
        }
    }
    
    sleep(ms: 10)
}
