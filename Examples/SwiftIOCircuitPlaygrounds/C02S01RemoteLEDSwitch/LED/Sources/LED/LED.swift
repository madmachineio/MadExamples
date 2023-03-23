// This code is downloaded to board connected to an LED.
// Wait UART data from other board to turn on/off LED.

import SwiftIO
import MadBoard

@main
public struct LED {
    public static func main() {
        let uart = UART(Id.UART0)
        let led = DigitalOut(Id.GREEN, value: true)

        var buffer: [UInt8] = []

        while true {
            // Receive all data from another board via UART bus.
            while uart.checkBufferReceived() > 0 {
                var byte: UInt8 = 0
                uart.read(into: &byte)
                buffer.append(byte)
                sleep(ms: 1)
            }

            // Match the message and change the LED state.
            if buffer.count > 0 {
                // The message from another board is sent in cString 
                // which means the last data is 0, so you need to convert
                // the data in buffer to string using the given encoding. 
                let str = String(cString: buffer)
                
                buffer.removeAll()

                switch str {
                case "on": 
                    led.low()
                    print("LED " + str)
                case "off": 
                    led.high()
                    print("LED " + str)
                default: break
                }
            }
            
            sleep(ms: 10)
        }
    }
}